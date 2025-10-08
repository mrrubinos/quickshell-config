import qs.services
import Quickshell

LauncherInteractiveItem {
    id: root

    required property var config
    readonly property alias input: root.data

    commandPrefix: config?.commandPrefix || ""
    hintIcon: config?.hintIcon || "content_copy"
    hintText: config ? qsTr(config.hintText) : ""
    placeholderText: config ? qsTr(config.placeholderText) : ""
    processCommand: config?.processCommand || []

    modelData: LauncherItemModel {
        function onActivate() {
            const cmd = root.config.activateCommand.replace('{input}', root.input);
            const fullCmd = `${cmd} | wl-copy`;
            Quickshell.execDetached(["sh", "-c", fullCmd]);
            return true;  // Close launcher after action
        }

        fontIcon: root.config.fontIcon
        isAction: true
        name: ""
        subtitle: ""
    }

    onHintClicked: function () {
        if (root.config.openCommand && root.config.openCommand !== "") {
            const cmd = root.config.openCommand.replace('{input}', root.input);
            Quickshell.execDetached(["sh", "-c", cmd]);
        } else {
            // Fallback: copy result to clipboard
            const cmd = root.config.activateCommand.replace('{input}', root.input);
            const fullCmd = `${cmd} | wl-copy`;
            Quickshell.execDetached(["sh", "-c", fullCmd]);
        }
        return true;
    }
    onProcessOutput: function (output) {
        root.isError = output.includes("error: ") || output.includes("warning: ");
    }
}
