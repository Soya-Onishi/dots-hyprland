import QtQuick
import Quickshell.Io

Item {
    id: root
    property string rxText: "↓ -"
    property string txText: "↑ -"

    implicitWidth: col.implicitWidth
    implicitHeight: col.implicitHeight

    function fmt(bps) {
        if (bps < 1024)        return `${bps} B/s`
        if (bps < 1024 * 1024) return `${(bps / 1024).toFixed(1)} K/s`
        return                        `${(bps / 1024 / 1024).toFixed(1)} M/s`
    }

    Process {
        id: proc
        // デフォルトルートのNICを自動検出して1秒差分を取る
        command: ["bash", "-c", `
            iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -1)
            [ -z "$iface" ] && exit 1
            read rx1 tx1 < <(awk -v i="$iface:" '$1==i {print $2, $10}' /proc/net/dev)
            sleep 1
            read rx2 tx2 < <(awk -v i="$iface:" '$1==i {print $2, $10}' /proc/net/dev)
            echo "$((rx2-rx1)) $((tx2-tx1))"
        `]

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(" ")
                if (parts.length === 2) {
                    root.rxText = "↓ " + root.fmt(parseInt(parts[0]))
                    root.txText = "↑ " + root.fmt(parseInt(parts[1]))
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    Column {
        id: col
        spacing: 1
        Text { text: root.rxText; color: "#89dceb"; font.pixelSize: 11 }
        Text { text: root.txText; color: "#a6e3a1"; font.pixelSize: 11 }
    }
}
