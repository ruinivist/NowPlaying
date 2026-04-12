import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

MouseArea {
    id: mediaControlsMouseArea

    readonly property double buttonSize: 16

    focus: true
    hoverEnabled: true
    Keys.onPressed: (event) => {
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

    RowLayout {
        anchors.fill: parent

        ColumnLayout {
            id: leftColumn

            Layout.fillHeight: true
            states: [
                State {
                    name: "buttonsVisible"
                    when: mediaControlsMouseArea.containsMouse

                    PropertyChanges {
                        target: nowPlayingLabels
                        Layout.bottomMargin: 10
                    }

                },
                State {
                    name: "buttonsHidden"
                    when: !mediaControlsMouseArea.containsMouse

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

                Layout.alignment: Qt.AlignRight
                spacing: 0

                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignRight
                    text: "NOW"
                    lineHeight: 0.8
                    font.pixelSize: 16
                    font.bold: true
                    // qmllint disable missing-property
                    font.family: plasmoid.configuration.fontFamily
                }

                PlasmaComponents.Label {
                    id: nowPlayingLabel2

                    Layout.alignment: Qt.AlignRight
                    text: "PLAYING"
                    lineHeight: 0.8
                    font.bold: true
                    font.pixelSize: 16
                    // qmllint disable missing-property
                    font.family: plasmoid.configuration.fontFamily
                }

            }

            RowLayout {
                id: mediaControls

                Layout.alignment: Qt.AlignHCenter
                opacity: mediaControlsMouseArea.containsMouse ? 1 : 0
                visible: opacity > 0

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

        Rectangle {
            id: separator

            Layout.fillHeight: true
            width: 1
        }

        ColumnLayout {
            id: infoColumn

            Layout.fillWidth: true

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: player.title
                font.pixelSize: 28
                font.bold: true
                // qmllint disable missing-property
                font.family: plasmoid.configuration.fontFamily
                lineHeight: 0.8
                elide: Text.ElideRight
            }

            PlasmaComponents.Label {
                Layout.maximumWidth: 300
                Layout.fillWidth: true
                text: player.artists
                font.pixelSize: 26
                // qmllint disable missing-property
                font.family: plasmoid.configuration.fontFamily
                lineHeight: 0.8
                elide: Text.ElideRight
            }

        }

    }

}
