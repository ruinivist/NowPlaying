import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    property string configuredFontFamily: "Noto Sans"
    property int configuredLabelFontSize: 16
    property int configuredTitleFontSize: 28
    property int configuredArtistFontSize: 26
    property string configuredLabelVisibilityMode: "auto"
    property string configuredLabelPlacement: "left"
    property string configuredLabelText: "NOW\nPLAYING"
    property bool configuredUseLabelArtwork: false
    property int configuredImageBorderRadius: 8
    property string configuredBackgroundStyle: "custom"
    property string configuredBackgroundColor: "transparent"
    property int configuredBackgroundRadius: 0
    property string configuredForegroundColor: "white"
    property bool configuredTextShadowEnabled: false
    property bool configuredShowMediaControls: true
    property int configuredTrackTextVerticalSpacing: 5
    property int configuredLabelVerticalSpacing: 0
    property int configuredSeparatorGapLabel: 4
    property int configuredSeparatorGapTrack: 4
    property int configuredSeparatorHeight: 90
    property bool configuredHideSeparator: false
    property bool configuredVisualizerEnabled: true
    property string configuredVisualizerColorMode: "foreground"
    property string configuredVisualizerColor: "white"
    property int configuredVisualizerBarHeight: 100
    property int configuredVisualizerBarCount: 100
    property int configuredVisualizerSmoothing: 10
    property string configuredVisualizerScale: "linear"
    readonly property double buttonSize: 16
    readonly property string effectiveLabelVisibilityMode: configuredLabelVisibilityMode === "always" || configuredLabelVisibilityMode === "never" ? configuredLabelVisibilityMode : "auto"
    readonly property bool labelsOnRight: configuredLabelPlacement === "right"
    readonly property bool hideNowPlayingArea: effectiveLabelVisibilityMode === "never"
    readonly property bool usesCustomBackground: configuredBackgroundStyle === "custom"
    readonly property int hideModeHorizontalPadding: 8
    readonly property int contentInset: 8
    readonly property int availableContentWidth: Math.max(0, width - contentInset * 2)
    readonly property int separatorReservedWidth: !hideNowPlayingArea ? 1 + effectiveSeparatorGapLabel + effectiveSeparatorGapTrack : 0
    readonly property int maxLabelRailSize: Math.max(0, availableContentWidth - separatorReservedWidth)
    // Keep artwork and labels sized to the track row instead of the taller widget.
    readonly property int labelRailSize: Math.max(0, Math.min(trackRow.height, maxLabelRailSize))
    readonly property bool mediaControlsTargetShown: mediaControlsEnabled && controlsHoverActive && !hideNowPlayingArea
    readonly property int artworkControlsGap: configuredUseLabelArtwork && player.artUrl.length > 0 ? 2 : 0
    readonly property real labelShrunkScale: labelRailSize > 0 ? Math.max(0, (labelRailSize - buttonSize - artworkControlsGap) / labelRailSize) : 1
    property real labelContentScale: mediaControlsTargetShown ? labelShrunkScale : 1
    readonly property real controlsReveal: {
        const range = 1 - labelShrunkScale;
        if (range <= 0)
            return mediaControlsTargetShown ? 1 : 0;

        return Math.max(0, Math.min(1, (1 - labelContentScale) / range));
    }
    readonly property real labelContentSize: labelRailSize * labelContentScale
    readonly property int effectiveImageBorderRadius: Math.max(0, configuredImageBorderRadius)
    readonly property string effectiveBackgroundColor: configuredBackgroundColor || "transparent"
    readonly property int effectiveBackgroundRadius: Math.max(0, configuredBackgroundRadius)
    readonly property string effectiveForegroundColor: configuredForegroundColor || "white"
    readonly property int effectiveLabelFontSize: Math.max(1, configuredLabelFontSize)
    readonly property int effectiveTitleFontSize: Math.max(1, configuredTitleFontSize)
    readonly property int effectiveArtistFontSize: Math.max(1, configuredArtistFontSize)
    readonly property int effectiveTrackTextVerticalSpacing: configuredTrackTextVerticalSpacing
    readonly property int effectiveLabelVerticalSpacing: configuredLabelVerticalSpacing
    readonly property int effectiveSeparatorGapLabel: Math.max(0, configuredSeparatorGapLabel)
    readonly property int effectiveSeparatorGapTrack: Math.max(0, configuredSeparatorGapTrack)
    readonly property int effectiveSeparatorHeight: Math.max(0, Math.min(100, configuredSeparatorHeight))
    readonly property var effectiveLabelLines: (configuredLabelText || "").split(/\r?\n/)
    readonly property bool mediaControlsEnabled: configuredShowMediaControls
    readonly property bool hasTrackInfo: player.ready && (((player.title || "").trim().length > 0) || ((player.artists || "").trim().length > 0))
    readonly property bool rawHoverActive: mediaControlsEnabled && rootHoverHandler.hovered
    readonly property bool controlsHoverActive: mediaControlsEnabled && (rawHoverActive || hoverExitTimer.running)

    visible: hasTrackInfo || effectiveLabelVisibilityMode === "always"
    focus: true
    onRawHoverActiveChanged: {
        if (!root.mediaControlsEnabled) {
            hoverExitTimer.stop();
            return;
        }
        if (rawHoverActive)
            hoverExitTimer.stop();
        else
            hoverExitTimer.restart();
    }
    onMediaControlsEnabledChanged: {
        if (!root.mediaControlsEnabled)
            hoverExitTimer.stop();
    }
    Keys.onPressed: event => {
        if (!root.mediaControlsEnabled) {
            event.accepted = false;
            return;
        }
        if (!event.modifiers) {
            event.accepted = true;
            if (event.key === Qt.Key_Space || event.key === Qt.Key_K)
                player.togglePlayPause();
            else if (event.key === Qt.Key_P)
                player.previous();
            else if (event.key === Qt.Key_N)
                player.next();
            else
                event.accepted = false;
        }
    }

    HoverHandler {
        id: rootHoverHandler

        enabled: root.mediaControlsEnabled
        margin: 60
    }

    Timer {
        id: hoverExitTimer

        interval: 300
    }

    Behavior on labelContentScale {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: root.usesCustomBackground
        color: root.effectiveBackgroundColor
        radius: root.effectiveBackgroundRadius
    }

    RowLayout {
        id: trackRow

        x: root.contentInset
        y: root.contentInset
        width: root.availableContentWidth
        // Reserve the bar height and gap only while the visualizer is enabled.
        height: Math.max(0, root.height - root.contentInset * 2 - (root.configuredVisualizerEnabled ? visualizer.implicitHeight + 16 : 0))
        layoutDirection: root.labelsOnRight ? Qt.RightToLeft : Qt.LeftToRight

        Item {
            id: leftColumn

            visible: !root.hideNowPlayingArea
            Layout.fillHeight: true
            Layout.minimumWidth: visible ? root.labelRailSize : 0
            Layout.preferredWidth: visible ? root.labelRailSize : 0
            Layout.maximumWidth: visible ? root.labelRailSize : 0

            Item {
                id: labelSlot

                readonly property bool showsArtwork: root.configuredUseLabelArtwork && player.artUrl.length > 0
                // Text is rasterized at whole pixel sizes, then lightly scaled between steps for smoother motion.
                readonly property real textTargetFontSize: Math.max(1, root.effectiveLabelFontSize * root.labelContentScale)
                readonly property int textRasterFontSize: Math.max(1, Math.round(textTargetFontSize))
                readonly property real textResidualScale: textTargetFontSize / textRasterFontSize

                x: root.labelsOnRight ? 0 : leftColumn.width - width
                y: 0
                width: root.labelContentSize
                height: root.labelContentSize
                clip: true

                LabelContent {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: labelSlot.showsArtwork ? root.labelRailSize : root.labelContentSize / labelSlot.textResidualScale
                    height: labelSlot.showsArtwork ? root.labelRailSize : root.labelContentSize / labelSlot.textResidualScale
                    scale: labelSlot.showsArtwork ? root.labelContentScale : labelSlot.textResidualScale
                    transformOrigin: Item.TopLeft
                    artworkSource: root.configuredUseLabelArtwork ? player.artUrl : ""
                    labelLines: root.effectiveLabelLines
                    fontFamily: root.configuredFontFamily
                    fontPixelSize: labelSlot.showsArtwork ? root.effectiveLabelFontSize : labelSlot.textRasterFontSize
                    textColor: root.effectiveForegroundColor
                    textShadowEnabled: root.configuredTextShadowEnabled
                    verticalSpacing: root.effectiveLabelVerticalSpacing
                    horizontalAlignment: root.labelsOnRight ? Text.AlignLeft : Text.AlignRight
                    borderRadius: root.effectiveImageBorderRadius
                    artworkSize: labelSlot.showsArtwork ? root.labelRailSize : root.labelContentSize / labelSlot.textResidualScale
                }
            }

            RowLayout {
                id: mediaControls

                x: root.labelsOnRight ? 0 : leftColumn.width - width
                y: root.labelContentSize + root.artworkControlsGap
                width: implicitWidth
                height: root.buttonSize
                clip: true
                enabled: root.mediaControlsTargetShown
                opacity: root.controlsReveal
                visible: root.mediaControlsTargetShown || opacity > 0

                QQC2.Button {
                    Layout.preferredWidth: buttonSize
                    Layout.preferredHeight: buttonSize
                    padding: 0
                    background: null
                    onClicked: {
                        player.previous();
                        console.log("prev clicked");
                    }

                    contentItem: Kirigami.Icon {
                        source: "media-skip-backward"
                        color: root.effectiveForegroundColor
                    }
                }

                QQC2.Button {
                    id: playButton

                    Layout.preferredWidth: buttonSize
                    Layout.preferredHeight: buttonSize
                    padding: 0
                    background: null
                    onClicked: {
                        player.togglePlayPause();
                        console.log("pause clicked");
                    }

                    contentItem: Kirigami.Icon {
                        source: player.playbackStatus === 2 ? "media-playback-pause" : "media-playback-start"
                        color: root.effectiveForegroundColor
                    }
                }

                QQC2.Button {
                    Layout.preferredWidth: buttonSize
                    Layout.preferredHeight: buttonSize
                    padding: 0
                    background: null
                    onClicked: player.next()

                    contentItem: Kirigami.Icon {
                        source: "media-skip-forward"
                        color: root.effectiveForegroundColor
                    }
                }
            }
        }

        Item {
            id: separatorContainer

            visible: !root.hideNowPlayingArea
            Layout.fillHeight: true
            Layout.leftMargin: visible ? root.effectiveSeparatorGapLabel : 0
            Layout.rightMargin: visible ? root.effectiveSeparatorGapTrack : 0
            Layout.minimumWidth: visible ? 1 : 0
            Layout.preferredWidth: visible ? 1 : 0
            Layout.maximumWidth: visible ? 1 : 0

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: Math.round(parent.height * root.effectiveSeparatorHeight / 100)
                color: root.configuredHideSeparator ? "transparent" : root.effectiveForegroundColor
            }
        }

        ColumnLayout {
            id: infoColumn

            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.leftMargin: root.hideNowPlayingArea ? root.hideModeHorizontalPadding : 0
            Layout.rightMargin: root.hideNowPlayingArea ? root.hideModeHorizontalPadding : 0
            spacing: root.effectiveTrackTextVerticalSpacing

            ShadowedLabel {
                Layout.fillWidth: true
                shadowEnabled: root.configuredTextShadowEnabled
                text: player.title
                font.pixelSize: root.effectiveTitleFontSize
                font.bold: true
                font.family: root.configuredFontFamily
                color: root.effectiveForegroundColor
                lineHeight: 0.8
                elide: Text.ElideRight
                horizontalAlignment: root.labelsOnRight ? Text.AlignRight : Text.AlignLeft
            }

            ShadowedLabel {
                Layout.fillWidth: true
                Layout.alignment: root.labelsOnRight ? Qt.AlignRight : Qt.AlignLeft
                shadowEnabled: root.configuredTextShadowEnabled
                text: player.artists
                font.pixelSize: root.effectiveArtistFontSize
                font.family: root.configuredFontFamily
                color: root.effectiveForegroundColor
                lineHeight: 0.8
                elide: Text.ElideRight
                horizontalAlignment: root.labelsOnRight ? Text.AlignRight : Text.AlignLeft
            }
        }
    }

    Visualizer {
        id: visualizer

        visible: root.configuredVisualizerEnabled
        barColor: root.configuredVisualizerColorMode === "custom" ? (root.configuredVisualizerColor || "white") : root.effectiveForegroundColor
        barHeight: root.configuredVisualizerBarHeight
        barCount: root.configuredVisualizerBarCount
        smoothing: root.configuredVisualizerSmoothing
        scaleMode: root.configuredVisualizerScale

        x: root.contentInset
        y: trackRow.y + trackRow.height + 16
        width: visible ? root.availableContentWidth : 0
        height: visible ? Math.min(implicitHeight, Math.max(0, root.height - y - root.contentInset)) : 0
    }
}
