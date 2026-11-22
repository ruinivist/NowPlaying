import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    required property var player
    property string configuredFontFamily: "Noto Sans"
    property bool configuredTrackTextItalic: false
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
    property string configuredPlaybackButtonsMode: "hover"
    property string configuredSeekBarMode: "hover"
    property int configuredSeekBarHeight: 2
    property bool configuredShowSeekTime: true
    property int configuredTrackTextVerticalSpacing: 5
    property int configuredLabelVerticalSpacing: 0
    property int configuredSeparatorGapLabel: 4
    property int configuredSeparatorGapTrack: 4
    property int configuredSeparatorHeight: 90
    property bool configuredHideSeparator: false
    property bool configuredVisualizerEnabled: true
    required property int visualizerGap
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
    readonly property bool mediaControlsTargetShown: mediaControlsEnabled && !hideNowPlayingArea && (effectivePlaybackButtonsMode === "always" || playbackHoverActive)
    readonly property int artworkControlsGap: configuredUseLabelArtwork && root.player.artUrl.length > 0 ? 6 : 0
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
    readonly property int seekLineThickness: Math.max(1, Math.min(8, configuredSeekBarHeight))
    readonly property int effectiveLabelVerticalSpacing: configuredLabelVerticalSpacing
    readonly property int effectiveSeparatorGapLabel: Math.max(0, configuredSeparatorGapLabel)
    readonly property int effectiveSeparatorGapTrack: Math.max(0, configuredSeparatorGapTrack)
    readonly property int effectiveSeparatorHeight: Math.max(0, Math.min(100, configuredSeparatorHeight))
    readonly property var effectiveLabelLines: (configuredLabelText || "").split(/\r?\n/)
    readonly property string effectivePlaybackButtonsMode: configuredPlaybackButtonsMode === "always" || configuredPlaybackButtonsMode === "hidden" ? configuredPlaybackButtonsMode : "hover"
    readonly property bool mediaControlsEnabled: effectivePlaybackButtonsMode !== "hidden"
    readonly property string effectiveSeekBarMode: configuredSeekBarMode === "always" || configuredSeekBarMode === "hidden" ? configuredSeekBarMode : "hover"
    readonly property bool hoverActivationEnabled: effectivePlaybackButtonsMode === "hover" || effectiveSeekBarMode === "hover"
    readonly property bool seekBarAvailable: effectiveSeekBarMode !== "hidden" && root.player.ready && root.player.canSeek && Number.isFinite(root.player.songLength) && root.player.songLength > 0
    readonly property real seekDurationSeconds: seekBarAvailable ? root.player.songLength / 1000000 : 0
    readonly property real seekPositionSeconds: seekBarAvailable && Number.isFinite(root.player.songPosition) ? Math.max(0, Math.min(seekDurationSeconds, root.player.songPosition / 1000000)) : 0
    readonly property bool seekRevealTargetShown: seekBarAvailable && seekBarFits && (effectiveSeekBarMode === "always" || playbackHoverActive)
    readonly property bool positionRefreshActive: visible && seekRevealTargetShown
    property real seekRevealProgress: seekRevealTargetShown ? 1 : 0
    property var seekScrubSnapshot: null
    property real seekScrubStartValue: 0
    property bool seekPointerPending: false
    readonly property bool hasTrackInfo: root.player.ready && (((root.player.title || "").trim().length > 0) || ((root.player.artists || "").trim().length > 0))
    readonly property bool rawHoverActive: rootHoverHandler.hovered
    readonly property bool playbackHoverActive: rawHoverActive || hoverExitTimer.running || (seekBarAvailable && seekBarFits && (seekSlider.pressed || seekHoverHandler.hovered || (effectiveSeekBarMode === "hover" && seekSlider.activeFocus)))
    readonly property real seekMinimumTextHeight: Math.ceil(minimumTitleFontMetrics.height) + Math.ceil(minimumArtistFontMetrics.height)
    readonly property real seekBaseTextHeight: titleFontMetrics.height + artistFontMetrics.height
    readonly property real seekLayoutSpacing: {
        const spacing = root.effectiveTrackTextVerticalSpacing;
        if (root.seekRevealProgress <= 0 || spacing <= 0)
            return spacing;

        const remaining = infoColumnWrapper.seekGapEnd - root.seekMinimumTextHeight - seekBarRow.height;
        return Math.min(spacing, Math.max(0, remaining));
    }
    readonly property real seekTextFitScale: {
        if (root.seekRevealProgress <= 0)
            return 1;

        const availableTextHeight = infoColumnWrapper.seekGapEnd - root.seekLayoutSpacing - seekBarRow.height;
        if (availableTextHeight >= root.seekBaseTextHeight)
            return 1;

        // Allow for whole-pixel font sizes and layout rounding.
        return Math.max(root.seekMinimumTextHeight, availableTextHeight - 2) / root.seekBaseTextHeight;
    }
    readonly property bool seekBarFits: trackRow.height >= seekMinimumTextHeight + seekSlider.implicitHeight

    FontMetrics {
        id: titleFontMetrics

        font.family: root.configuredFontFamily
        font.pixelSize: root.effectiveTitleFontSize
        font.bold: true
        font.italic: root.configuredTrackTextItalic
    }

    FontMetrics {
        id: artistFontMetrics

        font.family: root.configuredFontFamily
        font.pixelSize: root.effectiveArtistFontSize
        font.italic: root.configuredTrackTextItalic
    }

    FontMetrics {
        id: minimumTitleFontMetrics

        font.family: root.configuredFontFamily
        font.pixelSize: Math.min(2, root.effectiveTitleFontSize)
        font.bold: true
        font.italic: root.configuredTrackTextItalic
    }

    FontMetrics {
        id: minimumArtistFontMetrics

        font.family: root.configuredFontFamily
        font.pixelSize: Math.min(2, root.effectiveArtistFontSize)
        font.italic: root.configuredTrackTextItalic
    }

    visible: hasTrackInfo || effectiveLabelVisibilityMode === "always"
    focus: true
    onRawHoverActiveChanged: {
        if (!root.hoverActivationEnabled) {
            hoverExitTimer.stop();
            return;
        }
        if (rawHoverActive)
            hoverExitTimer.stop();
        else
            hoverExitTimer.restart();
    }
    onHoverActivationEnabledChanged: {
        if (!root.hoverActivationEnabled)
            hoverExitTimer.stop();
    }
    onPositionRefreshActiveChanged: {
        if (positionRefreshActive)
            root.player.updatePosition();
    }
    function captureSeekSnapshot() {
        return {
            player: root.player.resolvedPlayer,
            title: root.player.title,
            artist: root.player.artists,
            length: root.player.songLength,
            artUrl: root.player.artUrl
        };
    }

    function seekSnapshotMatches(snapshot) {
        return snapshot && snapshot.player === root.player.resolvedPlayer && snapshot.title === root.player.title && snapshot.artist === root.player.artists && snapshot.length === root.player.songLength && snapshot.artUrl === root.player.artUrl;
    }

    function commitSeek(seconds, snapshot) {
        if (!root.seekBarAvailable || !root.seekSnapshotMatches(snapshot))
            return;

        const duration = Math.round(root.player.songLength);
        const position = Math.max(0, Math.min(duration, Math.round(Math.max(0, Math.min(seconds, root.seekDurationSeconds)) * 1000000)));
        root.player.setPosition(position);
    }

    function finishSeekPointerInteraction() {
        if (!root.seekPointerPending)
            return;
        if (Math.abs(seekSlider.value - root.seekScrubStartValue) > 0.000001)
            root.commitSeek(seekSlider.value, root.seekScrubSnapshot);
        root.seekPointerPending = false;
        root.seekScrubSnapshot = null;
    }
    Keys.onPressed: event => {
        if (!root.mediaControlsEnabled) {
            event.accepted = false;
            return;
        }
        if (!event.modifiers) {
            event.accepted = true;
            if (event.key === Qt.Key_Space || event.key === Qt.Key_K)
                root.player.togglePlayPause();
            else if (event.key === Qt.Key_P)
                root.player.previous();
            else if (event.key === Qt.Key_N)
                root.player.next();
            else
                event.accepted = false;
        }
    }

    HoverHandler {
        id: rootHoverHandler

        enabled: root.hoverActivationEnabled
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

    Behavior on seekRevealProgress {
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

        objectName: "trackRow"
        x: root.contentInset
        y: root.contentInset
        width: root.availableContentWidth
        // Reserve the bar height and gap only while the visualizer is enabled.
        height: Math.max(0, root.height - root.contentInset * 2 - (root.configuredVisualizerEnabled ? visualizer.implicitHeight + root.visualizerGap : 0))
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

                readonly property bool showsArtwork: root.configuredUseLabelArtwork && root.player.artUrl.length > 0
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
                    artworkSource: root.configuredUseLabelArtwork ? root.player.artUrl : ""
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

                x: {
                    const centeredX = labelSlot.x + (labelSlot.width - width) / 2;
                    return root.labelsOnRight ? Math.max(0, centeredX) : Math.min(leftColumn.width - width, centeredX);
                }
                y: root.labelContentSize + root.artworkControlsGap
                width: implicitWidth
                height: root.buttonSize
                spacing: Math.min(12, Math.max(0, (leftColumn.width - 3 * root.buttonSize) / 2))
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
                        root.player.previous();
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
                        root.player.togglePlayPause();
                        console.log("pause clicked");
                    }

                    contentItem: Kirigami.Icon {
                        source: root.player.playbackStatus === 2 ? "media-playback-pause" : "media-playback-start"
                        color: root.effectiveForegroundColor
                    }
                }

                QQC2.Button {
                    Layout.preferredWidth: buttonSize
                    Layout.preferredHeight: buttonSize
                    padding: 0
                    background: null
                    onClicked: root.player.next()

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

        Item {
            id: infoColumnWrapper

            readonly property real seekGapEnd: root.configuredVisualizerEnabled ? visualizer.y - trackRow.y - y : height

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            Layout.leftMargin: root.hideNowPlayingArea ? root.hideModeHorizontalPadding : 0
            Layout.rightMargin: root.hideNowPlayingArea ? root.hideModeHorizontalPadding : 0

            ColumnLayout {
                id: infoColumn

                objectName: "infoColumn"
                x: 0
                y: {
                    const textWasCompressed = root.seekTextFitScale < 1 || root.seekLayoutSpacing !== root.effectiveTrackTextVerticalSpacing;
                    const restingHeight = textWasCompressed ? Math.max(height, root.seekBaseTextHeight + root.effectiveTrackTextVerticalSpacing) : height;
                    const centeredY = Math.max(0, (parent.height - restingHeight) / 2);
                    return seekBarRow.height > 0 ? Math.max(0, Math.min(centeredY, parent.seekGapEnd - height - seekBarRow.height)) : centeredY;
                }
                width: parent.width
                height: implicitHeight
                spacing: 0

                ShadowedLabel {
                    id: titleLabel

                    objectName: "titleLabel"
                    Layout.fillWidth: true
                    Layout.bottomMargin: root.seekLayoutSpacing
                    shadowEnabled: root.configuredTextShadowEnabled
                    text: root.player.title
                    font.pixelSize: Math.max(1, Math.round(root.effectiveTitleFontSize * root.seekTextFitScale))
                    font.bold: true
                    font.italic: root.configuredTrackTextItalic
                    font.family: root.configuredFontFamily
                    color: root.effectiveForegroundColor
                    lineHeight: 0.8
                    elide: Text.ElideRight
                    horizontalAlignment: root.labelsOnRight ? Text.AlignRight : Text.AlignLeft
                }

                ShadowedLabel {
                    id: artistLabel

                    objectName: "artistLabel"
                    Layout.fillWidth: true
                    Layout.alignment: root.labelsOnRight ? Qt.AlignRight : Qt.AlignLeft
                    shadowEnabled: root.configuredTextShadowEnabled
                    text: root.player.artists
                    font.pixelSize: Math.max(1, Math.round(root.effectiveArtistFontSize * root.seekTextFitScale))
                    font.italic: root.configuredTrackTextItalic
                    font.family: root.configuredFontFamily
                    color: root.effectiveForegroundColor
                    lineHeight: 0.8
                    elide: Text.ElideRight
                    horizontalAlignment: root.labelsOnRight ? Text.AlignRight : Text.AlignLeft
                }
            }

            Item {
                id: seekBarRow

                objectName: "seekBarRow"
                y: (infoColumn.y + infoColumn.height + parent.seekGapEnd - height) / 2
                width: parent.width
                height: visible ? root.seekRevealProgress * seekSlider.implicitHeight : 0
                clip: true
                visible: root.seekBarAvailable && root.seekBarFits

                QQC2.Slider {
                    id: seekSlider

                    objectName: "seekSlider"
                    x: 0
                    y: (parent.height - height) / 2
                    width: parent.width
                    height: implicitHeight
                    implicitHeight: 14
                    padding: 0
                    from: 0
                    to: root.seekDurationSeconds
                    value: root.seekPositionSeconds
                    stepSize: 1
                    live: false
                    focusPolicy: Qt.TabFocus
                    enabled: root.seekBarAvailable
                    readonly property real seekTrackCenterY: height / 2

                    readonly property real seekPreviewSeconds: Math.max(0, Math.min(root.seekDurationSeconds, pressed ? position * root.seekDurationSeconds : value))

                    background: Item {
                        implicitWidth: 200
                        implicitHeight: root.seekLineThickness

                        Rectangle {
                            x: 0
                            y: seekSlider.seekTrackCenterY - height / 2
                            width: parent.width
                            height: root.seekLineThickness
                            radius: 2
                            color: root.effectiveForegroundColor
                            opacity: 0.25
                        }

                        Rectangle {
                            x: 0
                            y: seekSlider.seekTrackCenterY - height / 2
                            width: seekSlider.visualPosition * parent.width
                            height: root.seekLineThickness
                            radius: 2
                            color: root.effectiveForegroundColor
                        }
                    }

                    handle: Rectangle {
                        x: seekSlider.leftPadding + seekSlider.visualPosition * (seekSlider.availableWidth - width)
                        y: seekSlider.seekTrackCenterY - height / 2
                        implicitWidth: 8
                        implicitHeight: 8
                        radius: width / 2
                        color: root.effectiveForegroundColor
                    }

                    HoverHandler {
                        id: seekHoverHandler
                    }

                    onPressedChanged: {
                        if (pressed) {
                            root.seekPointerPending = true;
                            root.seekScrubStartValue = value;
                            root.seekScrubSnapshot = root.captureSeekSnapshot();
                        } else if (root.seekPointerPending) {
                            Qt.callLater(root.finishSeekPointerInteraction);
                        }
                    }
                    onMoved: {
                        if (pressed)
                            return;
                        if (root.seekPointerPending) {
                            root.finishSeekPointerInteraction();
                            return;
                        }
                        root.commitSeek(value, root.captureSeekSnapshot());
                    }
                }
            }

            Text {
                id: seekTime

                objectName: "seekTime"
                anchors.right: seekBarRow.right
                y: seekBarRow.y + seekBarRow.height / 2 - height - 6
                opacity: root.seekRevealProgress
                visible: root.configuredShowSeekTime && seekBarRow.visible && seekBarRow.height > 0 && x >= 0 && y >= 0 && !overlaps(titleLabel) && !overlaps(artistLabel)
                text: root.player.formatTrackTime(seekSlider.seekPreviewSeconds) + " / " + root.player.formatTrackTime(root.seekDurationSeconds)
                color: root.effectiveForegroundColor
                font.family: root.configuredFontFamily
                font.pixelSize: 14
                font.italic: true
                textFormat: Text.PlainText

                function overlaps(label) {
                    const labelTop = infoColumn.y + label.y;
                    return label.text.length > 0 && y < labelTop + label.height && y + height > labelTop && (root.labelsOnRight || x < label.x + Math.min(label.width, label.implicitWidth) + 4);
                }
            }
        }
    }

    Visualizer {
        id: visualizer

        objectName: "visualizer"
        visible: root.configuredVisualizerEnabled
        barColor: root.configuredVisualizerColorMode === "custom" ? (root.configuredVisualizerColor || "white") : root.effectiveForegroundColor
        barHeight: root.configuredVisualizerBarHeight
        barCount: root.configuredVisualizerBarCount
        smoothing: root.configuredVisualizerSmoothing
        scaleMode: root.configuredVisualizerScale

        x: root.contentInset
        y: trackRow.y + trackRow.height + root.visualizerGap
        width: visible ? root.availableContentWidth : 0
        height: visible ? Math.min(implicitHeight, Math.max(0, root.height - y - root.contentInset)) : 0
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.positionRefreshActive && root.player.playbackStatus === 2
        onTriggered: {
            if (!seekSlider.pressed)
                root.player.updatePosition();
        }
    }
}
