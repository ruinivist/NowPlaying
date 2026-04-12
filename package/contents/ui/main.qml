import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    // Properties accessed from configuration.
    // "qmllint" sees `plasmoid` as QObject here, but Plasma injects `configuration` at runtime.
    // qmllint disable missing-property
    property int configuredOpacity: plasmoid.configuration.opacity

    width: Kirigami.Units.gridUnit * 25
    height: Kirigami.Units.gridUnit * 5
    Layout.minimumWidth: Kirigami.Units.gridUnit * 25
    Layout.minimumHeight: Kirigami.Units.gridUnit * 5
    Plasmoid.backgroundHints: "NoBackground"
    opacity: configuredOpacity / 100

    Player {
        id: player
    }

    fullRepresentation: Representation {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 25
        Layout.minimumHeight: Kirigami.Units.gridUnit * 5
        Layout.preferredWidth: root.width
        Layout.preferredHeight: root.height
    }

    compactRepresentation: Representation {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 25
        Layout.minimumHeight: Kirigami.Units.gridUnit * 5
    }

}
