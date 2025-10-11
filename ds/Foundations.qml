pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property list<real> animCurve: [0.2, 0, 0, 1, 1, 1]
    property Duration duration: Duration {
    }
    property Font font: Font {
    }
    property ColorBase16 palette: ColorBase16 {
    }
    property Radius radius: Radius {
    }
    property Spacing spacing: Spacing {
    }

    component ColorBase16: QtObject {
        property color base00: "#000000";  // Black background
        property color base01: "#1a1a1a";  // Dark background
        property color base02: "#2a2a2a";  // Selection background
        property color base03: "#3a3a3a";  // Comments, invisibles
        property color base04: "#4a4a4a";  // Dark foreground
        property color base05: "#d8d8d8";  // Default foreground
        property color base06: "#e8e8e8";  // Light foreground
        property color base07: "#f8f8f8";  // Light background
        property color base08: "#ee2e24";  // Red (critical/urgent)
        property color base09: "#ef9f76";  // Orange (warning)
        property color base0A: "#ffd204";  // Yellow
        property color base0B: "#a6d189";  // Green
        property color base0C: "#81c0c8";  // Cyan
        property color base0D: "#8caaee";  // Blue
        property color base0E: "#a57fbd";  // Purple
        property color base0F: "#efefef";  // White/border color
    }

    component Duration: QtObject {
        property int slow: 600
        property int standard: 400
        property int fast: 200
        property int fastest: 50
        property int zero: 0
    }
    component Font: QtObject {
        property FontFamily family: FontFamily {
        }
        property FontSize size: FontSize {
        }
    }
    component FontFamily: QtObject {
        property string material: "Material Symbols Rounded"
        property string mono: "MesloLGS Nerd Font"
        property string sans: "NotoSans Nerd Font"
    }
    component FontSize: QtObject {
        property int l: 18
        property int m: 14
        property int s: 12
        property int xl: 20
        property int xs: 10
    }
    component Radius: QtObject {
        property int all: 500
        property int l: 20
        property int m: 16
        property int s: 12
        property int xs: 8
    }
    component Spacing: QtObject {
        property int l: 15
        property int m: 12
        property int s: 10
        property int xl: 20
        property int xs: 7
        property int xxs: 5
        property int xxxs: 2
    }
}
