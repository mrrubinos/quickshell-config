pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import qs.services as Services
import qs.ds.buttons as Buttons
import qs.ds.list as Lists
import qs.ds.text as Text
import qs.ds.icons as Icons
import Quickshell
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string connectingToSsid: ""

    // ToDo: Review
    property int margin: Foundations.spacing.xxs

    spacing: margin
    width: Math.max(320, implicitWidth)

    Text.HeadingS {
        Layout.rightMargin: root.margin
        Layout.topMargin: root.margin
        text: qsTr("Network")
    }

    // Connection details section (shown when there are active connections)
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: detailsLayout.implicitHeight + Foundations.spacing.m * 2
        Layout.rightMargin: root.margin
        Layout.bottomMargin: root.margin

        color: Foundations.palette.base01
        radius: Foundations.radius.s
        border.color: Foundations.palette.base03
        border.width: 1
        visible: Network.ethernetIp !== "" || Network.wifiIp !== ""

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

            // Ethernet IP
            DetailRow {
                icon: "lan"
                label: qsTr("Ethernet IP")
                value: Network.ethernetIp
                visible: Network.ethernetIp !== ""
            }

            // WiFi IP
            DetailRow {
                icon: "wifi"
                label: qsTr("WiFi IP")
                value: Network.wifiIp
                visible: Network.wifiIp !== ""
            }
        }
    }

    // No active connections message
    Text.BodyS {
        Layout.fillWidth: true
        Layout.rightMargin: root.margin
        text: qsTr("No active network connections")
        color: Foundations.palette.base03
        horizontalAlignment: Text.AlignHCenter
        visible: Network.ethernetIp === "" && Network.wifiIp === ""
    }
    Toggle {
        Layout.topMargin: root.margin
        checked: Network.wifiEnabled
        label: qsTr("WiFi enabled")

        toggle.onToggled: Network.enableWifi(checked)
    }
    Text.BodyS {
        Layout.rightMargin: root.margin
        Layout.topMargin: root.margin
        disabled: true
        text: qsTr("%1 networks available").arg(Network.networks.length)
    }
    Repeater {
        model: ScriptModel {
            values: [...Network.networks].sort((a, b) => {
                if (a.active !== b.active)
                    return b.active - a.active;
                return b.strength - a.strength;
            }).slice(0, 8)
        }

        Lists.ListItem {
            readonly property bool isConnecting: root.connectingToSsid === modelData.ssid
            required property Network.AccessPoint modelData

            disabled: !Network.wifiEnabled
            leftIcon: Services.IconsService.getNetworkIcon(modelData.strength)
            primaryActionActive: modelData.active
            primaryActionLoading: isConnecting
            primaryFontIcon: modelData.active ? "link_off" : "link"
            secondaryIcon: modelData.isSecure ? "lock" : ""
            selected: modelData.active
            text: modelData.ssid

            onPrimaryActionClicked: {
                if (modelData.active) {
                    Network.disconnectFromNetwork();
                } else {
                    root.connectingToSsid = modelData.ssid;
                    Network.connectToNetwork(modelData.ssid, "");
                }
            }
        }
    }
    Buttons.PrimaryButton {
        Layout.fillWidth: true
        Layout.topMargin: root.margin
        disabled: !Network.wifiEnabled
        leftIcon: "wifi_find"
        loading: Network.scanning
        text: qsTr("Rescan networks")

        onClicked: Network.rescanWifi()
    }

    // Reset connecting state when network changes
    Connections {
        function onActiveChanged(): void {
            if (Network.active && root.connectingToSsid === Network.active.ssid) {
                root.connectingToSsid = "";
            }
        }

        target: Network
    }

    component Toggle: RowLayout {
        property alias checked: toggle.checked
        required property string label
        property alias toggle: toggle

        Layout.fillWidth: true
        Layout.rightMargin: root.margin
        spacing: root.margin

        Text.BodyM {
            Layout.fillWidth: true
            text: parent.label
        }
        Switch {
            id: toggle
        }
    }

    // Component for detail rows
    component DetailRow: RowLayout {
        required property string icon
        required property string label
        required property string value

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
            font.family: Foundations.font.family.mono
            text: parent.value
        }
    }
}
