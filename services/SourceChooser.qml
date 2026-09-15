pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property string fifo: ""
    property var options: []
    readonly property bool pending: fifo !== ""

    function answer(choice: string): void {
        if (!pending)
            return;
        Quickshell.execDetached(["sh", "-c", '[ -p "$1" ] && printf "%s\\n" "$2" > "$1"', "sh", fifo, choice]);
        fifo = "";
        options = [];
    }
    function request(path: string, lines: string): void {
        answer("");
        options = lines.split("\n").filter(line => line.length > 0);
        fifo = path;
    }
}
