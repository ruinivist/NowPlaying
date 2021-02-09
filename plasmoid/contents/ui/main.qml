import QtQuick 2.12
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.12
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: root

    Layout.minimumWidth: units.gridUnit*25
    Layout.minimumHeight: units.gridUnit*5

    Plasmoid.backgroundHints: "NoBackground"

    opacity: plasmoid.configuration.opacity/100

    Representation {
        anchors.fill: parent
    }

    PlasmaCore.DataSource {
        id: mediaSource
        engine: "mpris2"
        connectedSources: sources

        property string currentSource: plasmoid.configuration.preferredSource
        property var currentData: data[currentSource]
        property var currentMetadata: currentData ? currentData.Metadata : {}

        property bool loaded: hasLoaded()

        property string playerIcon: loaded ? currentData["Desktop Icon Name"] : ""
        property string playerName: loaded ? currentData.Identity : ""
        property string playbackStatus: loaded ? currentData.PlaybackStatus : ""
        property string track: currentMetadata ? currentMetadata["xesam:title"]
                                                 || "" : ""
        property string artist: currentMetadata ? currentMetadata["xesam:artist"]
                                                  || "" : ""
        property string album: currentMetadata ? currentMetadata["xesam:album"]
                                                 || "" : ""
        property string albumArt: currentMetadata ? currentMetadata["mpris:artUrl"]
                                                    || "" : ""
        property double length: currentMetadata ? currentMetadata["mpris:length"]
                                                  || 0 : 0
        property double position: loaded ? currentData.Position || 0 : 0

        function hasLoaded() {
            if (typeof currentData === "undefined"
                    || typeof currentMetadata === "undefined") {
                return false
            } else {
                return true
            }
        }

        onSourceRemoved: {
            if (source === currentSource) {
                currentSource = "@multiplex"
            }
        }
    }

    function formatTrackTime(s) {
        var hours = Math.floor(s / 3600)
        var minutes = Math.floor((s - (hours * 3600)) / 60)
        var seconds = Math.ceil(s - (hours * 3600) - (minutes * 60))
        minutes = (minutes < 10) ? "0" + minutes : minutes
        seconds = (seconds < 10) ? "0" + seconds : seconds
        var time = minutes + ":" + seconds
        return time
    }
    function action_open() {
        serviceOp("Raise")
    }
    function mediaPlay() {
        serviceOp("Play")
    }
    function mediaPause() {
        serviceOp("Pause")
    }
    function mediaToggle() {
        serviceOp("PlayPause")
    }
    function mediaPrev() {
        serviceOp("Previous")
    }
    function mediaNext() {
        serviceOp("Next")
    }
    function mediaStop() {
        serviceOp("Stop")
    }
    function updatePosition() {
        serviceOp("GetPosition")
    }
    function setPosition(s) {
        serviceOp("SetPosition", s)
    }
    function mediaSeek(s) {
        serviceOp("Seek", s)
    }
    function serviceOp(op, n) {
        var service = mediaSource.serviceForSource(mediaSource.currentSource)
        var operation = service.operationDescription(op)
        if (typeof n === "number") {
            operation.microseconds = n
        }
        service.startOperationCall(operation)
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            updatePosition()
        }
    }

    Component.onCompleted: {
        mediaSource.serviceForSource("@multiplex").enableGlobalShortcuts()
    }
}
