pragma ComponentBehavior: Bound

import qs.services
import qs.ds.text as Text
import qs.ds.icons as Icons
import qs.ds
import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import qs.ds.animations
import qs.ds.buttons

Rectangle {
    id: root

    property color colour: Foundations.palette.base05
    property int margin: Foundations.spacing.s
    property int spacingItems: Foundations.spacing.xs
    property int iconSize: Foundations.font.size.m

    // Get the active player - prioritize playing, then paused, then first available
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

    clip: true
    color: Foundations.palette.base02
    implicitHeight: height
    implicitWidth: activePlayer !== null ? mainLayout.implicitWidth + margin * 2 : 0
    radius: Foundations.radius.all
    visible: activePlayer !== null

    Behavior on implicitWidth {
        BasicNumberAnimation {
            duration: Foundations.duration.standard
        }
    }

    RowLayout {
        id: mainLayout

        anchors.centerIn: parent
        spacing: root.spacingItems

        // Previous button
        Rectangle {
            Layout.preferredHeight: root.height
            Layout.preferredWidth: root.height
            color: "transparent"
            radius: Foundations.radius.s
            visible: activePlayer && activePlayer.canGoPrevious

            InteractiveArea {
                function onClicked(): void {
                    if (activePlayer) activePlayer.previous();
                }
                radius: parent.radius
            }

            Icons.MaterialFontIcon {
                anchors.centerIn: parent
                color: root.colour
                font.pointSize: root.iconSize
                text: "skip_previous"
            }
        }

        // Play/Pause button
        Rectangle {
            Layout.preferredHeight: root.height
            Layout.preferredWidth: root.height
            color: "transparent"
            radius: Foundations.radius.s
            visible: activePlayer

            InteractiveArea {
                function onClicked(): void {
                    if (!activePlayer) return;
                    if (activePlayer.playbackState === MprisPlaybackState.Playing) {
                        if (activePlayer.canPause) activePlayer.pause();
                    } else {
                        if (activePlayer.canPlay) activePlayer.play();
                    }
                }
                radius: parent.radius
            }

            Icons.MaterialFontIcon {
                anchors.centerIn: parent
                color: root.colour
                font.pointSize: root.iconSize
                text: {
                    if (activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing) {
                        return "pause";
                    } else {
                        return "play_arrow";
                    }
                }
            }
        }

        // Next button
        Rectangle {
            Layout.preferredHeight: root.height
            Layout.preferredWidth: root.height
            color: "transparent"
            radius: Foundations.radius.s
            visible: activePlayer && activePlayer.canGoNext

            InteractiveArea {
                function onClicked(): void {
                    if (activePlayer) activePlayer.next();
                }
                radius: parent.radius
            }

            Icons.MaterialFontIcon {
                anchors.centerIn: parent
                color: root.colour
                font.pointSize: root.iconSize
                text: "skip_next"
            }
        }
    }
}