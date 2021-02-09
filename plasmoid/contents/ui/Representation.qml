import QtQuick 2.12
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.12
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore

RowLayout {
    id: fullView
    focus: true
    Keys.onReleased: {
        if (!event.modifiers) {
            event.accepted = true
            if (event.key === Qt.Key_Space || event.key === Qt.Key_K) {
                root.mediaToggle()
            } else if (event.key === Qt.Key_P) {
                root.mediaPrev()
            } else if (event.key === Qt.Key_N) {
                root.mediaNext()
            } else {
                event.accepted = false
            }
        }
    }
    MouseArea {
        // Layout.alignment: Qt.AlignRight
        id: mediaControlsMouseArea
        height: separator.height
        width: nowPlayingColumn.width
        hoverEnabled: true
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0
            id: nowPlayingColumn
            Label {
                id: nowPlayingLabel1
                Layout.alignment: Qt.AlignRight
                text: "NOW"
                lineHeight: 0.8
                // color: "orange"
                font.pixelSize: 16
                font.bold: true
                font.family: plasmoid.configuration.fontFamily
            }
            Label {
                id: nowPlayingLabel2
                Layout.alignment: Qt.AlignRight
                text: "PLAYING"
                lineHeight: 0.8
                // color: "orange"
                font.bold: true
                font.pixelSize: 16
                font.family: plasmoid.configuration.fontFamily
            }
            RowLayout {
                id: mediaControls
                opacity: mediaControlsMouseArea.containsMouse
                Behavior on opacity {
                    PropertyAnimation {
                        easing.type: Easing.InOutQuad
                        duration: 250
                    }
                }
                Button {
                    Layout.preferredWidth: nowPlayingLabel2.width / 3
                    contentItem: PlasmaCore.IconItem {
                        source: "media-skip-backward"
                    }
                    padding: 0
                    background: null
                    onClicked: {
                        root.mediaPrev()
                        console.log("prev clicked")
                    }
                }
                Button {
                    Layout.preferredWidth: nowPlayingLabel2.width / 3
                    id: playButton
                    contentItem: PlasmaCore.IconItem {
                        source: mediaSource.playbackStatus
                                === "Playing" ? "media-playback-start" : "media-playback-pause"
                    }
                    padding: 0
                    background: null
                    onClicked: {
                        root.mediaToggle()
                        console.log("pause clicked")
                    }
                }
                Button {
                    Layout.preferredWidth: nowPlayingLabel2.width / 3
                    contentItem: PlasmaCore.IconItem {
                        source: "media-skip-forward"
                    }
                    onClicked: {
                        root.mediaNext()
                        console.log(mediaSource.playbackStatus)
                        console.log("next clicked")
                    }
                    padding: 0
                    background: null
                }
            }
        }
    }
    Rectangle {
        id: separator
        width: 1
        // color: "black"
        Layout.fillHeight: true
    }

    ColumnLayout {
        Layout.fillWidth: true
        id: infoColumn
        PlasmaComponents.Label {
            font.family: plasmoid.configuration.fontFamily
            text: mediaSource.track
            Layout.fillWidth: true
            font.pixelSize: 28
            // color: "red"
            lineHeight: 0.8
            font.bold: true
            elide: Text.ElideRight
        }
        PlasmaComponents.Label {
            font.family: plasmoid.configuration.fontFamily
            elide: Text.ElideRight
            Layout.maximumWidth: 300
            Layout.fillWidth: true
            text: mediaSource.artist
            font.pixelSize: 26
            // color: "red"
            lineHeight: 0.8
        }
    }
}