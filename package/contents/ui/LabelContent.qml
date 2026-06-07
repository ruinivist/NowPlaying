import QtQuick
import QtQuick.Effects

Item {
    id: labelContent

    required property string artworkSource
    required property var labelLines
    required property string fontFamily
    required property real fontPixelSize
    required property string textColor
    required property bool textShadowEnabled
    required property int verticalSpacing
    required property int horizontalAlignment
    required property int borderRadius
    required property real artworkSize
    property string currentArtworkSource: ""
    property string incomingArtworkSource: ""
    property real currentArtworkOpacity: 0
    property real incomingArtworkOpacity: 0
    property bool crossfadeActive: false
    readonly property bool artworkVisible: currentArtworkOpacity > 0 || incomingArtworkOpacity > 0
    readonly property bool holdsArtworkSlot: currentArtworkSource.length > 0 || artworkVisible
    readonly property real textOpacity: crossfadeActive || (currentArtworkSource.length > 0 && incomingArtworkSource.length > 0) ? 0 : 1 - Math.max(currentArtworkOpacity, incomingArtworkOpacity)

    function resetIncomingArtwork() {
        incomingArtworkSource = "";
        incomingArtworkOpacity = 0;
        crossfadeActive = false;
    }

    function finishIncomingArtwork() {
        currentArtworkSource = incomingArtworkSource;
        currentArtworkOpacity = incomingArtworkOpacity;
        resetIncomingArtwork();
    }

    function clearCurrentArtwork() {
        currentArtworkSource = "";
        currentArtworkOpacity = 0;
        resetIncomingArtwork();
    }

    function startFadeOutToText() {
        crossfadeAnimation.stop();
        fadeInIncomingArtwork.stop();
        resetIncomingArtwork();
        if (currentArtworkSource.length === 0 && currentArtworkOpacity === 0) {
            clearCurrentArtwork();
            return ;
        }
        fadeOutCurrentArtwork.restart();
    }

    function handleArtworkSourceChange() {
        const nextSource = artworkSource;
        if (nextSource.length === 0) {
            startFadeOutToText();
            return ;
        }
        if (nextSource === currentArtworkSource) {
            fadeOutCurrentArtwork.stop();
            currentArtworkOpacity = currentArtworkSource.length > 0 ? 1 : 0;
            resetIncomingArtwork();
            return ;
        }
        if (nextSource === incomingArtworkSource)
            return ;

        fadeOutCurrentArtwork.stop();
        if (currentArtworkSource.length > 0)
            currentArtworkOpacity = 1;

        crossfadeAnimation.stop();
        fadeInIncomingArtwork.stop();
        incomingArtworkSource = nextSource;
        incomingArtworkOpacity = 0;
        crossfadeActive = false;
    }

    function startIncomingTransition() {
        if (incomingArtworkSource.length === 0 || incomingArtworkSource !== artworkSource)
            return ;

        fadeOutCurrentArtwork.stop();
        incomingArtworkOpacity = 0;
        if (currentArtworkSource.length > 0 && currentArtworkOpacity > 0) {
            crossfadeActive = true;
            currentArtworkOpacity = 1;
            crossfadeAnimation.restart();
        } else {
            crossfadeActive = false;
            currentArtworkOpacity = 0;
            fadeInIncomingArtwork.restart();
        }
    }

    function handleIncomingArtworkFailure() {
        if (incomingArtworkSource.length === 0)
            return ;

        resetIncomingArtwork();
        startFadeOutToText();
    }

    clip: holdsArtworkSlot
    implicitWidth: artworkSize
    implicitHeight: artworkSize
    onArtworkSourceChanged: handleArtworkSourceChange()
    Component.onCompleted: handleArtworkSourceChange()

    Image {
        id: currentArtworkImage

        anchors.fill: parent
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        opacity: 0
        source: labelContent.currentArtworkSource
        sourceSize.width: labelContent.artworkSize
        sourceSize.height: labelContent.artworkSize
    }

    Image {
        id: incomingArtworkImage

        anchors.fill: parent
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        opacity: 0
        source: labelContent.incomingArtworkSource
        sourceSize.width: labelContent.artworkSize
        sourceSize.height: labelContent.artworkSize
        onSourceChanged: labelContent.incomingArtworkOpacity = 0
        onStatusChanged: {
            if (source.toString().length === 0)
                return ;

            if (status === Image.Ready)
                labelContent.startIncomingTransition();
            else if (status === Image.Error)
                labelContent.handleIncomingArtworkFailure();
        }
    }

    Rectangle {
        id: artworkMaskShape

        anchors.fill: parent
        antialiasing: true
        color: "white"
        layer.enabled: true
        radius: labelContent.borderRadius
        visible: false
    }

    MultiEffect {
        id: currentArtworkMask

        anchors.fill: parent
        autoPaddingEnabled: false
        maskEnabled: true
        maskSource: artworkMaskShape
        source: currentArtworkImage
        opacity: labelContent.currentArtworkOpacity
        visible: labelContent.currentArtworkSource.length > 0 && opacity > 0
    }

    MultiEffect {
        id: incomingArtworkMask

        anchors.fill: parent
        autoPaddingEnabled: false
        maskEnabled: true
        maskSource: artworkMaskShape
        source: incomingArtworkImage
        opacity: labelContent.incomingArtworkOpacity
        visible: labelContent.incomingArtworkSource.length > 0 && opacity > 0
    }

    Column {
        id: labelTextColumn

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: labelContent.verticalSpacing
        opacity: labelContent.textOpacity
        visible: opacity > 0

        Repeater {
            model: labelContent.labelLines

            delegate: ShadowedLabel {
                required property string modelData

                width: labelTextColumn.width
                shadowEnabled: labelContent.textShadowEnabled
                text: modelData
                lineHeight: 0.8
                font.bold: true
                font.pixelSize: labelContent.fontPixelSize
                font.family: labelContent.fontFamily
                color: labelContent.textColor
                horizontalAlignment: labelContent.horizontalAlignment
            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }

        }

    }

    SequentialAnimation {
        id: crossfadeAnimation

        ParallelAnimation {
            NumberAnimation {
                target: labelContent
                property: "currentArtworkOpacity"
                to: 0
                duration: 250
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                target: labelContent
                property: "incomingArtworkOpacity"
                to: 1
                duration: 250
                easing.type: Easing.InOutQuad
            }

        }

        ScriptAction {
            script: labelContent.finishIncomingArtwork()
        }

    }

    SequentialAnimation {
        id: fadeInIncomingArtwork

        NumberAnimation {
            target: labelContent
            property: "incomingArtworkOpacity"
            to: 1
            duration: 250
            easing.type: Easing.InOutQuad
        }

        ScriptAction {
            script: labelContent.finishIncomingArtwork()
        }

    }

    SequentialAnimation {
        id: fadeOutCurrentArtwork

        NumberAnimation {
            target: labelContent
            property: "currentArtworkOpacity"
            to: 0
            duration: 250
            easing.type: Easing.InOutQuad
        }

        ScriptAction {
            script: labelContent.clearCurrentArtwork()
        }

    }

}
