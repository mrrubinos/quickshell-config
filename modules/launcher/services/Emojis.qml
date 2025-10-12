import qs.modules.launcher
import qs.services
import Quickshell
import QtQuick

QtObject {
    id: root

    required property string prefix
    required property var emojiList

    // Simple substring search - much faster than fuzzy search
    function search(searchText: string): list<var> {
        const query = searchText.slice(prefix.length).toLowerCase();

        // Only search if at least 2 characters are typed
        if (query.length < 2) {
            return [];
        }

        const results = [];
        const maxResults = 50;

        // Simple substring matching - very fast
        for (let i = 0; i < emojiList.length && results.length < maxResults; i++) {
            const item = emojiList[i];
            if (item.keywords.toLowerCase().includes(query)) {
                results.push(variants.instances[i]);
            }
        }

        return results;
    }

    property Variants variants: Variants {
        model: emojiList

        delegate: LauncherItemModel {
            required property var modelData

            readonly property string emoji: modelData.emoji
            readonly property string keywords: modelData.keywords

            function onActivate() {
                // Copy emoji to clipboard and type it
                Quickshell.execDetached(["sh", "-c", `wl-copy "${emoji}" && wtype "${emoji}"`]);
                return true;  // Close launcher
            }

            autocompleteText: ""
            fontIcon: ""
            isAction: true
            name: emoji
            subtitle: keywords
        }
    }
}
