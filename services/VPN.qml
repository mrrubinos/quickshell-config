pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property var vpnTypes: ["vpn", "wireguard"]

    property var connections: []
    property string errorMessage: ""
    property string ipAddress: ""
    property string pendingUuid: ""

    readonly property var activeConnections: connections.filter(c => c.active)
    readonly property bool connected: activeConnections.length > 0
    readonly property bool connecting: pendingUuid !== "" || connections.some(c => c.activating)
    readonly property bool available: connections.length > 0
    readonly property string connectionName: activeConnections.map(c => c.displayName).join(", ")
    readonly property string serviceName: activeConnections.length > 0 ? activeConnections[0].uuid : ""
    readonly property string activeConnection: serviceName

    readonly property string statusIcon: {
        if (!available)
            return "vpn_key_off";
        if (connecting)
            return "sync";
        if (connected)
            return "vpn_key";
        return "vpn_key_off";
    }

    readonly property string statusText: {
        if (!available)
            return "Unavailable";
        if (connecting)
            return "Connecting...";
        if (connected)
            return "Connected";
        return "Disconnected";
    }

    function refreshStatus(): void {
        refreshDebounce.restart();
    }

    function scanConnections(): void {
        refreshDebounce.restart();
    }

    function connectToService(uuid: string): void {
        if (root.pendingUuid !== "" || !uuid)
            return;

        root.errorMessage = "";
        root.pendingUuid = uuid;
        actionProc.command = ["nmcli", "connection", "up", "uuid", uuid];
        actionProc.running = true;
    }

    function disconnectService(uuid: string): void {
        if (root.pendingUuid !== "" || !uuid)
            return;

        root.errorMessage = "";
        root.pendingUuid = uuid;
        actionProc.command = ["nmcli", "connection", "down", "uuid", uuid];
        actionProc.running = true;
    }

    function connect(): void {
        if (root.connected)
            return;

        const target = root.connections[0];
        if (!target) {
            root.errorMessage = "No VPN connection configured";
            return;
        }
        root.connectToService(target.uuid);
    }

    function disconnect(): void {
        const target = root.activeConnections[0];
        if (target)
            root.disconnectService(target.uuid);
    }

    function toggle(): void {
        if (root.connected)
            root.disconnect();
        else
            root.connect();
    }

    // nmcli terse output escapes `:` and `\` inside field values
    function splitTerse(line: string): var {
        const fields = [];
        let current = "";
        for (let i = 0; i < line.length; i++) {
            const ch = line[i];
            if (ch === "\\" && i + 1 < line.length)
                current += line[++i];
            else if (ch === ":") {
                fields.push(current);
                current = "";
            } else
                current += ch;
        }
        fields.push(current);
        return fields;
    }

    onConnectedChanged: {
        if (root.connected)
            ipProc.running = true;
        else
            root.ipAddress = "";
    }

    Component.onCompleted: listProc.running = true

    Timer {
        id: refreshDebounce

        interval: 300

        onTriggered: {
            listProc.running = false;
            listProc.running = true;
        }
    }

    Timer {
        interval: 15000
        repeat: true
        running: true

        onTriggered: root.refreshStatus()
    }

    Process {
        id: listProc

        command: ["nmcli", "-t", "-f", "UUID,TYPE,STATE,NAME", "connection", "show"]

        stdout: StdioCollector {
            onStreamFinished: {
                const found = [];
                for (const line of (text || "").split("\n")) {
                    if (!line)
                        continue;

                    const fields = root.splitTerse(line);
                    if (fields.length < 4)
                        continue;

                    const [uuid, type, state, ...rest] = fields;
                    if (!root.vpnTypes.includes(type))
                        continue;

                    const name = rest.join(":");
                    found.push({
                        uuid: uuid,
                        serviceName: uuid,
                        connectionName: name,
                        displayName: name,
                        type: type,
                        active: state === "activated",
                        activating: state === "activating"
                    });
                }
                root.connections = found;
            }
        }
    }

    Process {
        id: actionProc

        onExited: exitCode => {
            root.pendingUuid = "";
            if (exitCode !== 0 && root.errorMessage === "")
                root.errorMessage = "NetworkManager rejected the VPN request";
            root.refreshStatus();
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const message = (text || "").trim();
                if (message) {
                    root.errorMessage = message.split("\n").pop();
                    console.warn("VPN:", message);
                }
            }
        }
    }

    Process {
        id: monitorProc

        command: ["nmcli", "monitor"]
        running: true

        stdout: SplitParser {
            onRead: root.refreshStatus()
        }
    }

    Process {
        id: ipProc

        command: ["curl", "-s", "--max-time", "3", "https://ifconfig.me"]

        stdout: StdioCollector {
            onStreamFinished: {
                const address = (text || "").trim();
                if (address)
                    root.ipAddress = address;
            }
        }
    }
}
