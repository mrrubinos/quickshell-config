pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import qs.ds.buttons as Buttons
import qs.ds.text as Text
import qs.ds.icons as Icons
import qs.ds.animations
import Quickshell
import QtQuick
import QtQuick as QQ
import QtQuick.Layouts

ColumnLayout {
    id: root

    property int margin: Foundations.spacing.xxs

    spacing: margin
    width: Math.max(320, implicitWidth)

    property color statusColor: {
        if (!VPN.available) return Foundations.palette.base08;
        if (VPN.connecting) return Foundations.palette.base0A;
        if (VPN.connected) return Foundations.palette.base0B;
        return Foundations.palette.base02;
    }

    // Header section
    RowLayout {
        Layout.fillWidth: true
        Layout.rightMargin: root.margin
        Layout.topMargin: root.margin
        spacing: Foundations.spacing.s

        // VPN icon with status indication
        Rectangle {
            Layout.preferredHeight: 32
            Layout.preferredWidth: 32
            color: root.statusColor
            radius: Foundations.radius.m

            Behavior on color {
                BasicColorAnimation {
                }
            }

            // Subtle pulsing animation for connecting state
            SequentialAnimation on opacity {
                running: VPN.connecting
                loops: Animation.Infinite
                BasicNumberAnimation { from: 1.0; to: 0.4; duration: Foundations.duration.slow }
                BasicNumberAnimation { from: 0.4; to: 1.0; duration: Foundations.duration.slow }
            }

            Icons.MaterialFontIcon {
                anchors.centerIn: parent
                color: Foundations.palette.base00
                font.pointSize: Foundations.font.size.l
                text: VPN.statusIcon
            }

            // Small progress dot indicator
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: -2
                anchors.topMargin: -2
                width: 8
                height: 8
                radius: 4
                color: Foundations.palette.base09
                visible: VPN.connecting

                SequentialAnimation on scale {
                    running: VPN.connecting
                    loops: Animation.Infinite
                    BasicNumberAnimation { from: 1.0; to: 1.4; duration: Foundations.duration.standard }
                    BasicNumberAnimation { from: 1.4; to: 1.0; duration: Foundations.duration.standard }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text.HeadingS {
                text: qsTr("VPN Connection")
            }
        }

        Item {
            Layout.fillWidth: true
        }

        // Connection toggle switch
        Switch {
            checked: VPN.connected
            enabled: VPN.available && !VPN.connecting
            opacity: VPN.available ? 1.0 : 0.5

            onToggled: VPN.toggle()

            // Custom colors for VPN state
            activeColor: VPN.connecting ? Foundations.palette.base09 : Foundations.palette.base05
            inactiveColor: Foundations.palette.base03
        }
    }

    // Connection details section (shown when connected)
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: detailsLayout.implicitHeight + Foundations.spacing.m * 2
        Layout.rightMargin: root.margin

        color: Foundations.palette.base01
        radius: Foundations.radius.m
        border.color: Foundations.palette.base03
        border.width: 1
        visible: VPN.connected
        opacity: VPN.connected ? 1.0 : 0.0

        Behavior on opacity {
            BasicNumberAnimation {
                duration: Foundations.duration.standard
            }
        }

        ColumnLayout {
            id: detailsLayout

            anchors.fill: parent
            anchors.margins: Foundations.spacing.m
            spacing: Foundations.spacing.s

            Text.BodyS {
                color: Foundations.palette.base04
                text: qsTr("Connection Details")
                font.weight: Font.Medium
            }

            // Connection name
            DetailRow {
                icon: "vpn_key"
                label: qsTr("Profile")
                value: VPN.connectionName
            }

            // External IP address
            DetailRow {
                icon: "public"
                label: qsTr("External IP")
                value: VPN.ipAddress || qsTr("Fetching...")
                loading: VPN.connected && !VPN.ipAddress
            }
        }
    }

    // Error message section
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: errorText.implicitHeight + Foundations.spacing.s * 2
        Layout.rightMargin: root.margin

        color: Foundations.palette.base08 + "20" // Semi-transparent red
        radius: Foundations.radius.s
        border.color: Foundations.palette.base08
        border.width: 1
        visible: VPN.errorMessage !== ""

        RowLayout {
            anchors.fill: parent
            anchors.margins: Foundations.spacing.s
            spacing: Foundations.spacing.s

            Icons.MaterialFontIcon {
                color: Foundations.palette.base08
                font.pointSize: Foundations.font.size.m
                text: "error"
            }

            Text.BodyS {
                id: errorText
                Layout.fillWidth: true
                color: Foundations.palette.base08
                text: VPN.errorMessage || ""
                wrapMode: QQ.Text.WordWrap
            }
        }
    }

    // Action buttons
    RowLayout {
        Layout.fillWidth: true
        Layout.rightMargin: root.margin
        Layout.topMargin: root.margin
        spacing: Foundations.spacing.s

        Buttons.Button {
            enabled: VPN.available
            leftIcon: "refresh"
            text: qsTr("Refresh")

            onClicked: VPN.refreshStatus()
        }
    }

    // Component for detail rows
    component DetailRow: RowLayout {
        required property string icon
        required property string label
        required property string value
        property bool loading: false

        Layout.fillWidth: true
        spacing: Foundations.spacing.s

        Icons.MaterialFontIcon {
            color: Foundations.palette.base04
            font.pointSize: Foundations.font.size.s
            text: parent.icon
        }

        Text.BodyS {
            color: Foundations.palette.base04
            text: parent.label + ":"
        }

        Item {
            Layout.fillWidth: true
        }

        Text.BodyS {
            color: Foundations.palette.base05
            font.family: parent.value.match(/^\d+\.\d+\.\d+\.\d+$/) ? Foundations.font.family.mono : Foundations.font.family.sans
            text: parent.value

            // Loading animation for dynamic values
            SequentialAnimation on opacity {
                running: parent.parent.loading || false
                loops: Animation.Infinite
                BasicNumberAnimation { from: 1.0; to: 0.5; duration: Foundations.duration.slow }
                BasicNumberAnimation { from: 0.5; to: 1.0; duration: Foundations.duration.slow }
            }
        }
    }
}