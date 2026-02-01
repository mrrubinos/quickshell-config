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

    Variants {
        id: variants

        // Sort by launch count (descending), then alphabetically
        model: [...DesktopEntries.applications.values]
            .filter(app => !ConfigsJson.excludedDesktops.includes(app.id))
            .sort((a, b) => {
                const countA = LauncherHistory.getLaunchCount(a.id)
                const countB = LauncherHistory.getLaunchCount(b.id)
                if (countA !== countB) {
                    return countB - countA  // Higher count first
                }
                return a.name.localeCompare(b.name)
            })

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
