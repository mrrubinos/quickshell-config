import qs.modules.launcher
import qs.services.search
import Quickshell
import QtQuick

Search {
    id: root

    required property string prefix
    required property var bindList

    function search(search: string): list<var> {
        return query(search);
    }

    function transformSearch(search: string): string {
        return search.slice(prefix.length);
    }

    key: "haystack"
    list: variants.instances

    Variants {
        id: variants

        model: root.bindList

        delegate: LauncherItemModel {
            required property var modelData

            readonly property string haystack: `${name} ${subtitle}`

            fontIcon: ({
                    gesturebind: "swipe",
                    mousebind: "mouse",
                    axisbind: "mouse",
                    switchbind: "toggle_on"
                })[modelData.kind] ?? "keyboard"
            isAction: true
            name: [modelData.mods, modelData.key].filter(part => part && part !== "NONE").join("+")
            subtitle: [modelData.mode === "default" ? "" : `${modelData.mode} mode:`, modelData.action, modelData.args].filter(part => part).join(" ")

            onActivate: function () {
                return true;
            }
        }
    }
}
