import qs.modules.launcher
import qs.services.search
import qs.services
import Quickshell
import QtQuick

Search {
    id: root

    required property string prefix
    required property var commandList


    function search(search: string): list<var> {
        return query(search);
    }

    function transformSearch(search: string): string {
        return search.slice(prefix.length);
    }

    list: variants.instances

    Variants {
        id: variants

        model: commandList

        delegate: LauncherItemModel {
            required property var modelData

            autocompleteText: modelData.commandPrefix
            fontIcon: modelData.fontIcon
            isAction: true
            name: modelData.name
            subtitle: modelData.subtitle
        }
    }
}
