# Quickshell my-desktop Agent Guide

Quickshell desktop shell configuration for Hyprland.

## Build & Run Commands

```bash
# Run the shell
quickshell --config ~/.config/quickshell/my-desktop

# Run with hot reload (development)
quickshell --config ~/.config/quickshell/my-desktop --reload

# Check QML syntax
qmlscene -l shell.qml

# Kill running quickshell
killall quickshell
```

## Architecture

**Entry Point**: `shell.qml` - Composes modules, no logic here  
**Modules**: `modules/[name]/` - Features (bar, launcher, etc.)  
**Services**: `services/` - Singleton system integrations (Time, Bluetooth, etc.)  
**Config**: `config/` - Singleton configuration (Appearance, BarConfig, etc.)  
**Components**: `components/` - Reusable UI building blocks

See `ARCHITECTURE_GUIDE.md` for full documentation.

## Code Style

### QML Conventions
- **Files**: PascalCase (`Bar.qml`, `ClockWidget.qml`)
- **Properties**: camelCase (`backgroundColor`, `isEnabled`)
- **IDs**: lowercase descriptive (`root`, `content`, `button`)
- **Functions**: camelCase with return type (`function format(fmt: string): string`)
- **Signals**: past tense (`clicked`, `changed`)

### Import Order
```qml
// 1. Quickshell imports
import Quickshell
import Quickshell.Io

// 2. Qt imports
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// 3. Local modules (via qmldir)
import my-desktop
import my-desktop.services
import my-desktop.config

// 4. Relative imports
import "../../config"
import "../../services"
```

## Naming Conventions

### Files
- `Wrapper.qml` - Window wrapper for modules
- `Content.qml` - Module content/logic
- `[Service].qml` - Service singletons
- `[Config].qml` - Config singletons

### Properties
- Booleans: prefix with `is`/`has`/`should` (`isVisible`, `hasError`)
- Config access: direct singleton reference (`Appearance.colors.primary`)
- Required: mark explicit (`required property ShellScreen screen`)

## Singleton Pattern

```qml
// config/Appearance.qml
pragma Singleton
import QtQuick

Singleton {
    readonly property QtObject colors: QtObject {
        property color background: "#1e1e2e"
        property color primary: "#89b4fa"
    }
}
```

Register in `qmldir`:
```
singleton Appearance config/Appearance.qml
```

## Module Pattern

```qml
// modules/feature/Wrapper.qml
import my-desktop.config
import Quickshell

PanelWindow {
    id: root
    required property ShellScreen screen
    visible: false
    
    Content {
        anchors.fill: parent
    }
}
```

## Common Patterns

### Property Aliases
```qml
StyledRect {
    id: root
    property alias icon: iconLabel.text
    
    MaterialIcon {
        id: iconLabel
    }
}
```

### Conditional Binding
```qml
color: isActive ? Appearance.colors.primary : Appearance.colors.surface
```

### IPC Handler
```qml
IpcHandler {
    target: "launcher"
    function toggle(): void {
        launcherModule.visible = !launcherModule.visible
    }
}
```

## Agent Notes

1. **Always register singletons** in `qmldir` file
2. **Use readonly** for config properties that shouldn't change
3. **Prefer composition** over inheritance for components
4. **Test frequently** - run quickshell to verify changes
5. **Check imports** - relative paths or qmldir singletons
6. **No build step** - QML is interpreted directly
7. **Keep shell.qml minimal** - only compose modules there
8. **Wrapper pattern** - separate window management from content

## Quick Reference

| Directory | Purpose | Singleton? |
|-----------|---------|------------|
| `config/` | Theme, settings | Yes |
| `services/` | System APIs | Yes |
| `modules/` | Features | No |
| `components/` | UI building blocks | No |

## Decision Tree

1. Configuration? → `config/`
2. System integration? → `services/`
3. Reusable UI component? → `components/`
4. Major feature? → `modules/[name]/`
5. Module-specific component? → `modules/[name]/components/`
