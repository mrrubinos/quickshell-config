import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.services
import qs.ds

Item {
    id: root

    property color activeColor: Foundations.palette.base05
    property bool effectsActive: false
    property int horizontalPadding: 8
    property bool hovered: false
    property bool isDestroying: false
    property real masterProgress: 0.0
    readonly property int pillActiveWidth: 28
    readonly property int pillFocusedWidth: 44
    readonly property int pillHeight: 12
    readonly property int pillIdleWidth: 16
    required property var screen
    property real scrollAccumulated: 0
    property int scrollPendingSteps: 0
    property int scrollTargetIndex: -1
    property int spacingBetweenPills: 8
    property ListModel workspaces: ListModel {
    }

    signal workspaceChanged(int workspaceId, color accentColor)

    function focusedPillIndex(): int {
        let active = -1;
        for (let i = 0; i < workspaces.count; i++) {
            const ws = workspaces.get(i);
            if (ws.isFocused)
                return i;
            if (active < 0 && ws.isActive)
                active = i;
        }
        return active;
    }
    function stepScroll() {
        if (root.scrollPendingSteps === 0) {
            root.scrollTargetIndex = -1;
            return;
        }
        const step = root.scrollPendingSteps > 0 ? 1 : -1;
        root.scrollPendingSteps -= step;
        // The model lags behind mmsg, so a queued burst walks from the last
        // requested index instead of the one the pills still show
        const current = root.scrollTargetIndex >= 0 ? root.scrollTargetIndex : root.focusedPillIndex();
        const target = current - step;
        if (current < 0 || target < 0 || target >= workspaces.count) {
            root.scrollPendingSteps = 0;
            root.scrollAccumulated = 0;
            return;
        }
        root.scrollTargetIndex = target;
        Mango.focusWorkspace(workspaces.get(target).id);
        scrollGuard.restart();
    }
    function triggerUnifiedWave() {
        masterAnimation.restart();
    }
    function updateWorkspaceFocus() {
        // Tag numbers repeat per monitor, so the focused id only counts here
        // when the focused workspace belongs to this screen
        const focused = Mango.workspaces?.[Mango.focusedWorkspaceIndex];
        const focusedId = (focused && focused.output === root.screen.name) ? focused.id : -1;
        for (let i = 0; i < workspaces.count; i++) {
            const ws = workspaces.get(i);
            const isFocused = ws.id === focusedId;
            if (ws.isFocused !== isFocused) {
                workspaces.setProperty(i, "isFocused", isFocused);
                if (isFocused) {
                    root.triggerUnifiedWave();
                    root.workspaceChanged(ws.id, root.activeColor);
                }
            }
        }
    }
    function updateWorkspaceList() {
        const newList = Mango.workspaces || [];
        for (let i = 0; i < workspaces.count; i++) {
            const ws = workspaces.get(i);
            if (ws.output !== root.screen.name)
                continue;
            const src = newList.find(w => w.output === root.screen.name && w.id === ws.id);
            const occupied = src ? src.occupied === true : false;
            const isUrgent = src ? src.is_urgent === true : false;
            const isActive = src ? src.is_active === true : false;
            if (ws.occupied !== occupied)
                workspaces.setProperty(i, "occupied", occupied);
            if (ws.isUrgent !== isUrgent)
                workspaces.setProperty(i, "isUrgent", isUrgent);
            if (ws.isActive !== isActive)
                workspaces.setProperty(i, "isActive", isActive);
        }
        updateWorkspaceFocus();
    }

    implicitHeight: 30
    implicitWidth: {
        let total = 0;
        for (let i = 0; i < workspaces.count; i++) {
            const ws = workspaces.get(i);
            if (ws.isFocused)
                total += root.pillFocusedWidth;
            else if (ws.isActive)
                total += root.pillActiveWidth;
            else
                total += root.pillIdleWidth;
        }
        total += Math.max(workspaces.count - 1, 0) * spacingBetweenPills;
        total += horizontalPadding * 2;
        return total;
    }

    Component.onCompleted: {
        for (let i = 0; i < Mango.tagCount; i++) {
            workspaces.append({
                id: i + 1,
                idx: i,
                name: "",
                output: root.screen.name,
                isActive: false,
                isFocused: false,
                isUrgent: false,
                occupied: false
            });
        }
        updateWorkspaceList();
    }
    Component.onDestruction: {
        root.isDestroying = true;
    }

    Connections {
        function onFocusedWorkspaceIndexChanged() {
            updateWorkspaceFocus();
        }
        function onWorkspacesChanged() {
            updateWorkspaceList();
        }

        target: Mango
    }
    SequentialAnimation {
        id: masterAnimation

        PropertyAction {
            property: "effectsActive"
            target: root
            value: true
        }
        NumberAnimation {
            duration: Foundations.duration.slow
            easing.type: Easing.OutQuint
            from: 0.0
            property: "masterProgress"
            target: root
            to: 1.0
        }
        PropertyAction {
            property: "effectsActive"
            target: root
            value: false
        }
        PropertyAction {
            property: "masterProgress"
            target: root
            value: 0.0
        }
    }
    Timer {
        id: scrollGuard

        interval: 80

        onTriggered: root.stepScroll()
    }
    Row {
        id: pillRow

        anchors.centerIn: parent
        spacing: spacingBetweenPills

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

            onWheel: event => {
                root.scrollAccumulated += event.angleDelta.y;
                const steps = Math.trunc(root.scrollAccumulated / 120);
                if (steps === 0)
                    return;
                root.scrollAccumulated -= steps * 120;
                root.scrollPendingSteps += steps;
                if (!scrollGuard.running)
                    root.stepScroll();
            }
        }

        Repeater {
            model: root.workspaces

            Rectangle {
                id: workspacePill

                property bool isHovered: pillMouseArea.containsMouse

                color: {
                    if (model.isFocused)
                        return activeColor;
                    if (model.isUrgent)
                        return Foundations.palette.base08;
                    if (isHovered)
                        return Qt.lighter(Foundations.palette.base04, 1.3);
                    if (model.occupied)
                        return Qt.lighter(Foundations.palette.base04, 1.15);
                    return Foundations.palette.base04;
                }
                height: root.pillHeight
                radius: root.pillHeight / 2
                scale: model.isFocused ? 1.0 : (isHovered ? 0.95 : 0.9)
                width: {
                    if (model.isFocused)
                        return root.pillFocusedWidth;
                    else if (model.isActive)
                        return root.pillActiveWidth;
                    else
                        return root.pillIdleWidth;
                }
                z: 0

                Behavior on color {
                    ColorAnimation {
                        duration: Foundations.duration.fast
                        easing.type: Easing.InOutCubic
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Foundations.duration.standard
                        easing.type: Easing.OutBack
                    }
                }
                Behavior on width {
                    NumberAnimation {
                        duration: Foundations.duration.standard
                        easing.type: Easing.OutBack
                    }
                }

                SequentialAnimation {
                    id: urgentPulse

                    loops: Animation.Infinite
                    running: model.isUrgent && !model.isFocused

                    onStopped: workspacePill.opacity = 1.0

                    NumberAnimation {
                        duration: Foundations.duration.slow
                        easing.type: Easing.InOutQuad
                        property: "opacity"
                        target: workspacePill
                        to: 0.35
                    }
                    NumberAnimation {
                        duration: Foundations.duration.slow
                        easing.type: Easing.InOutQuad
                        property: "opacity"
                        target: workspacePill
                        to: 1.0
                    }
                }

                MouseArea {
                    id: pillMouseArea

                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: model.isFocused ? Qt.ArrowCursor : Qt.PointingHandCursor

                    onClicked: {
                        if (!model.isFocused) {
                            Mango.focusWorkspace(model.id);
                        }
                    }
                }

                // Burst effect overlay for focused pill (smaller outline)
                Rectangle {
                    id: pillBurst

                    anchors.centerIn: parent
                    border.color: root.activeColor
                    border.width: 2 + 6 * (1.0 - root.masterProgress)
                    color: "transparent"
                    height: parent.height + 18 * root.masterProgress
                    opacity: root.effectsActive && model.isFocused ? (1.0 - root.masterProgress) * 0.7 : 0
                    radius: width / 2
                    visible: root.effectsActive && model.isFocused
                    width: parent.width + 18 * root.masterProgress
                    z: 1
                }
            }
        }
    }
}
