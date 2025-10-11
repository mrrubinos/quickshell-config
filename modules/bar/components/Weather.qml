pragma ComponentBehavior: Bound

import qs.services
import qs.ds.text as Text
import qs.ds.icons as Icons
import qs.ds
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.ds.animations

Rectangle {
    id: root

    property color colour: Foundations.palette.base05
    property int margin: Foundations.spacing.s
    property int spacingItems: Foundations.spacing.xs

    clip: true
    color: Foundations.palette.base02
    implicitWidth: weatherLayout.implicitWidth + margin * 2
    implicitHeight: height
    radius: Foundations.radius.all

    Behavior on implicitWidth {
        BasicNumberAnimation {
            duration: Foundations.duration.standard
        }
    }


    RowLayout {
        id: weatherLayout

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: root.spacingItems

        // Weather icon
        Icons.MaterialFontIcon {
            id: weatherIcon

            color: {
                if (Weather.isLoading) return Foundations.palette.base03;
                if (Weather.errorMessage) return Foundations.palette.base08;

                // Color based on weather condition - only alert for extreme temps
                const temp = Weather.temperature;
                if (temp > 35) return Foundations.palette.base08; // Extreme heat - red alert
                if (temp <= 0) return Foundations.palette.base0D; // Freezing - blue alert
                return Foundations.palette.base05; // Normal color for everything else
            }
            font.pointSize: Foundations.font.size.m
            text: {
                if (Weather.isLoading) return "refresh";
                if (Weather.errorMessage) return "error";
                return Weather.icon;
            }

            Behavior on color {
                BasicColorAnimation {
                    duration: Foundations.duration.standard
                }
            }

            // Loading animation
            RotationAnimator {
                target: weatherIcon
                running: Weather.isLoading
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 2000
            }
        }

        // Temperature display
        Text.BodyM {
            id: temperatureText

            color: weatherIcon.color
            font.family: Foundations.font.family.mono
            text: {
                if (Weather.isLoading) return "...";
                if (Weather.errorMessage) return "ERR";
                return Math.round(Weather.temperature) + "°C";
            }

            Behavior on color {
                BasicColorAnimation {
                    duration: Foundations.duration.standard
                }
            }
        }

        // Condition text (optional, only shown when there's enough space)
        Text.BodyM {
            id: conditionText

            color: weatherIcon.color
            font.family: Foundations.font.family.sans
            text: {
                if (Weather.isLoading) return "";
                if (Weather.errorMessage) return "Error";
                return Weather.condition;
            }
            visible: Weather.condition && !Weather.isLoading && !Weather.errorMessage

            Behavior on color {
                BasicColorAnimation {
                    duration: Foundations.duration.standard
                }
            }
        }
    }

    // Tooltip/hover effect for additional info
    Rectangle {
        id: tooltip

        anchors.bottom: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Foundations.spacing.xs

        width: tooltipText.implicitWidth + Foundations.spacing.s * 2
        height: tooltipText.implicitHeight + Foundations.spacing.xs * 2

        color: Foundations.palette.base01
        radius: Foundations.radius.xs
        border.color: Foundations.palette.base03
        border.width: 1

        visible: false
        opacity: 0

        Text.BodyS {
            id: tooltipText

            anchors.centerIn: parent
            color: Foundations.palette.base05
            text: {
                if (Weather.location) {
                    return Weather.location + " • " + Weather.condition;
                }
                return Weather.condition || "Weather info";
            }
        }

        Behavior on opacity {
            BasicNumberAnimation {
                duration: Foundations.duration.fast
            }
        }
    }

    // Hover states for tooltip
    HoverHandler {
        id: hoverHandler

        onHoveredChanged: {
            if (hovered && !Weather.isLoading && !Weather.errorMessage) {
                tooltip.visible = true;
                tooltip.opacity = 1;
            } else {
                tooltip.opacity = 0;
                tooltip.visible = Qt.binding(() => tooltip.opacity > 0);
            }
        }
    }

}