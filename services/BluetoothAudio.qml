pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var cards: []

    function cardFor(address: string): var {
        return cards.find(c => c.address === address) ?? null;
    }
    function isHandsFree(key: string): bool {
        return key.startsWith("headset-head-unit");
    }
    function isHighFidelity(key: string): bool {
        return key.startsWith("a2dp-sink");
    }
    function isCodecVariant(key: string, keys: var): bool {
        return keys.some(k => k !== key && key.startsWith(k + "-"));
    }
    function profileIcon(address: string): string {
        const profile = cardFor(address)?.activeProfile ?? "";
        if (isHandsFree(profile))
            return "headset_mic";
        if (isHighFidelity(profile))
            return "headphones";
        return "";
    }
    function parseCards(text: string): var {
        return JSON.parse(text).filter(c => c.name.startsWith("bluez_card.")).map(c => {
            const keys = Object.keys(c.profiles);
            return {
                address: c.properties["api.bluez5.address"] ?? "",
                activeProfile: c.active_profile,
                name: c.name,
                profiles: Object.entries(c.profiles).filter(([key, p]) => key !== "off" && p.available && !isCodecVariant(key, keys)).map(([key, p]) => ({
                            description: p.description.replace(/, codec [^)]*/, ""),
                            key
                        }))
            };
        });
    }
    function refresh(): void {
        listProc.running = false;
        listProc.running = true;
    }
    function setProfile(address: string, key: string): void {
        const card = cardFor(address);
        if (!card)
            return;
        setProc.command = ["pactl", "set-card-profile", card.name, key];
        setProc.running = true;
    }
    function toggle(address: string): string {
        const card = cardFor(address);
        if (!card)
            return "";
        const wantHandsFree = isHighFidelity(card.activeProfile);
        const next = card.profiles.find(p => wantHandsFree ? isHandsFree(p.key) : isHighFidelity(p.key));
        if (!next)
            return "";
        setProfile(address, next.key);
        return next.key;
    }

    Process {
        id: subscribeProc

        command: ["pactl", "subscribe"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                if (line.includes(" on card "))
                    refreshTimer.restart();
            }
        }

        onExited: resubscribeTimer.start()
    }
    Timer {
        id: resubscribeTimer

        interval: 2000

        onTriggered: {
            subscribeProc.running = true;
            root.refresh();
        }
    }
    Timer {
        id: refreshTimer

        interval: 300

        onTriggered: root.refresh()
    }
    Process {
        id: listProc

        command: ["pactl", "--format=json", "list", "cards"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.cards = root.parseCards(text)
        }
    }
    Process {
        id: setProc

    }
}
