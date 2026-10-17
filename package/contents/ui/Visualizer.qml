// Renders configured CAVA levels as downward white bars.
// Used beneath the track row in each widget representation.
pragma ComponentBehavior: Bound

import QtQuick
import "NowPlaying/Native" as Native

Item {
    id: visualizer

    // ---------- Capture ----------

    property int barHeight: 100
    property int barCount: 100
    property int smoothing: 10
    property string scaleMode: "linear"
    readonly property var levels: cava.levels

    implicitHeight: Math.max(1, Math.min(512, barHeight))

    Native.CavaSource {
        id: cava

        barCount: visualizer.barCount
        smoothing: visualizer.smoothing

        // Avoid duplicate capture from hidden representations; playback and window state do not gate capture.
        active: visualizer.visible && visualizer.width > 0 && visualizer.height > 0
    }

    // ---------- Bars ----------

    Repeater {
        model: cava.barCount

        Rectangle {
            required property int index
            readonly property real level: (visualizer.levels[index] || 0) / 255
            // Square root lifts weaker signals without changing full-scale peaks.
            readonly property real scaledLevel: visualizer.scaleMode === "linear" ? level : Math.sqrt(level)
            readonly property real pitch: Math.max(0, visualizer.width) / cava.barCount

            x: Math.round(index * pitch)
            y: 0
            width: Math.round((index + 0.5) * pitch) - x
            height: Math.min(Math.max(0, visualizer.height), Math.max(1, Math.round(visualizer.height * scaledLevel)))
            color: "white"
        }
    }
}
