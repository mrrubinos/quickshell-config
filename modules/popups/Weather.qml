pragma ComponentBehavior: Bound

import qs.services
import qs.ds.text as Text
import qs.ds.icons as Icons
import qs.ds
import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.ds.animations

Column {
    id: root

    property int margin: Foundations.spacing.l

    spacing: Foundations.spacing.s
    width: 380

    // Header with location and current conditions
    Item {
        width: parent.width
        height: headerColumn.implicitHeight + Foundations.spacing.m * 2

        Column {
            id: headerColumn
            anchors.centerIn: parent
            width: parent.width - Foundations.spacing.m * 2
            spacing: Foundations.spacing.xs

            // Location
            Text.HeadingM {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Foundations.palette.base06
                text: Weather.location || "Unknown Location"
            }

            // Current temperature and icon
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Foundations.spacing.m

                // Large weather icon
                Icons.MaterialFontIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    color: {
                        const temp = Weather.temperature;
                        if (temp > 35) return Foundations.palette.base08;
                        if (temp <= 0) return Foundations.palette.base0D;
                        return Foundations.palette.base07;
                    }
                    font.pointSize: 48
                    text: Weather.icon
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    // Large temperature display
                    Text.HeadingL {
                        color: Foundations.palette.base07
                        font.pointSize: 36
                        text: Math.round(Weather.temperature) + "°"
                    }

                    // Feels like
                    Text.BodyM {
                        color: Foundations.palette.base05
                        text: "Feels like " + Math.round(Weather.feelsLike) + "°"
                    }
                }
            }

            // Weather condition
            Text.HeadingS {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Foundations.palette.base06
                text: Weather.condition
            }
        }
    }

    // Current details grid
    Grid {
        width: parent.width
        columns: 3
        columnSpacing: Foundations.spacing.xs
        rowSpacing: Foundations.spacing.xs

        DetailCard {
            icon: "water_drop"
            label: "Humidity"
            value: Weather.humidity + "%"
        }

        DetailCard {
            icon: "air"
            label: "Wind"
            value: Weather.windSpeed + " km/h " + Weather.windDirection
        }

        DetailCard {
            icon: "compress"
            label: "Pressure"
            value: Weather.pressure + " hPa"
        }

        DetailCard {
            icon: "sunny"
            label: "UV Index"
            value: Math.round(Weather.uvIndex)
        }

        DetailCard {
            icon: "wb_twilight"
            label: "Sunrise"
            value: Weather.sunrise || "--:--"
        }

        DetailCard {
            icon: "nights_stay"
            label: "Sunset"
            value: Weather.sunset || "--:--"
        }
    }

    // Hourly forecast
    Column {
        width: parent.width
        spacing: Foundations.spacing.s

        Text.HeadingS {
            color: Foundations.palette.base06
            text: "Hourly Forecast"
        }

        Item {
            width: parent.width
            height: 85

            ListView {
                id: hourlyList
                anchors.fill: parent
                anchors.margins: Foundations.spacing.xs
                orientation: ListView.Horizontal
                spacing: Foundations.spacing.xs
                model: Weather.hourlyForecast
                clip: true

                delegate: Item {
                    required property var modelData
                    width: 55
                    height: parent.height - 10

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text.BodyS {
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Foundations.palette.base05
                            font.pointSize: Foundations.font.size.xs
                            text: modelData.time
                        }

                        Icons.MaterialFontIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Foundations.palette.base05
                            font.pointSize: Foundations.font.size.s
                            text: modelData.icon
                        }

                        Text.BodyS {
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Foundations.palette.base07
                            font.family: Foundations.font.family.mono
                            text: modelData.temp + "°"
                        }
                    }
                }
            }
        }
    }

    // 5-day forecast
    Column {
        width: parent.width
        spacing: Foundations.spacing.xs

        Text.HeadingS {
            color: Foundations.palette.base06
            text: "5-Day Forecast"
        }

        Repeater {
            model: Math.min(5, Weather.dailyForecast ? Weather.dailyForecast.length : 0)

            delegate: Item {
                required property int index

                width: parent.width
                height: 45

                readonly property var itemData: (Weather.dailyForecast && index < Weather.dailyForecast.length) ? Weather.dailyForecast[index] : null


                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Foundations.spacing.xs
                    spacing: Foundations.spacing.xs

                    // Day of week
                    Text.BodyS {
                        Layout.preferredWidth: 65
                        Layout.alignment: Qt.AlignVCenter
                        color: Foundations.palette.base05
                        text: {
                            if (!itemData || !itemData.date) return "";
                            const date = new Date(itemData.date);
                            const today = new Date();
                            if (date.toDateString() === today.toDateString()) {
                                return "Today";
                            }
                            const tomorrow = new Date();
                            tomorrow.setDate(tomorrow.getDate() + 1);
                            if (date.toDateString() === tomorrow.toDateString()) {
                                return "Tomorrow";
                            }
                            return date.toLocaleDateString('en-US', { weekday: 'short' });
                        }
                    }

                    // Weather icon and condition
                    Row {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: Foundations.spacing.xs

                        Icons.MaterialFontIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            color: Foundations.palette.base05
                            font.pointSize: Foundations.font.size.m
                            text: (itemData && itemData.icon) || "help"
                            visible: itemData && itemData.icon !== undefined
                        }

                        Text.BodyS {
                            anchors.verticalCenter: parent.verticalCenter
                            color: Foundations.palette.base05
                            text: {
                                if (!itemData || itemData.weatherCode === undefined) return "";
                                const code = itemData.weatherCode;
                                if (code === 0) return "Clear";
                                if (code <= 3) return "Cloudy";
                                if (code >= 45 && code <= 48) return "Foggy";
                                if (code >= 51 && code <= 67) return "Rainy";
                                if (code >= 71 && code <= 86) return "Snowy";
                                if (code >= 95) return "Stormy";
                                return "Unknown";
                            }
                        }
                    }

                    // Spacer
                    Item {
                        Layout.fillWidth: true
                    }

                    // Temperature range
                    Row {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: Foundations.spacing.m

                        // Min temp
                        Text.BodyS {
                            color: Foundations.palette.base05
                            font.family: Foundations.font.family.mono
                            text: (itemData && itemData.minTemp !== undefined ? itemData.minTemp : "--") + "°"
                        }

                        // Temperature bar
                        Rectangle {
                            width: 40
                            height: 3
                            anchors.verticalCenter: parent.verticalCenter
                            color: Foundations.palette.base03
                            radius: 2

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                x: parent.width * 0.2
                                width: parent.width * 0.6
                                height: parent.height
                                color: {
                                    if (!itemData || itemData.maxTemp === undefined || itemData.minTemp === undefined) {
                                        return Foundations.palette.base03;
                                    }
                                    const avg = (itemData.maxTemp + itemData.minTemp) / 2;
                                    if (avg > 25) return Foundations.palette.base08;
                                    if (avg > 18) return Foundations.palette.base09;
                                    if (avg > 10) return Foundations.palette.base0B;
                                    return Foundations.palette.base0D;
                                }
                                radius: 2
                            }
                        }

                        // Max temp
                        Text.BodyS {
                            color: Foundations.palette.base07
                            font.family: Foundations.font.family.mono
                            text: (itemData && itemData.maxTemp !== undefined ? itemData.maxTemp : "--") + "°"
                        }
                    }
                }
            }
        }
    }

    // Last updated
    Text.BodyS {
        anchors.horizontalCenter: parent.horizontalCenter
        color: Foundations.palette.base04
        font.italic: true
        text: Weather.isLoading ? "Updating..." : "Click to refresh"
        opacity: 0.7

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Weather.refresh()
        }
    }

    component DetailCard: Item {
        required property string icon
        required property string label
        required property string value

        width: (parent.width - parent.columnSpacing * 2) / 3
        height: 55

        Column {
            anchors.centerIn: parent
            spacing: 2

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4

                Icons.MaterialFontIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    color: Foundations.palette.base05
                    font.pointSize: Foundations.font.size.s
                    text: parent.parent.parent.icon
                }

                Text.BodyS {
                    anchors.verticalCenter: parent.verticalCenter
                    color: Foundations.palette.base07
                    font.family: Foundations.font.family.mono
                    text: parent.parent.parent.value
                }
            }

            Text.BodyS {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Foundations.palette.base05
                font.pointSize: 9
                text: parent.parent.label
            }
        }
    }
}