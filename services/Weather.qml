pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real temperature: 0
    property string condition: ""
    property string icon: "sunny"
    property bool isLoading: false
    property string errorMessage: ""
    property string location: ""
    property real feelsLike: 0
    property real humidity: 0
    property real windSpeed: 0
    property string windDirection: ""
    property real pressure: 0
    property real visibility: 0
    property real uvIndex: 0
    property var dailyForecast: []
    property var hourlyForecast: []
    property string sunrise: ""
    property string sunset: ""


    // Weather icon mapping from weather codes to material icons
    readonly property var weatherIcons: ({
        0: "sunny", // Clear sky
        1: "partly_cloudy_day", // Mainly clear
        2: "partly_cloudy_day", // Partly cloudy
        3: "cloudy", // Overcast
        45: "foggy", // Fog
        48: "foggy", // Depositing rime fog
        51: "rainy_light", // Light drizzle
        53: "rainy", // Moderate drizzle
        55: "rainy_heavy", // Dense drizzle
        56: "weather_mix", // Light freezing drizzle
        57: "weather_mix", // Dense freezing drizzle
        61: "rainy_light", // Slight rain
        63: "rainy", // Moderate rain
        65: "rainy_heavy", // Heavy rain
        66: "weather_mix", // Light freezing rain
        67: "weather_mix", // Heavy freezing rain
        71: "weather_snowy", // Slight snow
        73: "weather_snowy", // Moderate snow
        75: "weather_snowy", // Heavy snow
        77: "ac_unit", // Snow grains
        80: "rainy_light", // Slight rain showers
        81: "rainy", // Moderate rain showers
        82: "rainy_heavy", // Violent rain showers
        85: "weather_snowy", // Slight snow showers
        86: "weather_snowy", // Heavy snow showers
        95: "thunderstorm", // Thunderstorm
        96: "thunderstorm", // Thunderstorm with slight hail
        99: "thunderstorm" // Thunderstorm with heavy hail
    })

    function refresh(): void {
        if (isLoading) return;

        isLoading = true;
        errorMessage = "";

        // First get location via IP
        locationProcess.running = true;
    }

    function updateWeatherIcon(weatherCode: int): void {
        const iconName = weatherIcons[weatherCode] || "help";
        icon = iconName;
    }

    function getWindDirection(degrees: real): string {
        const directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
        const index = Math.round(((degrees % 360) + 360) % 360 / 45) % 8;
        return directions[index];
    }

    // Auto-refresh every 30 minutes
    Timer {
        interval: 30 * 60 * 1000 // 30 minutes
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // Get location via IP
    Process {
        id: locationProcess

        command: ["curl", "-s", "http://ipinfo.io/json"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    if (data.loc) {
                        const coords = data.loc.split(",");
                        const lat = parseFloat(coords[0]);
                        const lon = parseFloat(coords[1]);

                        root.location = data.city || "Unknown";

                        // Fetch weather data with extended information
                        weatherProcess.command = [
                            "curl", "-s",
                            `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,weather_code,apparent_temperature,relative_humidity_2m,wind_speed_10m,wind_direction_10m,surface_pressure,uv_index&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset&hourly=temperature_2m,weather_code&timezone=auto&temperature_unit=celsius&wind_speed_unit=kmh&forecast_days=7`
                        ];
                        weatherProcess.running = true;
                    } else {
                        root.errorMessage = "Could not determine location";
                        root.isLoading = false;
                    }
                } catch (e) {
                    root.errorMessage = "Location parsing error";
                    root.isLoading = false;
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    root.errorMessage = "Location fetch failed";
                    root.isLoading = false;
                }
            }
        }
    }

    // Get weather data
    Process {
        id: weatherProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    if (data.current) {
                        root.temperature = Math.round(data.current.temperature_2m);
                        root.feelsLike = Math.round(data.current.apparent_temperature);
                        root.humidity = Math.round(data.current.relative_humidity_2m);
                        root.windSpeed = Math.round(data.current.wind_speed_10m);
                        root.windDirection = getWindDirection(data.current.wind_direction_10m);
                        root.pressure = Math.round(data.current.surface_pressure);
                        root.uvIndex = data.current.uv_index || 0;
                        root.updateWeatherIcon(data.current.weather_code);

                        // Map weather code to condition string
                        const code = data.current.weather_code;
                        if (code === 0) root.condition = "Clear";
                        else if (code <= 3) root.condition = "Cloudy";
                        else if (code >= 45 && code <= 48) root.condition = "Foggy";
                        else if (code >= 51 && code <= 67) root.condition = "Rainy";
                        else if (code >= 71 && code <= 86) root.condition = "Snowy";
                        else if (code >= 95) root.condition = "Stormy";
                        else root.condition = "Unknown";

                        // Process daily forecast
                        if (data.daily) {
                            const dailyData = [];
                            for (let i = 0; i < Math.min(7, data.daily.time.length); i++) {
                                dailyData.push({
                                    date: data.daily.time[i],
                                    maxTemp: Math.round(data.daily.temperature_2m_max[i]),
                                    minTemp: Math.round(data.daily.temperature_2m_min[i]),
                                    weatherCode: data.daily.weather_code[i],
                                    icon: root.weatherIcons[data.daily.weather_code[i]] || "help"
                                });
                            }
                            root.dailyForecast = dailyData;

                            // Store sunrise/sunset from today's data
                            if (data.daily.sunrise && data.daily.sunrise[0]) {
                                root.sunrise = new Date(data.daily.sunrise[0]).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false });
                            }
                            if (data.daily.sunset && data.daily.sunset[0]) {
                                root.sunset = new Date(data.daily.sunset[0]).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false });
                            }
                        }

                        // Process hourly forecast (next 6 hours from current time)
                        if (data.hourly) {
                            const now = new Date();
                            const currentHour = now.getHours();
                            const hourlyData = [];

                            // Find the index of the current hour in the data
                            let startIndex = -1;
                            for (let i = 0; i < data.hourly.time.length; i++) {
                                const forecastTime = new Date(data.hourly.time[i]);
                                if (forecastTime >= now) {
                                    startIndex = i;
                                    break;
                                }
                            }

                            if (startIndex >= 0) {
                                // Get the next 6 hours from current time
                                for (let i = 0; i < 6 && (startIndex + i) < data.hourly.time.length; i++) {
                                    const idx = startIndex + i;
                                    hourlyData.push({
                                        time: new Date(data.hourly.time[idx]).toLocaleTimeString('en-US', { hour: '2-digit', hour12: false }),
                                        temp: Math.round(data.hourly.temperature_2m[idx]),
                                        weatherCode: data.hourly.weather_code[idx],
                                        icon: root.weatherIcons[data.hourly.weather_code[idx]] || "help"
                                    });
                                }
                            }
                            root.hourlyForecast = hourlyData;
                        }

                        root.errorMessage = "";
                    } else {
                        root.errorMessage = "Invalid weather data";
                    }
                } catch (e) {
                    root.errorMessage = "Weather parsing error";
                }
                root.isLoading = false;
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    root.errorMessage = "Weather fetch failed";
                    root.isLoading = false;
                }
            }
        }
    }

    reloadableId: "weather"
}