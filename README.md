# QuickShell Configuration

Personal QuickShell configuration packaged as a Nix flake.

## Structure

```
.
├── ds/                 # Design system components
├── modules/            # QuickShell modules (bar, dashboard, drawer, etc.)
├── services/           # Services (audio, network, notifications, etc.)
├── shell/              # Shell-specific configurations
├── shell.qml           # Main entry point
└── flake.nix           # Nix flake definition
```

## Usage

### Manual Testing

```bash
# Run the configuration directly
quickshell-config

# Or use the start script (kills existing instance first)
~/.config/niri/start-quickshell

# Or use only the config with
quickshell -p ./
```

### Integration with Niri

The configuration is automatically integrated when using Niri as window manager. To enable auto-start, uncomment the following line in `modules/home/wm/niri/default.nix`:

```kdl
spawn-at-startup "sh" "-c" "~/.config/niri/start-quickshell"
```

## Development

### Testing Changes

1. Make changes to the QML files in this directory
2. Rebuild the system: `quickshell -p ./`


## Flake Structure

This configuration is packaged as a Nix flake with:

- **Package**: `quickshell-config` - The main QuickShell configuration
- **Home Manager Module**: For easy integration with home-manager
- **Overlay**: For system-wide availability

## Dependencies

- QuickShell (from git+https://git.outfoxxed.me/outfoxxed/quickshell)
- Qt6 QML modules
- Nix with flakes enabled

## ToDo
- [ ] DS
  - [ ] Review opacity animations
  - [ ] Propagate margin, radius and opacity to all components
- [ ] Popups
  - [ ] Redistribute the Performance popup information
- [ ] Bar
  - [ ] Handle unknown icons
- [ ] Notifications
  - [ ] Add notificationTime
  - [ ] Don't hide notification when hover
  - [ ] Group notifications
- [ ] Launcher
  - [ ] Define interactive commands with a json

## Troubleshooting

### Process Management

If QuickShell doesn't restart properly:

```bash
# Find QuickShell processes
pgrep -af quickshell

# Kill all QuickShell instances
pgrep -f "/bin/quickshell.*-p" | xargs -r kill
```

## 📚 References
* [Quickshell](https://quickshell.org/docs/v0.2.0/types/Quickshell.Hyprland/HyprlandWorkspace/)
* [Caelestia-shell](https://github.com/caelestia-dots/shell)
* [Shovel-shell](https://github.com/shovelwithasprout/shovel-shell)
