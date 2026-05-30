import QtQuick
import org.kde.plasma.components as PlasmaComponents

Item {
    id: shadowedLabel

    property alias text: foregroundLabel.text
    property alias font: foregroundLabel.font
    property alias lineHeight: foregroundLabel.lineHeight
    property alias elide: foregroundLabel.elide
    property alias horizontalAlignment: foregroundLabel.horizontalAlignment
    property alias verticalAlignment: foregroundLabel.verticalAlignment
    property alias color: foregroundLabel.color
    property bool shadowEnabled: false

    implicitWidth: foregroundLabel.implicitWidth + (shadowEnabled ? 1 : 0)
    implicitHeight: foregroundLabel.implicitHeight + (shadowEnabled ? 1 : 0)

    PlasmaComponents.Label {
        id: shadowLabel

        visible: shadowedLabel.shadowEnabled
        x: 1
        y: 1
        width: foregroundLabel.width
        height: foregroundLabel.height
        text: foregroundLabel.text
        font: foregroundLabel.font
        lineHeight: foregroundLabel.lineHeight
        elide: foregroundLabel.elide
        horizontalAlignment: foregroundLabel.horizontalAlignment
        verticalAlignment: foregroundLabel.verticalAlignment
        color: "#99000000"
    }

    PlasmaComponents.Label {
        id: foregroundLabel

        anchors.fill: parent
    }

}
