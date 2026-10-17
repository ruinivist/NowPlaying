// Renders fixed CAVA levels as downward white bars.
// Used beneath the track row in each widget representation.
pragma ComponentBehavior: Bound

import QtQuick
import "NowPlaying/Native" as Native

Item {
    id: visualizer

    // ---------- Capture ----------

    readonly property var levels: cava.levels

    implicitHeight: 72

    Native.CavaSource {
        id: cava

        // Avoid duplicate capture from hidden representations; playback and window state do not gate capture.
        active: visualizer.visible && visualizer.width > 0 && visualizer.height > 0
    }

    // ---------- Bars ----------

    Repeater {
        model: cava.barCount

        Rectangle {
            required property int index
            readonly property real pitch: Math.max(0, visualizer.width) / cava.barCount

            x: Math.round(index * pitch)
            y: 0
            width: Math.round((index + 0.5) * pitch) - x
            height: Math.min(Math.max(0, visualizer.height), Math.max(1, Math.round(visualizer.height * visualizer.levels[index] / 255)))
            color: "white"
        }
    }
}
