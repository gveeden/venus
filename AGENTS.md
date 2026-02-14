# Quickshell Venus Agent Guide

Quickshell desktop shell for Hyprland.

## Build & Test Commands

```bash
# Check QML syntax
qmlscene -l shell.qml

# View logs (do NOT kill quickshell)
quickshell --config ~/.config/quickshell/venus log

# Restart quickshell after changes
quickshell --config ~/.config/quickshell/venus restart
```

## Architecture Overview

| Directory | Purpose | Singleton? |
|-----------|---------|------------|
| `config/` | Theme/settings | Yes |
| `services/` | System APIs (Time, Bluetooth, etc.) | Yes |
| `components/` | **Reusable UI building blocks** | No |
| `modules/[name]/` | Feature modules (bar, launcher) | No |

**Key Files:**
- `shell.qml` - Entry point, composes modules only
- `qmldir` - Register all singletons here
- `modules/[name]/Wrapper.qml` - Window wrapper
- `modules/[name]/Content.qml` - Module content/logic

## Code Style

### Naming Conventions
- **Files:** PascalCase (`Bar.qml`, `ClockWidget.qml`)
- **Properties:** camelCase (`backgroundColor`, `isEnabled`)
- **IDs:** lowercase descriptive (`root`, `content`, `button`)
- **Functions:** camelCase with return type (`function format(fmt: string): string`)
- **Signals:** past tense (`clicked`, `changed`)
- **Booleans:** prefix with `is`/`has`/`should` (`isVisible`, `hasError`)

### Import Order
```qml
// 1. Quickshell imports
import Quickshell
import Quickshell.Io

// 2. Qt imports
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// 3. Local singletons (via qmldir)
import venus
import venus.services
import venus.config

// 4. Relative imports
import "../../config"
import "../../services"
```

### Singleton Pattern
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

## Component Guidelines (CRITICAL)

**Always prefer creating reusable components!**

### When to Create a Component
- UI element used in 2+ places → `components/`
- Module-specific UI element → `modules/[name]/components/`
- Generic control (button, slider) → `components/controls/`
- Composite widget (clock, battery) → `components/widgets/`

### Component Best Practices
```qml
// Good: Configurable via properties
Rectangle {
    id: root
    property alias text: label.text
    property color bgColor: Appearance.colors.surface
    
    color: bgColor
    radius: Appearance.rounding.small
    
    Text {
        id: label
        anchors.centerIn: parent
    }
}

// Bad: Hard-coded values, not reusable
Rectangle {
    color: "#ff0000"  // Hard-coded!
    width: 100        // Fixed size!
}
```

### Property Aliases
Always expose inner element properties via aliases:
```qml
StyledRect {
    id: root
    property alias icon: iconLabel.text
    property alias iconColor: iconLabel.color
    
    MaterialIcon {
        id: iconLabel
    }
}
```

## Module Pattern

```qml
// modules/feature/Wrapper.qml
import venus.config
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

### Service Usage
```qml
// In services/Time.qml
readonly property string timeStr: Qt.formatDateTime(currentDate, "hh:mm")

// In component
Text {
    text: Time.timeStr
}
```

## Decision Tree

1. Configuration value? → `config/`
2. System API integration? → `services/`
3. Reusable UI component? → `components/`
4. Major feature with window? → `modules/[name]/`
5. Module-specific component? → `modules/[name]/components/`

## Agent Notes

1. **Always register singletons** in `qmldir` file
2. **Use readonly** for config properties that shouldn't change
3. **Prefer composition** over inheritance
4. **Create reusable components** - don't duplicate UI code
5. **Use property aliases** to expose inner element properties
6. **No build step** - QML is interpreted directly
7. **Keep shell.qml minimal** - only compose modules
8. **Wrapper pattern** - separate window management from content
9. **Test frequently** - run `qmlscene -l shell.qml` to check syntax
10. **Use config values** - never hardcode colors/sizes, use `Appearance.*`

## Quick Reference

```qml
// Config access
Appearance.colors.primary
BarConfig.height

// Service access
Time.timeStr
Bluetooth.enabled

// Creating a new singleton service
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    readonly property bool enabled: manager.enabled
    MyManager { id: manager }
}

// Component with proper structure
Rectangle {
    id: root
    property alias text: label.text
    signal clicked()
    
    Text { id: label }
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
```
