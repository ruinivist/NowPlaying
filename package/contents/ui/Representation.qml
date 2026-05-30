import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

MouseArea {
    id: mediaControlsMouseArea

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
    readonly property double buttonSize: 16
    readonly property string effectiveLabelVisibilityMode: configuredLabelVisibilityMode === "always" || configuredLabelVisibilityMode === "never" ? configuredLabelVisibilityMode : "auto"
    readonly property bool labelsOnRight: configuredLabelPlacement === "right"
    readonly property bool hideNowPlayingArea: effectiveLabelVisibilityMode === "never"
    readonly property bool usesCustomBackground: configuredBackgroundStyle === "custom"
    readonly property int hideModeHorizontalPadding: 8
    readonly property int labelRailWidth: 100
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
    readonly property bool nowPlayingLabelsVisible: {
        if (effectiveLabelVisibilityMode === "always")
            return true;

        if (effectiveLabelVisibilityMode === "never")
            return false;

        return hasTrackInfo;
    }

    focus: true
    acceptedButtons: Qt.NoButton
    hoverEnabled: true
    onRawHoverActiveChanged: {
        if (!mediaControlsMouseArea.mediaControlsEnabled) {
            hoverExitTimer.stop();
            return ;
        }
        if (rawHoverActive)
            hoverExitTimer.stop();
        else
            hoverExitTimer.restart();
    }
    onMediaControlsEnabledChanged: {
        if (!mediaControlsMouseArea.mediaControlsEnabled)
            hoverExitTimer.stop();

    }
    Keys.onPressed: (event) => {
        if (!mediaControlsMouseArea.mediaControlsEnabled) {
            event.accepted = false;
            return ;
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

        enabled: mediaControlsMouseArea.mediaControlsEnabled
        margin: 60
    }

    Timer {
        id: hoverExitTimer

        interval: 300
    }

    Rectangle {
        anchors.fill: parent
        visible: mediaControlsMouseArea.usesCustomBackground
        color: mediaControlsMouseArea.effectiveBackgroundColor
        radius: mediaControlsMouseArea.effectiveBackgroundRadius
    }

    RowLayout {
        anchors.fill: parent
        layoutDirection: mediaControlsMouseArea.labelsOnRight ? Qt.RightToLeft : Qt.LeftToRight

        ColumnLayout {
            id: leftColumn

            visible: !mediaControlsMouseArea.hideNowPlayingArea
            Layout.fillHeight: true
            Layout.minimumWidth: visible ? mediaControlsMouseArea.labelRailWidth : 0
            Layout.preferredWidth: visible ? mediaControlsMouseArea.labelRailWidth : 0
            Layout.maximumWidth: visible ? mediaControlsMouseArea.labelRailWidth : 0
            states: [
                State {
                    name: "buttonsVisible"
                    when: mediaControlsMouseArea.controlsHoverActive

                    PropertyChanges {
                        target: nowPlayingLabels
                        Layout.bottomMargin: 10
                    }

                },
                State {
                    name: "buttonsHidden"
                    when: !mediaControlsMouseArea.controlsHoverActive

                    PropertyChanges {
                        target: nowPlayingLabels
                        Layout.bottomMargin: 0
                    }

                }
            ]

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            ColumnLayout {
                id: nowPlayingLabels

                Layout.alignment: mediaControlsMouseArea.labelsOnRight ? Qt.AlignLeft : Qt.AlignRight
                Layout.fillWidth: true
                visible: mediaControlsMouseArea.nowPlayingLabelsVisible

                LabelContent {
                    Layout.alignment: mediaControlsMouseArea.labelsOnRight ? Qt.AlignLeft : Qt.AlignRight
                    Layout.fillWidth: true
                    artworkSource: mediaControlsMouseArea.configuredUseLabelArtwork ? player.artUrl : ""
                    labelLines: mediaControlsMouseArea.effectiveLabelLines
                    fontFamily: mediaControlsMouseArea.configuredFontFamily
                    fontPixelSize: mediaControlsMouseArea.effectiveLabelFontSize
                    textColor: mediaControlsMouseArea.effectiveForegroundColor
                    textShadowEnabled: mediaControlsMouseArea.configuredTextShadowEnabled
                    verticalSpacing: mediaControlsMouseArea.effectiveLabelVerticalSpacing
                    horizontalAlignment: mediaControlsMouseArea.labelsOnRight ? Text.AlignLeft : Text.AlignRight
                    borderRadius: mediaControlsMouseArea.effectiveImageBorderRadius
                    artworkSize: mediaControlsMouseArea.labelRailWidth
                }

            }

            RowLayout {
                id: mediaControls

                Layout.alignment: mediaControlsMouseArea.labelsOnRight ? Qt.AlignLeft : Qt.AlignRight
                enabled: mediaControlsMouseArea.mediaControlsEnabled && mediaControlsMouseArea.controlsHoverActive
                opacity: mediaControlsMouseArea.mediaControlsEnabled && mediaControlsMouseArea.controlsHoverActive && mediaControlsMouseArea.nowPlayingLabelsVisible && !mediaControlsMouseArea.hideNowPlayingArea ? 1 : 0
                visible: mediaControlsMouseArea.mediaControlsEnabled && mediaControlsMouseArea.controlsHoverActive && mediaControlsMouseArea.nowPlayingLabelsVisible && !mediaControlsMouseArea.hideNowPlayingArea

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
                        color: mediaControlsMouseArea.effectiveForegroundColor
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
                        color: mediaControlsMouseArea.effectiveForegroundColor
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
                        color: mediaControlsMouseArea.effectiveForegroundColor
                    }

                }

                Behavior on opacity {
                    PropertyAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }

                }

            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            transitions: Transition {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                    properties: "Layout.bottomMargin"
                }

            }

        }

        Item {
            id: separatorContainer

            visible: mediaControlsMouseArea.nowPlayingLabelsVisible && !mediaControlsMouseArea.hideNowPlayingArea
            Layout.fillHeight: true
            Layout.leftMargin: visible ? mediaControlsMouseArea.effectiveSeparatorGapLabel : 0
            Layout.rightMargin: visible ? mediaControlsMouseArea.effectiveSeparatorGapTrack : 0
            Layout.minimumWidth: visible ? 1 : 0
            Layout.preferredWidth: visible ? 1 : 0
            Layout.maximumWidth: visible ? 1 : 0

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: Math.round(parent.height * mediaControlsMouseArea.effectiveSeparatorHeight / 100)
                color: mediaControlsMouseArea.configuredHideSeparator ? "transparent" : mediaControlsMouseArea.effectiveForegroundColor
            }

        }

        ColumnLayout {
            id: infoColumn

            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.leftMargin: mediaControlsMouseArea.hideNowPlayingArea ? mediaControlsMouseArea.hideModeHorizontalPadding : 0
            Layout.rightMargin: mediaControlsMouseArea.hideNowPlayingArea ? mediaControlsMouseArea.hideModeHorizontalPadding : 0
            spacing: mediaControlsMouseArea.effectiveTrackTextVerticalSpacing

            ShadowedLabel {
                Layout.fillWidth: true
                shadowEnabled: mediaControlsMouseArea.configuredTextShadowEnabled
                text: player.title
                font.pixelSize: mediaControlsMouseArea.effectiveTitleFontSize
                font.bold: true
                font.family: mediaControlsMouseArea.configuredFontFamily
                color: mediaControlsMouseArea.effectiveForegroundColor
                lineHeight: 0.8
                elide: Text.ElideRight
                horizontalAlignment: mediaControlsMouseArea.labelsOnRight ? Text.AlignRight : Text.AlignLeft
            }

            ShadowedLabel {
                Layout.fillWidth: true
                Layout.alignment: mediaControlsMouseArea.labelsOnRight ? Qt.AlignRight : Qt.AlignLeft
                shadowEnabled: mediaControlsMouseArea.configuredTextShadowEnabled
                text: player.artists
                font.pixelSize: mediaControlsMouseArea.effectiveArtistFontSize
                font.family: mediaControlsMouseArea.configuredFontFamily
                color: mediaControlsMouseArea.effectiveForegroundColor
                lineHeight: 0.8
                elide: Text.ElideRight
                horizontalAlignment: mediaControlsMouseArea.labelsOnRight ? Text.AlignRight : Text.AlignLeft
            }

        }

    }

}
