import qs.modules.launcher
import qs.services.search
import qs.services
import Quickshell
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

    Variants {
        id: variants

        model: SourceChooser.options

        delegate: LauncherItemModel {
            required property var modelData

            readonly property bool isWindow: modelData.startsWith("Window: ")
            readonly property string label: modelData.replace(/^(Monitor|Window): /, "")

            fontIcon: isWindow ? "web_asset" : "desktop_windows"
            isAction: true
            name: isWindow ? label.replace(/ \([^()]*\)$/, "") : label.split(" ")[0]
            subtitle: isWindow ? qsTr("Window") : label.slice(name.length + 1)

            onActivate: function () {
                SourceChooser.answer(modelData);
                return true;
            }
        }
    }
}
