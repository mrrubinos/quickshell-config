pragma Singleton

import ".."
import qs.services
import qs.services.search
import Quickshell
import QtQuick

Search {
    id: root

    function launch(entry: DesktopEntry): void {
        // Record launch for history
        LauncherHistory.recordLaunch(entry.id)

        if (entry.runInTerminal) {
            const terminal = "alacritty";
            const terminalCommand = `${terminal} -e ${entry.command.join(" ")}`;
            Niri.spawn(terminalCommand);
        } else {
            Niri.spawn(entry.command.join(" "));
        }
    }
    function search(search: string): list<var> {
        return query(search);
    }

    list: variants.instances

    // Reference to trigger re-sort when history changes
    property var historyData: LauncherHistory.launchCounts

    Variants {
        id: variants

        // Sort by launch count (descending), then alphabetically
        model: {
            const counts = root.historyData  // Dependency for reactivity
            return [...DesktopEntries.applications.values]
                .filter(app => !ConfigsJson.excludedDesktops.includes(app.id))
                .sort((a, b) => {
                    const countA = counts[a.id] || 0
                    const countB = counts[b.id] || 0
                    if (countA !== countB) {
                        return countB - countA  // Higher count first
                    }
                    return a.name.localeCompare(b.name)
                })
        }

        delegate: LauncherItemModel {
            required property DesktopEntry modelData

            appIcon: modelData?.icon ?? ""
            isApp: true
            name: modelData?.name ?? ""
            originalData: modelData
            subtitle: modelData?.comment || modelData?.genericName || modelData?.name || ""

            onActivate: function () {
                root.launch(originalData);
            }
        }
    }
}
