pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import qs.services as Services
import qs.ds.list as Lists
import qs.ds.text as Text
import qs.ds as Ds
import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    id: root

    required property Item wrapper
    
    property int margin: Foundations.spacing.xxs
    property int itemSpacing: Foundations.spacing.m

    spacing: Foundations.spacing.s
    width: Math.max(320, implicitWidth)

    Text.HeadingS {
        Layout.rightMargin: root.margin
        Layout.topMargin: root.margin
        text: qsTr("Bluetooth %1").arg(BluetoothAdapterState.toString(Bluetooth.defaultAdapter?.state).toLowerCase())
    }
    Toggle {
        checked: Bluetooth.defaultAdapter?.enabled ?? false
        label: qsTr("Enabled")

        toggle.onToggled: {
            const adapter = Bluetooth.defaultAdapter;
            if (adapter)
                adapter.enabled = checked;
        }
    }
    Toggle {
        checked: Bluetooth.defaultAdapter?.discovering ?? false
        label: qsTr("Discovering")

        toggle.onToggled: {
            const adapter = Bluetooth.defaultAdapter;
            if (adapter)
                adapter.discovering = checked;
        }
    }
    Text.BodyS {
        Layout.rightMargin: root.margin
        Layout.topMargin: root.margin
        disabled: true
        text: {
            const devices = Bluetooth.devices.values;
            let available = qsTr("%1 device%2 available").arg(devices.length).arg(devices.length === 1 ? "" : "s");
            const connected = devices.filter(d => d.connected).length;
            if (connected > 0)
                available += qsTr(" (%1 connected)").arg(connected);
            return available;
        }
    }
    Repeater {
        model: ScriptModel {
            values: [...Bluetooth.devices.values].sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired)).slice(0, 5)
        }

        ColumnLayout {
            id: device

            readonly property var card: Services.BluetoothAudio.cardFor(modelData.address)
            readonly property bool loading: modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting
            required property BluetoothDevice modelData

            Layout.fillWidth: true
            spacing: 0

            Lists.ListItem {
                leftIcon: Services.IconsService.getBluetoothIcon(device.modelData.icon)
                primaryActionActive: device.modelData.connected
                primaryActionLoading: device.loading
                primaryFontIcon: device.modelData.connected ? "link_off" : "link"
                secondaryActionActive: !device.modelData.bonded
                secondaryFontIcon: device.modelData.bonded ? "delete" : ""
                selected: device.modelData.connected
                text: device.modelData.name

                onPrimaryActionClicked: {
                    device.modelData.connected = !device.modelData.connected;
                }
                onSecondaryActionClicked: {
                    device.modelData.forget();
                }
            }
            ButtonGroup {
                id: profiles

            }
            Repeater {
                model: device.modelData.connected ? (device.card?.profiles ?? []) : []

                Lists.ListItem {
                    required property var modelData

                    Layout.leftMargin: Foundations.spacing.m
                    buttonGroup: profiles
                    selected: device.card?.activeProfile === modelData.key
                    text: modelData.description

                    onClicked: Services.BluetoothAudio.setProfile(device.modelData.address, modelData.key)
                }
            }
        }
    }

    component Toggle: RowLayout {
        property alias checked: toggle.checked
        required property string label
        property alias toggle: toggle

        Layout.fillWidth: true
        Layout.rightMargin: root.margin
        spacing: root.itemSpacing

        Text.BodyM {
            Layout.fillWidth: true
            text: parent.label
        }
        Ds.Switch {
            id: toggle
        }
    }
}
