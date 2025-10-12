import qs.modules.launcher
import qs.services.search
import qs.services
import Quickshell
import Quickshell.Io
import QtQuick

Search {
    id: root

    required property string prefix

    function search(search: string): list<var> {
        return query(search);
    }

    function transformSearch(search: string): string {
        return search.slice(prefix.length);
    }

    list: variants.instances

    Component.onCompleted: {
        loadPasswords();
    }

    function loadPasswords() {
        passwordsProcess.running = true;
    }

    property var passwordList: []

    Process {
        id: passwordsProcess

        command: ["sh", "-c", "find ${PASSWORD_STORE_DIR:-$HOME/.password-store} -name '*.gpg' 2>/dev/null | sed \"s|${PASSWORD_STORE_DIR:-$HOME/.password-store}/||\" | sed 's/\\.gpg$//' | sort"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n').filter(line => line.length > 0);
                root.passwordList = lines;
            }
        }
    }

    Variants {
        id: variants

        model: passwordList

        delegate: LauncherItemModel {
            required property var modelData

            readonly property string passName: modelData

            function onActivate() {
                // Copy password to clipboard
                Quickshell.execDetached(["sh", "-c", `pass show "${passName}" | head -n1 | tr -d '\\n' | wl-copy`]);
                return true;  // Close launcher
            }

            autocompleteText: ""
            fontIcon: "key"
            isAction: true
            name: passName
            subtitle: "Password entry"
        }
    }
}
