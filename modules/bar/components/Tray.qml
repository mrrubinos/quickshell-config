import qs.services
import qs.ds
import qs.ds.icons as Icons
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import qs.ds.animations
import qs.ds.buttons

Rectangle {
    id: root

    readonly property alias items: items

    // ToDo: Reviow (maybe review all margin/paddings)
    property int margin: Foundations.spacing.xxs
    property int spacingItems: Foundations.spacing.xs
    property int buttonSize: height - margin * 2  // Match bar height
    property int iconSize: Foundations.font.size.m  // Match other shell icons

    clip: true
    color: "transparent"
    implicitHeight: height
    implicitWidth: layout.implicitWidth + margin * 2
    radius: Foundations.radius.all
    visible: width > 0 && height > 0 // To avoid warnings about being visible with no size

    Behavior on implicitWidth {
        BasicNumberAnimation {
        }
    }

    Row {
        id: layout

        anchors.centerIn: parent
        spacing: root.spacingItems

        add: Transition {
            BasicNumberAnimation {
                from: 0
                properties: "scale"
                to: 1
            }
        }
        move: Transition {
            BasicNumberAnimation {
                properties: "scale"
                to: 1
            }
            BasicNumberAnimation {
                properties: "x,y"
            }
        }

        Repeater {
            id: items

            model: SystemTray.items

            Rectangle {
                id: trayItem

                required property SystemTrayItem modelData

                color: "transparent"
                height: root.buttonSize
                width: root.buttonSize
                radius: Foundations.radius.l

                InteractiveArea {
                    function onClicked(): void {
                        trayItem.modelData.activate();
                    }
                    function onEntered(): void {
                        trayItem.modelData.secondaryActivate();
                    }

                    radius: parent.radius
                }

                Loader {
                    anchors.centerIn: parent

                    sourceComponent: {
                        const title = trayItem.modelData.title?.toLowerCase() || "";
                        const id = trayItem.modelData.id?.toLowerCase() || "";
                        const iconName = trayItem.modelData.icon?.toLowerCase() || "";

                        // Check if it's Insync
                        if (title.includes("insync") || id.includes("insync") || iconName.includes("insync")) {
                            return googleDriveIcon;
                        }
                        return defaultIcon;
                    }

                    Component {
                        id: googleDriveIcon

                        Icons.MaterialFontIcon {
                            color: Foundations.palette.base05
                            font.pointSize: root.iconSize  // Use consistent icon size
                            text: "add_to_drive"  // Material Design Google Drive icon
                        }
                    }

                    Component {
                        id: defaultIcon

                        IconImage {
                            asynchronous: true
                            height: root.iconSize
                            width: root.iconSize
                            source: {
                                let icon = trayItem.modelData.icon;
                                if (icon.includes("?path=")) {
                                    const [name, path] = icon.split("?path=");
                                    return `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`;
                                }
                                return icon;
                            }
                        }
                    }
                }
            }
        }
    }
}
