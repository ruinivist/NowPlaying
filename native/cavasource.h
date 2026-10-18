// Owns a CAVA subprocess and decodes its fixed-size binary frames.
// The widget loads this source through the packaged NowPlaying.Native module.
#pragma once

#include <QByteArray>
#include <QObject>
#include <QProcess>
#include <QTemporaryFile>
#include <QTimer>
#include <QVariantList>
#include <QtQml/qqmlregistration.h>

// ---------- Frame decoding ----------

/// Keeps the newest complete frame and retains any unfinished bytes.
/// Used by CavaSource to turn the stdout stream into fixed-size QML updates.
class CavaFrames {
public:
  static constexpr int BarCount = 100;
  static constexpr int FrameRate = 30;

  /// Returns true only when a complete frame changes the published values.
  /// A single read may contain several frames; only the latest is published.
  bool append(const QByteArray &bytes);
  QByteArray values = QByteArray(BarCount, '\0');
  QByteArray pending;
};

// ---------- Process lifecycle ----------

/// Owns capture for one QML consumer without changing the user's CAVA settings.
/// Publishes the configured number of unsigned levels (0–255); inactive or
/// failed capture is flat.
class CavaSource : public QObject {
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(bool available READ available CONSTANT)
  Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
  Q_PROPERTY(
      int barCount READ barCount WRITE setBarCount NOTIFY barCountChanged)
  Q_PROPERTY(
      int smoothing READ smoothing WRITE setSmoothing NOTIFY smoothingChanged)
  Q_PROPERTY(QVariantList levels READ levels NOTIFY frameChanged)
  Q_PROPERTY(QString error READ error NOTIFY errorChanged)

public:
  explicit CavaSource(QObject *parent = nullptr);
  ~CavaSource() override;

  bool available() const { return !m_executable.isEmpty(); }
  int barCount() const { return m_barCount; }
  void setBarCount(int barCount);
  int smoothing() const { return m_smoothing; }
  void setSmoothing(int smoothing);
  bool active() const { return m_active; }

  /// Requests capture; true does not guarantee that CAVA is running.
  /// Failures remain in error until a false-to-true transition retries capture.
  void setActive(bool active);
  QVariantList levels() const;
  QString error() const { return m_error; }

Q_SIGNALS:
  void activeChanged();
  void barCountChanged();
  void smoothingChanged();
  void frameChanged();
  void errorChanged();

private:
  // ---------- Capture and process events ----------

  void start();
  void stop();
  void reconfigure();
  bool prepareConfig();
  void readOutput();
  void readStderr();
  void handleError(QProcess::ProcessError error);
  void handleFinished(int exitCode, QProcess::ExitStatus status);

  // ---------- Published state ----------

  void clear();
  void fail(const QString &message);

  // ---------- Owned resources ----------

  const QString m_executable;
  CavaFrames m_frames;
  QProcess m_process;
  QTemporaryFile m_config;
  QTimer m_killTimer;
  QTimer m_reconfigureTimer;
  int m_barCount = CavaFrames::BarCount;
  int m_smoothing = 10;
  QString m_error;
  QString m_stderr;
  // QML's capture request, even if CAVA has failed to start.
  bool m_active = false;
  // Wait for the old process to exit before honoring a new capture request.
  bool m_stopping = false;
};
