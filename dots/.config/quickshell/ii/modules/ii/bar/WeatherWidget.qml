import QtQuick

Item {
    id: root
    property var today: null
    property var tomorrow: null

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    // WMO weather code → emoji (主要なものだけ)
    function weatherIcon(code) {
        if (code === 0)              return "☀️"
        if (code <= 2)              return "🌤️"
        if (code === 3)             return "☁️"
        if (code <= 49)             return "🌫️"  // fog/drizzle
        if (code <= 67)             return "🌧️"  // rain
        if (code <= 77)             return "❄️"  // snow
        if (code <= 82)             return "🌦️"  // showers
        if (code <= 99)             return "⛈️"  // thunder
        return "❓"
    }

    function fetch() {
        const req = new XMLHttpRequest()
        const url = "https://api.open-meteo.com/v1/forecast" +
            "?latitude=34.6913&longitude=135.1830" +
            "&daily=weathercode,temperature_2m_max,temperature_2m_min" +
            "&timezone=Asia%2FTokyo&forecast_days=2"

        req.open("GET", url)
        req.onreadystatechange = () => {
            if (req.readyState !== XMLHttpRequest.DONE) return
            if (req.status !== 200) return
            try {
                const d = JSON.parse(req.responseText).daily
                root.today = {
                    icon: root.weatherIcon(d.weathercode[0]),
                    max:  d.temperature_2m_max[0].toFixed(0),
                    min:  d.temperature_2m_min[0].toFixed(0)
                }
                root.tomorrow = {
                    icon: root.weatherIcon(d.weathercode[1]),
                    max:  d.temperature_2m_max[1].toFixed(0),
                    min:  d.temperature_2m_min[1].toFixed(0)
                }
            } catch(e) { console.warn("weather parse error:", e) }
        }
        req.send()
    }

    Timer {
        interval: 30 * 60 * 1000  // 30分ごと
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.fetch()
    }

    Row {
        id: row
        spacing: 8

        // 今日
        Row {
            spacing: 3
            visible: root.today !== null
            Text { text: root.today ? root.today.icon : ""; font.pixelSize: 14 }
            Column {
                spacing: 0
                Text { text: root.today ? `${root.today.max}°` : ""; color: "#f38ba8"; font.pixelSize: 11 }
                Text { text: root.today ? `${root.today.min}°` : ""; color: "#89b4fa"; font.pixelSize: 11 }
            }
        }

        // 区切り
        Text { text: "|"; color: "#6c7086"; font.pixelSize: 12; visible: root.tomorrow !== null }

        // 明日
        Row {
            spacing: 3
            visible: root.tomorrow !== null
            Text { text: root.tomorrow ? root.tomorrow.icon : ""; font.pixelSize: 14; opacity: 0.75 }
            Column {
                spacing: 0
                Text { text: root.tomorrow ? `${root.tomorrow.max}°` : ""; color: "#f38ba8"; font.pixelSize: 11; opacity: 0.75 }
                Text { text: root.tomorrow ? `${root.tomorrow.min}°` : ""; color: "#89b4fa"; font.pixelSize: 11; opacity: 0.75 }
            }
        }
    }
}
