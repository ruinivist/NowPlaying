import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "preferences-desktop"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Visualiser")
        icon: "view-media-visualization"
        source: "configVisualizer.qml"
    }
}
