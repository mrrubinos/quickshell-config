import qs.services
import QtQuick
import QtQuick.Shapes
import qs.ds.animations
import qs.ds

Rectangle {
    property color bgColour: Foundations.palette.base01
    property color fgColour: Foundations.palette.base05
    property real value

    color: bgColour
    radius: Foundations.radius.xs

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * (value || 0)
        height: parent.height
        color: fgColour
        radius: parent.radius

        Behavior on width {
            BasicNumberAnimation { }
        }
    }
}