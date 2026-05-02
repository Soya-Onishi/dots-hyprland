import QtQuick
import Quickshell.Io

Item {
    id: root
    property real temp: 0
    readonly property string displayText: temp > 0 ? `${temp.toFixed(0)}°C` : "--°C"

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Process {
        id: proc
        // Intel: "Package id 0", AMD: "Tdie" or "Tctl"
        command: ["bash", "-c",
            "sensors | grep -E 'Package id 0:|Tdie:|Tctl:' | head -1 | grep -oP '\\+\\K[0-9]+'"]

        stdout: SplitParser {
            onRead: data => {
                const v = parseFloat(data)
                if (!isNaN(v)) root.temp = v
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    // 見た目はBarの既存スタイルに合わせて調整する
    Row {
        spacing: 4
        Text {
            text: ""   // nerd font: thermometer
            color: root.temp > 80 ? "#ff6b6b" : root.temp > 70 ? "#ffa94d" : "#a6e3a1"
            font.pixelSize: 14
        }
        Text {
            id: label
            text: root.displayText
            color: "#cdd6f4"
            font.pixelSize: 13
        }
    }
}
