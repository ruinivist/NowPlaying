import QtQuick
import QtQuick.Effects
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
    readonly property real contentWidth: width > 0 ? width : foregroundLabel.implicitWidth
    readonly property real contentHeight: height > 0 ? height : foregroundLabel.implicitHeight

    implicitWidth: foregroundLabel.implicitWidth
    implicitHeight: foregroundLabel.implicitHeight

    PlasmaComponents.Label {
        id: shadowSourceLabel

        visible: false
        width: shadowedLabel.contentWidth
        height: shadowedLabel.contentHeight
        text: foregroundLabel.text
        font: foregroundLabel.font
        lineHeight: foregroundLabel.lineHeight
        elide: foregroundLabel.elide
        horizontalAlignment: foregroundLabel.horizontalAlignment
        verticalAlignment: foregroundLabel.verticalAlignment
        color: "white"
    }

    MultiEffect {
        x: shadowSourceLabel.x
        y: shadowSourceLabel.y
        width: shadowSourceLabel.width
        height: shadowSourceLabel.height
        autoPaddingEnabled: true
        shadowBlur: 0.5
        shadowColor: "#3f4c66"
        shadowEnabled: shadowedLabel.shadowEnabled
        shadowHorizontalOffset: 0
        shadowOpacity: 0.42
        shadowScale: 1
        shadowVerticalOffset: 2
        source: shadowSourceLabel
        visible: shadowedLabel.shadowEnabled
    }

    PlasmaComponents.Label {
        id: foregroundLabel

        width: shadowedLabel.contentWidth
        height: shadowedLabel.contentHeight
    }

}
