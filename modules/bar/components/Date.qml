pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import qs.ds.text as Text
import QtQuick

Rectangle {
    id: root

    signal clicked()

    property int margin: Foundations.spacing.s

    clip: true
    color: Foundations.palette.base02
    implicitWidth: dateText.implicitWidth + margin * 2
    implicitHeight: height
    radius: Foundations.radius.all

    Text.BodyM {
        id: dateText

        anchors.centerIn: parent
        font.family: Foundations.font.family.mono
        text: Time.format("ddd dd MMM  HH:mm")
        interactive: true

        onClicked: root.clicked()
    }
}
