// Implements event-driven CAVA capture and latest-frame delivery.
// QML consumes the published levels through the NowPlaying.Native plugin.
//
// QML requests capture
//         |
//         v
// Start CAVA with our config
//         |
//         v
// Read binary frames from its stdout
//         |
//         v
// Publish configured levels and emit frameChanged

#include "cavasource.h"

#include <QDebug>
#include <QFile>
#include <QStandardPaths>

// ---------- Frame decoding ----------

bool CavaFrames::append(const QByteArray &bytes) {
  pending += bytes;
  // Pipe reads do not align with frame boundaries; leave the partial tail.
  const qsizetype complete = pending.size() / values.size() * values.size();
  if (!complete)
    return false;

  const QByteArray latest =
      pending.mid(complete - values.size(), values.size());
  pending.remove(0, complete);
  if (latest == values)
    return false;
  values = latest;
  return true;
}

// ---------- Process lifecycle ----------

CavaSource::CavaSource(QObject *parent) : QObject(parent) {
  m_reconfigureTimer.setSingleShot(true);
  m_reconfigureTimer.setInterval(0);
  // Settings applied together need only one capture restart.
  connect(&m_reconfigureTimer, &QTimer::timeout, this, [this] {
    if (!m_active)
      return;
    if (m_process.state() == QProcess::NotRunning)
      start();
    else
      stop();
  });
  m_killTimer.setSingleShot(true);
  m_killTimer.setInterval(500);
  connect(&m_killTimer, &QTimer::timeout, &m_process, &QProcess::kill);
  connect(&m_process, &QProcess::readyReadStandardOutput, this,
          &CavaSource::readOutput);
  connect(&m_process, &QProcess::readyReadStandardError, this,
          &CavaSource::readStderr);
  connect(&m_process, &QProcess::started, this, [this] {
    // Deactivation may arrive before the child has finished starting.
    if (m_stopping)
      m_process.terminate();
  });
  connect(&m_process, &QProcess::errorOccurred, this, &CavaSource::handleError);
  connect(&m_process, &QProcess::finished, this, &CavaSource::handleFinished);
}

CavaSource::~CavaSource() {
  m_process.disconnect(this);
  // Destruction cannot wait for timer-driven shutdown.
  if (m_process.state() != QProcess::NotRunning) {
    m_process.kill();
    m_process.waitForFinished(1000);
  }
}

void CavaSource::setActive(bool active) {
  if (m_active == active)
    return;
  m_active = active;
  Q_EMIT activeChanged();
  if (active) {
    if (m_process.state() == QProcess::NotRunning)
      start();
  } else {
    m_reconfigureTimer.stop();
    clear();
    stop();
  }
}

void CavaSource::setBarCount(int barCount) {
  barCount = qBound(1, barCount, 512);
  if (m_barCount == barCount)
    return;
  m_barCount = barCount;
  reconfigure();
  Q_EMIT barCountChanged();
}

void CavaSource::setSmoothing(int smoothing) {
  smoothing = qBound(0, smoothing, 100);
  if (m_smoothing == smoothing)
    return;
  m_smoothing = smoothing;
  Q_EMIT smoothingChanged();
  reconfigure();
}

void CavaSource::reconfigure() {
  clear();
  if (m_active)
    m_reconfigureTimer.start();
}

void CavaSource::stop() {
  if (m_process.state() == QProcess::NotRunning || m_stopping)
    return;
  m_stopping = true;
  m_process.terminate();
  m_killTimer.start();
}

void CavaSource::start() {
  m_reconfigureTimer.stop();
  // A restarted child must never inherit bytes from the previous frame stream.
  if (m_process.isOpen()) {
    m_process.readAllStandardOutput();
    m_process.readAllStandardError();
  }
  clear();
  m_killTimer.stop();
  m_stopping = false;
  m_error.clear();
  m_stderr.clear();
  Q_EMIT errorChanged();
  const QString executable =
      QStandardPaths::findExecutable(QStringLiteral("cava"));
  if (executable.isEmpty()) {
    fail(QStringLiteral("CAVA is not installed or is not on PATH."));
    return;
  }
  if (!prepareConfig())
    return;
  m_process.start(executable, {QStringLiteral("-p"), m_config.fileName()});
}

// ---------- Private capture configuration ----------

/// Writes the bundled settings to the filesystem path CAVA requires.
/// Reuses the private file across activations; destruction removes it.
bool CavaSource::prepareConfig() {
  QFile settings(QStringLiteral(":/nowplaying/cava.conf.in"));
  if (!settings.open(QIODevice::ReadOnly)) {
    fail(settings.errorString());
    return false;
  }
  QByteArray config = settings.readAll();
  if (settings.error() != QFileDevice::NoError) {
    fail(settings.errorString());
    return false;
  }
  config.replace("@BAR_COUNT@", QByteArray::number(m_barCount));
  config.replace("@FRAME_RATE@", QByteArray::number(CavaFrames::FrameRate));
  config.replace("@SMOOTHING@", QByteArray::number(m_smoothing));

  if ((!m_config.isOpen() && !m_config.open()) || !m_config.resize(0) ||
      !m_config.seek(0)) {
    fail(m_config.errorString());
    return false;
  }
  if (m_config.write(config) != config.size() || !m_config.flush()) {
    fail(m_config.errorString());
    m_config.close();
    return false;
  }
  return true;
}

// ---------- Process events ----------

void CavaSource::readOutput() {
  const QByteArray bytes = m_process.readAllStandardOutput();
  if (m_active && !m_stopping && !m_reconfigureTimer.isActive() &&
      m_frames.append(bytes))
    Q_EMIT frameChanged();
}

void CavaSource::readStderr() {
  m_stderr += QString::fromLocal8Bit(m_process.readAllStandardError());
  m_stderr = m_stderr.right(4096);
}

void CavaSource::handleError(QProcess::ProcessError error) {
  // Crashes also emit finished(); failed startup does not.
  if (error != QProcess::FailedToStart)
    return;

  m_killTimer.stop();
  const bool restart = m_stopping && m_active;
  const bool stopped = m_stopping;
  m_stopping = false;
  if (restart)
    start();
  else if (!stopped && m_active)
    fail(m_process.errorString());
}

void CavaSource::handleFinished(int exitCode, QProcess::ExitStatus status) {
  m_killTimer.stop();
  readStderr();
  clear();

  // A reactivation during shutdown waits for the old child to be reaped.
  // Unexpected exits report an error instead of entering a retry loop.
  const bool restart = m_stopping && m_active;
  if (!m_stopping && m_active)
    fail(QStringLiteral("CAVA exited (%1, %2): %3")
             .arg(exitCode)
             .arg(int(status))
             .arg(m_stderr.trimmed()));
  m_stopping = false;
  if (restart)
    start();
}

// ---------- Published state ----------

void CavaSource::clear() {
  m_frames.pending.clear();
  const QByteArray zero(m_barCount, '\0');
  if (m_frames.values != zero) {
    m_frames.values = zero;
    Q_EMIT frameChanged();
  }
}

void CavaSource::fail(const QString &message) {
  clear();
  m_error = message;
  Q_EMIT errorChanged();
  qWarning().noquote() << "NowPlaying visualizer:" << message;
}

// ---------- QML delivery ----------

QVariantList CavaSource::levels() const {
  QVariantList result;
  result.reserve(m_barCount);
  for (unsigned char value : m_frames.values)
    result.append(int(value));
  return result;
}
