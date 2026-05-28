pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Current condition
    property string tempC: "0°C"
    property string feelsLikeC: "0°C"
    property string humidity: "0%"
    property string windSpeed: "0 km/h"
    property string description: "Clear"
    property string weatherIcon: "󰖙"
    property string location: "London"

    // Forecast data
    property var forecast: []

    function update() {
        console.log("[WService] Updating weather...");
        weatherProc.running = true;
    }

    Process {
        id: weatherProc
        command: ["curl", "-s", "wttr.in?format=j1"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                console.log("[WService] Data received");
                try {
                    let data = JSON.parse(text);
                    if (!data || !data.current_condition) return;
                    
                    let current = data.current_condition[0];
                    root.tempC = current.temp_C + "°C";
                    root.feelsLikeC = current.FeelsLikeC + "°C";
                    root.humidity = current.humidity + "%";
                    root.windSpeed = current.windspeedKmph + " km/h";
                    root.description = current.weatherDesc[0].value;
                    
                    if (data.nearest_area && data.nearest_area[0].areaName) {
                        root.location = data.nearest_area[0].areaName[0].value;
                    }
                    
                    root.weatherIcon = root.getIcon(current.weatherCode);
                    
                    // Forecast (simplified)
                    let newForecast = [];
                    if (data.weather) {
                        for (let i = 0; i < Math.min(data.weather.length, 5); i++) {
                            let day = data.weather[i];
                            if (day && day.hourly && day.hourly.length > 4) {
                                newForecast.push({
                                    date: day.date,
                                    avgTemp: day.avgtempC + "°C",
                                    icon: root.getIcon(day.hourly[4].weatherCode)
                                });
                            }
                        }
                    }
                    root.forecast = newForecast;
                    console.log("[WService] Update successful:", root.tempC, root.location);
                } catch (e) {
                    console.error("[WService] Error parsing weather data:", e);
                }
            }
        }
    }

    function getIcon(code) {
        let iconMap = {
            "113": "󰖙", "116": "󰖕", "119": "󰖐", "122": "󰖐",
            "143": "󰖑", "176": "󰖗", "200": "󰖓", "248": "󰖑",
            "263": "󰖗", "266": "󰖗", "296": "󰖗", "302": "󰖖",
            "308": "󰖖", "353": "󰖗", "356": "󰖖"
        };
        return iconMap[code] || "󰖐";
    }

    Timer {
        interval: 1800000 // 30 minutes
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.update()
    }
    
    Component.onCompleted: {
        console.log("[WService] Service initialized");
    }
}
