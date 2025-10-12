import qs.services
import qs.ds
import qs.ds.icons as Icons
import qs.ds.text as DsText
import Quickshell
import QtQuick

Item {
    id: root

    required property real innerHeight
    required property PersistentProperties visibilities

    implicitHeight: innerHeight
    implicitWidth: content.implicitWidth

    Rectangle {
        id: content

        anchors.verticalCenter: parent.verticalCenter
        color: Foundations.palette.base02
        height: root.innerHeight
        implicitWidth: searchIcon.implicitWidth + hintText.implicitWidth + Foundations.spacing.l * 2 + Foundations.spacing.m
        radius: Foundations.radius.all

        Icons.MaterialFontIcon {
            id: searchIcon

            anchors.left: parent.left
            anchors.leftMargin: Foundations.spacing.l
            anchors.verticalCenter: parent.verticalCenter
            color: Foundations.palette.base04
            text: "search"
        }

        DsText.BodyM {
            id: hintText

            anchors.left: searchIcon.right
            anchors.leftMargin: Foundations.spacing.m
            anchors.verticalCenter: parent.verticalCenter
            color: Foundations.palette.base04
            text: "Search"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.visibilities.launcher = !root.visibilities.launcher;
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: Foundations.duration.fast
            }
        }
    }

    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                content.color = Foundations.palette.base03;
            } else {
                content.color = Foundations.palette.base02;
            }
        }
    }
}
