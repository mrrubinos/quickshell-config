pragma ComponentBehavior: Bound

import qs.services
import qs.ds.text as Text
import qs.ds.icons as Icons
import qs.ds
import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

Column {
    id: root

    property int margin: Foundations.spacing.l

    readonly property MprisPlayer activePlayer: {
        if (!Mpris.players || Mpris.players.values.length === 0) return null;

        // Find a playing player first
        for (let i = 0; i < Mpris.players.values.length; i++) {
            const player = Mpris.players.values[i];
            if (player && player.playbackState === MprisPlaybackState.Playing) {
                return player;
            }
        }

        // Find a paused player with metadata (indicating active media)
        for (let i = 0; i < Mpris.players.values.length; i++) {
            const player = Mpris.players.values[i];
            if (player && player.playbackState === MprisPlaybackState.Paused &&
                player.metadata && Object.keys(player.metadata).length > 0) {
                return player;
            }
        }

        // If no playing or paused-with-content player, return null
        return null;
    }

    spacing: Foundations.spacing.s
    width: 280

    // Album cover
    Item {
        width: parent.width - Foundations.spacing.l * 2
        height: width  // Square aspect ratio
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            anchors.fill: parent
            color: Foundations.palette.base03
            radius: Foundations.radius.m

            Image {
                id: albumCover
                anchors.fill: parent
                anchors.margins: 2

                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                smooth: true

                source: {
                    if (activePlayer && activePlayer.metadata) {
                        const artUrl = activePlayer.metadata["mpris:artUrl"] || "";
                        return artUrl;
                    }
                    return "";
                }
            }

            // Fallback icon when no cover or failed to load
            Icons.MaterialFontIcon {
                anchors.centerIn: parent
                color: Foundations.palette.base05
                font.pointSize: 48
                text: "album"
                visible: albumCover.status !== Image.Ready || albumCover.source === ""
            }
        }
    }

    // Track title
    Text.HeadingS {
        width: parent.width
        color: Foundations.palette.base07
        horizontalAlignment: Text.AlignHCenter
        text: {
            if (activePlayer && activePlayer.metadata) {
                const metadata = activePlayer.metadata;
                return metadata["xesam:title"] || "Unknown Track";
            }
            return activePlayer ? activePlayer.identity : "No Player";
        }
    }

    // Artist
    Text.BodyM {
        width: parent.width
        color: Foundations.palette.base06
        horizontalAlignment: Text.AlignHCenter
        visible: text !== "" && text !== "No artist metadata"
        text: {
            if (activePlayer && activePlayer.metadata) {
                const metadata = activePlayer.metadata;
                const artist = metadata["xesam:artist"];

                // In QML, arrays appear as objects, so check for length property and indexing
                if (artist && typeof artist === 'object' && artist.length !== undefined && artist.length > 0) {
                    return artist[0] || "Empty first element";
                } else if (typeof artist === 'string') {
                    return artist;
                }
            }
            return "No artist metadata";
        }
    }

    // Album
    Text.BodyS {
        width: parent.width
        color: Foundations.palette.base05
        font.italic: true
        horizontalAlignment: Text.AlignHCenter
        visible: text !== ""
        text: {
            if (activePlayer && activePlayer.metadata) {
                const metadata = activePlayer.metadata;
                return metadata["xesam:album"] || "";
            }
            return "";
        }
    }

    // Player source
    Text.BodyS {
        width: parent.width
        color: Foundations.palette.base04
        font.pointSize: Foundations.font.size.xs
        horizontalAlignment: Text.AlignHCenter
        text: activePlayer ? `via ${activePlayer.identity}` : ""
    }
}