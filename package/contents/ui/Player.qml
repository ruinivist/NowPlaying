/**
Credits: https://github.com/ccatterina/plasmusic-toolbar

looked handy, ty
*/

import QtQml.Models
import QtQuick
import org.kde.plasma.private.mpris as Mpris

QtObject {
    id: root

    readonly property int containerRole: Qt.UserRole + 1
    property string sourceName: "any"
    property string sourcePriority: ""
    property bool sourceWhitelist: false
    property var mpris2Model
    property int modelRevision: 0
    readonly property var normalizedSourcePriority: parseSourcePriority(sourcePriority)
    readonly property var resolvedPlayer: resolvePlayer()
    readonly property bool ready: {
        if (!resolvedPlayer)
            return false;

        return sourceName === "any" || entriesMatch(resolvedPlayer.desktopEntry, sourceName);
    }
    readonly property string artists: ready ? resolvedPlayer.artist : ""
    readonly property string title: ready ? resolvedPlayer.track : ""
    readonly property int playbackStatus: ready ? resolvedPlayer.playbackStatus : Mpris.PlaybackStatus.Unknown
    readonly property int shuffle: ready ? resolvedPlayer.shuffle : Mpris.ShuffleStatus.Unknown
    readonly property string artUrl: ready ? resolvedPlayer.artUrl : ""
    readonly property int loopStatus: ready ? resolvedPlayer.loopStatus : Mpris.LoopStatus.Unknown
    readonly property double songPosition: ready ? resolvedPlayer.position : 0
    readonly property double songLength: ready ? resolvedPlayer.length : 0
    readonly property real volume: ready ? resolvedPlayer.volume : 0
    readonly property string identity: ready ? resolvedPlayer.identity : ""
    readonly property bool canGoNext: ready ? resolvedPlayer.canGoNext : false
    readonly property bool canGoPrevious: ready ? resolvedPlayer.canGoPrevious : false
    readonly property bool canPlay: ready ? resolvedPlayer.canPlay : false
    readonly property bool canPause: ready ? resolvedPlayer.canPause : false
    readonly property bool canSeek: ready ? resolvedPlayer.canSeek : false
    readonly property bool canRaise: ready ? resolvedPlayer.canRaise : false
    // To know whether Shuffle and Loop can be changed we have to check if the property is defined,
    // unlike the other commands, LoopStatus and Shuffle do not have specific properties such as
    // CanPause, CanSeek, etc.
    readonly property bool canChangeShuffle: ready ? resolvedPlayer.shuffle !== undefined : false
    readonly property bool canChangeLoopStatus: ready ? resolvedPlayer.loopStatus !== undefined : false

    function normalizedEntry(value) {
        return (value || "").toString().trim().toLowerCase();
    }

    function entriesMatch(left, right) {
        const normalizedLeft = normalizedEntry(left);
        const normalizedRight = normalizedEntry(right);
        if (!normalizedLeft || !normalizedRight)
            return false;

        return normalizedLeft === normalizedRight;
    }

    function parseSourcePriority(value) {
        return (value || "").split(",").map((entry) => {
            return normalizedEntry(entry);
        }).filter((entry) => {
            return entry.length > 0;
        });
    }

    function playerAt(row) {
        if (!mpris2Model || row < 0 || row >= mpris2Model.rowCount())
            return null;

        return mpris2Model.data(mpris2Model.index(row, 0), containerRole);
    }

    function findPlayerByEntry(targetEntry) {
        if (!targetEntry || !mpris2Model)
            return null;

        const playerCount = mpris2Model.rowCount();
        for (let row = 0; row < playerCount; ++row) {
            const player = playerAt(row);
            if (player && entriesMatch(player.desktopEntry, targetEntry))
                return player;

        }
        return null;
    }

    function resolvePlayer() {
        modelRevision;
        if (!mpris2Model)
            return null;

        for (const targetEntry of normalizedSourcePriority) {
            const matchedPlayer = findPlayerByEntry(targetEntry);
            if (matchedPlayer)
                return matchedPlayer;

        }
        if (sourceWhitelist && normalizedSourcePriority.length > 0)
            return null;

        return mpris2Model.currentPlayer || null;
    }

    function togglePlayPause() {
        if (resolvedPlayer)
            resolvedPlayer.PlayPause();

    }

    function setPosition(position) {
        if (resolvedPlayer)
            resolvedPlayer.position = position;

    }

    function next() {
        if (resolvedPlayer)
            resolvedPlayer.Next();

    }

    function previous() {
        if (resolvedPlayer)
            resolvedPlayer.Previous();

    }

    function updatePosition() {
        if (resolvedPlayer)
            resolvedPlayer.updatePosition();

    }

    function setVolume(volume) {
        if (resolvedPlayer)
            resolvedPlayer.volume = volume;

    }

    function changeVolume(delta, showOSD) {
        if (resolvedPlayer)
            resolvedPlayer.changeVolume(delta, showOSD);

    }

    function setShuffle(shuffle) {
        if (resolvedPlayer)
            resolvedPlayer.shuffle = shuffle;

    }

    function setLoopStatus(loopStatus) {
        if (resolvedPlayer)
            resolvedPlayer.loopStatus = loopStatus;

    }

    function raise() {
        if (resolvedPlayer)
            resolvedPlayer.Raise();

    }

    function formatTrackTime(s) {
        const hours = Math.floor(s / 3600);
        let minutes = Math.floor((s - hours * 3600) / 60);
        let seconds = Math.ceil(s - hours * 3600 - minutes * 60);
        minutes = minutes < 10 ? "0" + minutes : minutes;
        seconds = seconds < 10 ? "0" + seconds : seconds;
        return minutes + ":" + seconds;
    }

    mpris2Model: Mpris.Mpris2Model {
        onRowsInserted: root.modelRevision += 1
        onRowsRemoved: root.modelRevision += 1
        onModelReset: root.modelRevision += 1
        onDataChanged: root.modelRevision += 1
        onCurrentPlayerChanged: root.modelRevision += 1
    }

}
