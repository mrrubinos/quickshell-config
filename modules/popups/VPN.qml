pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import qs.ds.buttons as Buttons
import qs.ds.list
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
    Text.HeadingS {
        Layout.rightMargin: root.margin
        Layout.topMargin: root.margin
        text: qsTr("VPN Connection")
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

    // Available VPN connections list
    ColumnLayout {
        Layout.fillWidth: true
        Layout.rightMargin: root.margin
        spacing: Foundations.spacing.s
        visible: VPN.connections.length > 0

        Text.BodyS {
            color: Foundations.palette.base04
            text: qsTr("Available Connections")
            font.weight: Font.Medium
        }

        Repeater {
            model: VPN.connections

            ListItem {
                required property var modelData

                readonly property bool isActive: VPN.serviceName === modelData.serviceName && VPN.connected
                readonly property bool isConnecting: VPN.serviceName === modelData.serviceName && VPN.connecting

                Layout.fillWidth: true
                text: modelData.displayName
                leftIcon: "vpn_key"
                selected: VPN.serviceName === modelData.serviceName
                disabled: VPN.connecting
                primaryActionActive: isActive
                primaryActionLoading: isConnecting
                primaryFontIcon: isActive ? "link_off" : "link"

                onPrimaryActionClicked: {
                    if (isActive) {
                        // If this VPN is connected, disconnect it
                        VPN.disconnect();
                    } else {
                        // Connect to this VPN
                        VPN.connectToService(modelData.serviceName);
                    }
                }
            }
        }
    }

    // Error message section
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: errorText.implicitHeight + Foundations.spacing.s * 2
        Layout.rightMargin: root.margin

        color: Foundations.palette.base08
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