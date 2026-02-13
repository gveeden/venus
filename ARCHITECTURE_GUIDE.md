# Quickshell Project Architecture Guide

*Based on the Caelestia shell structure - A reference guide for organizing my-desktop*

---

## Table of Contents

1. [Introduction](#introduction)
2. [Current vs Target Structure](#current-vs-target-structure)
3. [Directory Structure Deep Dive](#directory-structure-deep-dive)
4. [Organization Principles](#organization-principles)
5. [Import System & Aliases](#import-system--aliases)
6. [File Organization Patterns](#file-organization-patterns)
7. [Migration Strategy](#migration-strategy)
8. [Concrete Examples](#concrete-examples)
9. [Best Practices](#best-practices)
10. [Quick Reference](#quick-reference)

---

## Introduction

This guide outlines a scalable architecture pattern for Quickshell projects based on the Caelestia shell. The structure emphasizes:

- **Separation of Concerns**: Clear boundaries between UI components, business logic, and configuration
- **Modularity**: Self-contained feature modules that can be enabled/disabled independently
- **Reusability**: Shared components and utilities accessible across the project
- **Scalability**: Easy to add new features without restructuring existing code
- **Maintainability**: Predictable file locations and consistent patterns

### Philosophy

The Caelestia architecture follows these principles:

1. **Top-level files are minimal** - `shell.qml` should only compose high-level modules
2. **Services are singletons** - System integrations (audio, network, time) are globally accessible
3. **Components are dumb** - UI building blocks don't contain business logic
4. **Modules are smart** - Feature modules contain their own logic, state, and sub-components
5. **Configuration is centralized** - All user-configurable settings live in `config/`

---

## Current vs Target Structure

### Current Structure (my-desktop)

```
my-desktop/
├── shell.qml                    # Entry point - composes top-level modules only
│
├── assets/                      # Static resources
│   ├── images/
│   ├── icons/
│   └── scripts/                 # JS utilities (fuzzy search, etc.)
│
├── components/                  # Reusable UI building blocks
│   ├── StyledText.qml
│   ├── StyledRect.qml
│   ├── controls/                # Interactive components
│   │   ├── IconButton.qml
│   │   ├── StyledSwitch.qml
│   │   └── StyledSlider.qml
│   ├── containers/              # Layout components
│   │   ├── StyledWindow.qml
│   │   └── StyledListView.qml
│   ├── effects/                 # Visual effects
│   │   ├── Elevation.qml
│   │   └── InnerBorder.qml
│   └── widgets/                 # Composite components
│       └── ClockWidget.qml
│
├── config/                      # Configuration singletons
│   ├── Config.qml               # Main config aggregator
│   ├── Appearance.qml           # Theme/appearance settings
│   ├── BarConfig.qml            # Bar-specific config
│   ├── LauncherConfig.qml       # Launcher-specific config
│   └── GeneralConfig.qml        # General settings
│
├── modules/                     # Feature modules (high-level)
│   ├── bar/
│   │   ├── Bar.qml              # Main bar component
│   │   ├── BarWrapper.qml       # Window/positioning wrapper
│   │   ├── components/          # Bar-specific components
│   │   │   ├── Logo.qml
│   │   │   └── StatusIcons.qml
│   │   └── popouts/             # Bar popout menus
│   │       └── VolumePopout.qml
│   ├── launcher/
│   │   ├── Launcher.qml         # Main launcher
│   │   ├── Wrapper.qml          # Window wrapper
│   │   ├── Content.qml          # Launcher content
│   │   └── items/               # Launcher item types
│   │       └── AppItem.qml
│   └── notifications/
│       ├── NotificationPopup.qml
│       ├── Wrapper.qml
│       └── Content.qml
│
├── services/                    # System integration singletons
│   ├── Time.qml                 # Time/clock service
│   ├── Audio.qml                # Audio control
│   ├── Bluetooth.qml            # Bluetooth manager
│   ├── Network.qml              # Network info
│   └── Notifs.qml               # Notification service
│
└── utils/                       # Utility singletons & helpers
    ├── Paths.qml                # Path constants
    ├── Icons.qml                # Icon helpers
    └── scripts/                 # JavaScript utilities
        └── helpers.js
```

---

## Directory Structure Deep Dive

### `shell.qml` - Entry Point

**Purpose**: Compose top-level modules and set up global services

**What goes here:**
- Importing and instantiating top-level modules
- Setting up global shortcuts
- Wiring up module dependencies
- Nothing else!

**Example:**
```qml
import "modules"
import "modules/bar"
import "modules/launcher"
import "modules/notifications"
import Quickshell

ShellRoot {
    // Modules instantiated at root level
    BarWrapper {}
    LauncherWrapper {}
    NotificationWrapper {}
    
    // Global services/shortcuts
    Shortcuts {}
    BatteryMonitor {}
}
```

### `assets/` - Static Resources

**Purpose**: Non-code resources needed by the shell

**What goes here:**
- Images (PNG, SVG, GIF)
- Icons
- Shaders
- Shell scripts
- External executables

**Subdirectories:**
- `images/` - General images
- `icons/` - Icon files
- `shaders/` - GLSL shader files
- `scripts/` - Shell scripts and executables

**Do NOT put here:**
- QML files
- JavaScript modules (those go in `utils/scripts/`)
- Configuration files

### `components/` - Reusable UI Components

**Purpose**: Building blocks used across multiple modules

**What goes here:**
- Styled variants of basic QML types (StyledText, StyledRect)
- Reusable controls (buttons, sliders, switches)
- Layout containers
- Visual effects
- Composite widgets used in multiple places

**Key characteristics:**
- **Stateless or minimal state** - Don't manage application state
- **Highly reusable** - Used by 2+ modules
- **Generic** - Not tied to specific business logic
- **Configurable** - Accept properties for customization

**Subdirectories:**
- `controls/` - Interactive elements (IconButton, StyledSlider, etc.)
- `containers/` - Layout wrappers (StyledWindow, StyledListView)
- `effects/` - Visual effects (Elevation, Blur, OpacityMask)
- `widgets/` - Composite components (ClockWidget, BatteryIndicator)
- `misc/` - Uncategorized helpers (Ref, CustomShortcut)

**Example component:**
```qml
// components/controls/IconButton.qml
import ".."
import qs.config
import QtQuick

StyledRect {
    id: root
    
    property alias icon: label.text
    property bool checked: false
    property int type: IconButton.Filled
    
    // ... styling based on config
    color: Appearance.colors.primary
    radius: Appearance.rounding.small
    
    MaterialIcon {
        id: label
        // ...
    }
    
    MouseArea {
        // ...
    }
}
```

### `config/` - Configuration Singletons

**Purpose**: Centralized, user-configurable settings

**What goes here:**
- Theme settings (colors, fonts, spacing)
- Module-specific configuration
- User preferences
- Feature flags

**Key characteristics:**
- **All are singletons** - One instance per config file
- **Loaded from JSON** - Often backed by a config file on disk
- **Reactive** - Changes propagate automatically
- **Organized by domain** - One file per major concern

**Common files:**
- `Config.qml` - Main config aggregator (imports all others)
- `Appearance.qml` - Theme, colors, fonts, spacing, rounding
- `GeneralConfig.qml` - App paths, battery warnings, idle timeouts
- `[Module]Config.qml` - Per-module settings (BarConfig, LauncherConfig, etc.)

**Example:**
```qml
// config/Appearance.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property QtObject colors: QtObject {
        property color primary: "#6366f1"
        property color background: "#1e1e2e"
        property color surface: "#313244"
    }
    
    readonly property QtObject padding: QtObject {
        property int small: 4
        property int medium: 8
        property int large: 16
    }
    
    readonly property QtObject rounding: QtObject {
        property int small: 4
        property int medium: 8
        property int large: 16
    }
}
```

### `modules/` - Feature Modules

**Purpose**: Self-contained features with their own UI, logic, and state

**What goes here:**
- Major features (bar, launcher, dashboard, notifications, etc.)
- Module-specific components and logic
- Feature state management

**Key characteristics:**
- **Self-contained** - Can be enabled/disabled independently
- **Has its own subdirectory** - `modules/[feature]/`
- **Uses Wrapper pattern** - Often has a Wrapper.qml for window management
- **Can have sub-components** - Module-specific components in `components/` subfolder
- **Imports from services and config** - Uses `qs.services` and `qs.config`

**Common structure within a module:**
```
modules/[feature]/
├── [Feature].qml           # Main component logic
├── Wrapper.qml             # Window/positioning wrapper
├── Content.qml             # Content area
├── Background.qml          # Background/styling
├── components/             # Module-specific components
│   └── FeatureSpecific.qml
└── [subdomain]/            # Sub-features
    └── SubFeature.qml
```

**Example module structure:**
```
modules/bar/
├── Bar.qml                 # Main bar layout/logic
├── BarWrapper.qml          # Window wrapper for bar
├── components/
│   ├── Logo.qml            # Bar-specific logo
│   ├── Clock.qml           # Bar-specific clock
│   ├── StatusIcons.qml     # Status indicators
│   └── workspaces/
│       └── WorkspaceItem.qml
└── popouts/
    ├── Wrapper.qml
    └── VolumePopout.qml
```

**When to create a new module:**
- It's a major, independent feature (e.g., bar, launcher, dashboard)
- It has its own window or top-level UI element
- It has significant logic and state
- It can be enabled/disabled independently

**When NOT to create a module:**
- It's a small UI component (→ use `components/`)
- It's a system integration (→ use `services/`)
- It's just configuration (→ use `config/`)

### `services/` - System Integration Singletons

**Purpose**: Interface with system APIs and external services

**What goes here:**
- System API wrappers (audio, network, Bluetooth)
- Data providers (time, weather, system usage)
- State managers (notifications, media players)

**Key characteristics:**
- **All are singletons** - One instance globally
- **Stateful** - Manage and expose system state
- **Reactive** - Emit signals when state changes
- **No UI** - Pure logic, no visual components
- **Used by modules** - Modules import and use these services

**Common services:**
- `Time.qml` - System time, date formatting
- `Audio.qml` - Volume, audio devices, control
- `Bluetooth.qml` - Bluetooth device management
- `Network.qml` - Network status, connections
- `Notifs.qml` - Notification aggregation
- `Players.qml` - Media player control (MPRIS)
- `SystemUsage.qml` - CPU, memory, disk usage

**Example:**
```qml
// services/Time.qml
pragma Singleton

import qs.config
import Quickshell
import QtQuick

Singleton {
    readonly property date date: clock.date
    readonly property int hours: clock.hours
    readonly property int minutes: clock.minutes
    readonly property int seconds: clock.seconds
    
    readonly property string timeStr: format(
        Config.services.useTwelveHourClock ? "hh:mm:A" : "hh:mm"
    )
    
    function format(fmt: string): string {
        return Qt.formatDateTime(clock.date, fmt)
    }
    
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
```

### `utils/` - Utilities & Helpers

**Purpose**: Helper functions, constants, and shared utilities

**What goes here:**
- Path constants
- Icon helpers
- JavaScript utility modules
- Helper singletons
- Pure functions

**Key characteristics:**
- **Often singletons** - For constants and helpers
- **No UI** - Pure logic
- **No state** - Or minimal state
- **Generic** - Not feature-specific

**Common files:**
- `Paths.qml` - XDG paths, app directories
- `Icons.qml` - Icon name mappings, helpers
- `scripts/` - JavaScript modules (fuzzy search, etc.)

**Example:**
```qml
// utils/Paths.qml
pragma Singleton

import Quickshell

Singleton {
    readonly property string home: Quickshell.env("HOME")
    readonly property string config: Quickshell.env("XDG_CONFIG_HOME") || `${home}/.config`
    readonly property string data: Quickshell.env("XDG_DATA_HOME") || `${home}/.local/share`
    readonly property string cache: Quickshell.env("XDG_CACHE_HOME") || `${home}/.cache`
    
    readonly property string appConfig: `${config}/my-desktop`
    readonly property string appData: `${data}/my-desktop`
    readonly property string appCache: `${cache}/my-desktop`
}
```

---

## Organization Principles

### Decision Tree: Where Does This Code Go?

Use this flowchart to decide where new code belongs:

```
Is it a configuration value?
├─ YES → config/
└─ NO ↓

Is it a static resource (image, script, shader)?
├─ YES → assets/
└─ NO ↓

Does it interface with system APIs or external services?
├─ YES → services/
└─ NO ↓

Is it a pure utility, constant, or helper function?
├─ YES → utils/
└─ NO ↓

Is it a major, independent feature with its own UI?
├─ YES → modules/[feature]/
└─ NO ↓

Is it a reusable UI component used by multiple modules?
├─ YES → components/
└─ NO ↓

Is it specific to one module?
└─ YES → modules/[module]/components/
```

### Components vs Modules

**Use `components/` when:**
- It's a generic UI building block
- It's used by 2+ modules
- It has minimal or no business logic
- It's highly configurable via properties
- Examples: buttons, sliders, text styles, containers

**Use `modules/[feature]/` when:**
- It's a major feature with its own window/UI
- It has significant business logic
- It manages its own state
- It can be enabled/disabled independently
- Examples: bar, launcher, notifications, dashboard

**Use `modules/[feature]/components/` when:**
- It's a UI component specific to one module
- It's only used within that module
- Examples: bar workspace indicator, launcher app item

### Services vs Utils

**Use `services/` when:**
- It interfaces with system APIs (D-Bus, sockets, etc.)
- It manages stateful data (audio state, network info)
- It provides reactive data to modules
- Examples: Audio, Network, Bluetooth, Time

**Use `utils/` when:**
- It's a pure function or constant
- It has no or minimal state
- It's a helper/convenience function
- Examples: Paths, icon mappings, formatters

### Singleton Pattern Usage

**Should be singleton:**
- All `config/` files
- All `services/` files
- Most `utils/` files
- Global state managers

**Should NOT be singleton:**
- `components/` - These are instantiated multiple times
- Most `modules/` files - Each module instance can have its own state
- Anything instantiated more than once

**How to make a singleton:**
```qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // ... your properties and methods
}
```

---

## Import System & Aliases

### The `qs.*` Import Pattern

Caelestia uses a custom import aliasing system for clean, short imports:

```qml
import qs.components           // → components/
import qs.components.controls  // → components/controls/
import qs.config               // → config/
import qs.services             // → services/
import qs.utils                // → utils/
import qs.modules.bar          // → modules/bar/
```

### Setting Up Import Aliases

To use this pattern, you need to configure Quickshell's import paths. This is typically done via a build system (CMake) or environment variables.

**Option 1: Using qmldir files (Recommended)**

Create `qmldir` files in each directory to define the module:

```
# components/qmldir
module qs.components
```

```
# services/qmldir
module qs.services
```

**Option 2: Environment Variable**

Set `QML_IMPORT_PATH` or `QML2_IMPORT_PATH`:

```bash
export QML2_IMPORT_PATH=$HOME/.config/quickshell/my-desktop
```

**Option 3: Relative Imports (Simple, No Setup)**

If you don't want to set up aliases, use relative imports:

```qml
import "../components"
import "../services"
import "../../config"
```

### Import Best Practices

1. **Use specific imports** - Import only what you need
   ```qml
   import qs.components.controls  // Good
   import qs.components           // Less specific
   ```

2. **Group imports logically**
   ```qml
   // External QML modules
   import Quickshell
   import QtQuick
   import QtQuick.Layouts
   
   // Project components
   import qs.components
   import qs.components.controls
   
   // Project services/config
   import qs.services
   import qs.config
   
   // Relative imports
   import "components"
   ```

3. **Use relative imports within modules**
   ```qml
   // In modules/bar/Bar.qml
   import "components"      // → modules/bar/components/
   import "popouts"         // → modules/bar/popouts/
   ```

---

## File Organization Patterns

### Pattern 1: Module Wrapper Pattern

Many modules use a Wrapper → Content separation:

```
modules/[feature]/
├── Wrapper.qml      # Window management, positioning, animations
├── Content.qml      # Actual content/logic
└── Background.qml   # Visual styling (optional)
```

**Why?**
- **Separation of concerns** - Window logic separate from content logic
- **Reusability** - Background/wrapper can be swapped
- **Cleaner code** - Each file has a single responsibility

**Example:**

```qml
// modules/launcher/Wrapper.qml
import qs.components
import qs.config
import Quickshell
import QtQuick

Item {
    id: root
    
    required property ShellScreen screen
    property int contentHeight
    
    readonly property bool shouldBeActive: Config.launcher.enabled
    
    visible: height > 0
    implicitWidth: content.implicitWidth
    
    Background {
        anchors.fill: parent
    }
    
    Content {
        id: content
        anchors.fill: parent
        onHeightChanged: root.contentHeight = height
    }
}
```

```qml
// modules/launcher/Content.qml
import qs.components
import qs.services
import qs.config
import QtQuick

Item {
    // Actual launcher logic and UI
    ListView {
        model: apps
        delegate: AppItem { }
    }
}
```

### Pattern 2: Config Aggregation Pattern

The main `Config.qml` aggregates all config files:

```qml
// config/Config.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Expose sub-configs as properties
    property alias appearance: appearanceConfig
    property alias general: generalConfig
    property alias bar: barConfig
    property alias launcher: launcherConfig
    
    // Load actual config files
    AppearanceConfig { id: appearanceConfig }
    GeneralConfig { id: generalConfig }
    BarConfig { id: barConfig }
    LauncherConfig { id: launcherConfig }
    
    // Optional: Save function
    function save(): void {
        // Serialize to JSON and save
    }
}
```

**Usage:**
```qml
import qs.config

Item {
    color: Config.appearance.colors.background
    width: Config.bar.width
}
```

### Pattern 3: Service Singleton Pattern

Services expose system state as properties:

```qml
// services/Audio.qml
pragma Singleton

import qs.config
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root
    
    // Read-only state
    readonly property real volume: defaultSink?.volume ?? 0.0
    readonly property bool muted: defaultSink?.muted ?? false
    
    // Writable (controlled) state
    property PwNode defaultSink: audioManager.defaultAudioSink
    
    // Methods to control state
    function setVolume(vol: real): void {
        if (defaultSink) {
            defaultSink.volume = Math.max(0.0, Math.min(vol, Config.services.maxVolume))
        }
    }
    
    function toggleMute(): void {
        if (defaultSink) {
            defaultSink.muted = !defaultSink.muted
        }
    }
    
    // Internal implementation
    PwObjectManager {
        id: audioManager
    }
}
```

**Usage in modules:**
```qml
import qs.services

Item {
    Text {
        text: `${Math.round(Audio.volume * 100)}%`
    }
    
    Slider {
        value: Audio.volume
        onValueChanged: Audio.setVolume(value)
    }
}
```

### Pattern 4: Component Composition Pattern

Build complex components from simpler ones:

```qml
// components/controls/IconButton.qml
import ".."
import qs.config
import QtQuick

StyledRect {
    id: root
    
    property alias icon: iconLabel.text
    signal clicked()
    
    color: Appearance.colors.surface
    radius: Appearance.rounding.small
    
    MaterialIcon {
        id: iconLabel
        anchors.centerIn: parent
    }
    
    StateLayer {  // Ripple effect
        id: stateLayer
        anchors.fill: parent
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
```

---

## Migration Strategy

### Phase 1: Set Up Directory Structure

1. **Create directories** (don't move files yet):
   ```bash
   mkdir -p {assets,components/{controls,containers,effects,widgets},config,services,utils}
   mkdir -p modules/{bar,launcher,notifications}
   ```

2. **Keep existing files** in place for now

### Phase 2: Extract Configuration

1. **Identify all hardcoded values** in your components
   - Colors, fonts, spacing, sizes
   - Feature flags, paths, user preferences

2. **Create config files**:
   ```qml
   // config/Appearance.qml
   pragma Singleton
   import QtQuick
   
   QtObject {
       readonly property QtObject colors: QtObject {
           property color background: "#1e1e2e"
           property color surface: "#313244"
           property color primary: "#6366f1"
       }
   }
   ```

3. **Create main Config.qml**:
   ```qml
   // config/Config.qml
   pragma Singleton
   import QtQuick
   
   QtObject {
       property Appearance appearance: Appearance {}
   }
   ```

4. **Replace hardcoded values** with config references:
   ```qml
   // Before:
   color: "#1e1e2e"
   
   // After:
   import qs.config
   color: Config.appearance.colors.background
   ```

### Phase 3: Extract Services

1. **Identify system integrations** in your code
   - Look for: Process, D-Bus, system APIs, timers, etc.

2. **Create service singletons**:
   ```qml
   // services/Time.qml
   pragma Singleton
   import Quickshell
   import QtQuick
   
   QtObject {
       readonly property date currentDate: clock.date
       
       SystemClock { id: clock }
   }
   ```

3. **Move logic from components to services**
   - Components should import and use services
   - Don't duplicate service logic

### Phase 4: Organize Components

1. **Identify reusable components**
   - Used by 2+ modules? → `components/`
   - Used by 1 module? → `modules/[feature]/components/`

2. **Categorize into subdirectories**:
   - `controls/` - Interactive (buttons, sliders)
   - `containers/` - Layout (windows, lists)
   - `effects/` - Visual (shadows, blur)
   - `widgets/` - Composite (clock widget, battery indicator)

3. **Move files** and update imports

### Phase 5: Restructure Modules

1. **For each major feature**, create:
   ```
   modules/[feature]/
   ├── [Feature].qml
   ├── Wrapper.qml (if needed)
   └── components/ (if needed)
   ```

2. **Move feature files** into modules

3. **Update shell.qml** to import from modules

### Phase 6: Clean Up shell.qml

1. **Remove all logic** from shell.qml
2. **Only keep**:
   - Module instantiation
   - Module wiring/dependencies
   - Global shortcuts

---

## Concrete Examples

### Example 1: Migrating BluetoothManager.qml

**Current:**
```qml
// BluetoothManager.qml (in root)
import Quickshell
import Quickshell.Services.Bluetooth

QtObject {
    id: root
    
    property BluetoothManager manager: BluetoothManager {}
    property bool enabled: manager.enabled
    
    function toggleBluetooth() {
        manager.enabled = !manager.enabled
    }
}
```

**After migration to services:**
```qml
// services/Bluetooth.qml
pragma Singleton

import Quickshell
import Quickshell.Services.Bluetooth
import QtQuick

Singleton {
    id: root
    
    readonly property bool enabled: manager.enabled
    readonly property var devices: manager.devices
    
    function toggle(): void {
        manager.enabled = !manager.enabled
    }
    
    function connect(device): void {
        device.connect()
    }
    
    BluetoothManager { id: manager }
}
```

**Usage in modules:**
```qml
// modules/bar/components/BluetoothIndicator.qml
import qs.services
import qs.components.controls

IconButton {
    icon: Bluetooth.enabled ? "bluetooth" : "bluetooth_disabled"
    checked: Bluetooth.enabled
    onClicked: Bluetooth.toggle()
}
```

### Example 2: Migrating Launcher.qml

**Current:**
```qml
// Launcher.qml (in root)
import Quickshell
import Quickshell.Services.Applications
import QtQuick

Window {
    id: launcher
    
    visible: false
    width: 600
    height: 400
    
    ListView {
        anchors.fill: parent
        model: ApplicationListModel {}
        delegate: Text {
            text: modelData.name
        }
    }
}
```

**After migration to modules:**
```qml
// modules/launcher/Wrapper.qml
import qs.components.containers
import qs.config
import Quickshell
import QtQuick

StyledWindow {
    id: root
    
    visible: false
    width: Config.launcher.width
    height: Config.launcher.height
    
    Background {}
    
    Content {
        anchors.fill: parent
    }
}
```

```qml
// modules/launcher/Content.qml
import qs.components
import qs.config
import Quickshell.Services.Applications
import QtQuick
import QtQuick.Layouts

Item {
    ListView {
        anchors.fill: parent
        model: ApplicationListModel {}
        delegate: AppItem {
            appName: modelData.name
            appIcon: modelData.icon
        }
    }
}
```

```qml
// modules/launcher/components/AppItem.qml
import qs.components
import qs.components.controls
import QtQuick

StyledRect {
    property string appName
    property string appIcon
    
    height: 48
    
    Row {
        Image { source: appIcon }
        StyledText { text: appName }
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: modelData.launch()
    }
}
```

**Updated shell.qml:**
```qml
// shell.qml
import "modules/launcher"
import Quickshell

ShellRoot {
    LauncherWrapper {
        id: launcher
        visible: false
    }
    
    IpcHandler {
        target: "launcher"
        function toggle(): void {
            launcher.visible = !launcher.visible
        }
    }
}
```

### Example 3: Migrating Bar.qml with Configuration

**Current:**
```qml
// Bar.qml (in root)
import Quickshell
import QtQuick

PanelWindow {
    width: 50
    height: screen.height
    anchors {
        left: true
    }
    
    Column {
        // Hard-coded styling
        spacing: 8
        padding: 12
        
        Text {
            text: "Logo"
            color: "#ffffff"
            font.pixelSize: 16
        }
    }
}
```

**Step 1: Create config**
```qml
// config/BarConfig.qml
pragma Singleton
import QtQuick

QtObject {
    readonly property int width: 50
    readonly property int spacing: 8
    readonly property int padding: 12
}
```

```qml
// config/Appearance.qml
pragma Singleton
import QtQuick

QtObject {
    readonly property QtObject colors: QtObject {
        property color text: "#ffffff"
        property color background: "#1e1e2e"
    }
    
    readonly property QtObject font: QtObject {
        property int size: 16
        property string family: "Inter"
    }
}
```

```qml
// config/Config.qml
pragma Singleton
import QtQuick

QtObject {
    property BarConfig bar: BarConfig {}
    property Appearance appearance: Appearance {}
}
```

**Step 2: Create module**
```qml
// modules/bar/BarWrapper.qml
import qs.config
import Quickshell
import QtQuick

PanelWindow {
    id: root
    
    required property ShellScreen screen
    
    width: Config.bar.width
    height: screen.height
    anchors.left: true
    
    Bar {
        anchors.fill: parent
    }
}
```

```qml
// modules/bar/Bar.qml
import qs.components
import qs.config
import "components"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: Config.bar.spacing
    
    Logo {
        Layout.alignment: Qt.AlignHCenter
    }
    
    // ... other bar items
}
```

```qml
// modules/bar/components/Logo.qml
import qs.components
import qs.config
import QtQuick

StyledText {
    text: "Logo"
    color: Config.appearance.colors.text
    font.pixelSize: Config.appearance.font.size
}
```

**Step 3: Update shell.qml**
```qml
// shell.qml
import "modules/bar"
import Quickshell

ShellRoot {
    Repeater {
        model: Quickshell.screens
        BarWrapper {
            screen: modelData
        }
    }
}
```

### Example 4: Creating Reusable Components

**Extract ClockWidget from modules to components:**

**Current:**
```qml
// modules/ClockWidget.qml
import Quickshell
import QtQuick

Item {
    width: 100
    height: 50
    
    Column {
        Text {
            text: Qt.formatTime(new Date(), "hh:mm")
            font.pixelSize: 24
            color: "#ffffff"
        }
        Text {
            text: Qt.formatDate(new Date(), "ddd, MMM d")
            font.pixelSize: 12
            color: "#aaaaaa"
        }
    }
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: parent.children[0].children[0].text = Qt.formatTime(new Date(), "hh:mm")
    }
}
```

**After migration:**

1. **Create Time service:**
```qml
// services/Time.qml
pragma Singleton

import qs.config
import Quickshell
import QtQuick

Singleton {
    readonly property date currentDate: clock.date
    
    function formatTime(format: string): string {
        return Qt.formatTime(currentDate, format)
    }
    
    function formatDate(format: string): string {
        return Qt.formatDate(currentDate, format)
    }
    
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
```

2. **Create reusable widget:**
```qml
// components/widgets/ClockWidget.qml
import qs.components
import qs.config
import qs.services
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: Config.appearance.spacing.small
    
    StyledText {
        text: Time.formatTime(timeFormat)
        font.pixelSize: Config.appearance.font.size * 1.5
        color: Config.appearance.colors.text
    }
    
    StyledText {
        text: Time.formatDate(dateFormat)
        font.pixelSize: Config.appearance.font.size * 0.75
        color: Config.appearance.colors.textSecondary
    }
    
    property string timeFormat: "hh:mm"
    property string dateFormat: "ddd, MMM d"
}
```

3. **Use in multiple places:**
```qml
// modules/bar/components/Clock.qml
import qs.components.widgets

ClockWidget {
    timeFormat: "hh:mm"
    dateFormat: "MMM d"
}
```

```qml
// modules/dashboard/components/Clock.qml
import qs.components.widgets

ClockWidget {
    timeFormat: "hh:mm:ss A"
    dateFormat: "EEEE, MMMM d, yyyy"
}
```

---

## Best Practices

### Naming Conventions

**Files:**
- PascalCase for QML files: `IconButton.qml`, `BarWrapper.qml`
- camelCase for JS files: `helpers.js`, `fuzzysort.js`
- lowercase for directories: `components/`, `services/`
- Suffix with purpose: `BarConfig.qml`, `BarWrapper.qml`, `BarContent.qml`

**Properties:**
- camelCase: `backgroundColor`, `isEnabled`
- Prefix booleans with `is`/`has`/`should`: `isVisible`, `hasError`, `shouldUpdate`
- Use `readonly` for derived properties
- Required properties: `required property ShellScreen screen`

**Functions:**
- camelCase: `toggleVisibility()`, `formatTime()`
- Verbs for actions: `toggle()`, `show()`, `hide()`, `update()`
- Return type annotations: `function format(fmt: string): string`

**Signals:**
- Past tense: `clicked`, `changed`, `opened`
- Or event-like: `aboutToShow`, `visibilityChanged`

### Component Design

**Keep components simple:**
```qml
// Good: Simple, configurable
StyledRect {
    property color bgColor: Config.appearance.colors.surface
    property real cornerRadius: Config.appearance.rounding.medium
    
    color: bgColor
    radius: cornerRadius
}

// Bad: Too many built-in assumptions
StyledRect {
    color: isActive ? "#ff0000" : "#00ff00"  // Hard-coded colors
    radius: parent.width > 100 ? 12 : 8      // Logic in component
}
```

**Use property aliases:**
```qml
StyledRect {
    id: root
    
    // Expose inner component properties
    property alias icon: iconLabel.text
    property alias iconColor: iconLabel.color
    
    MaterialIcon {
        id: iconLabel
    }
}
```

**Prefer composition over inheritance:**
```qml
// Good: Compose from smaller parts
IconButton {
    id: button
    icon: "volume_up"
}

// Less good: Inherit and override
IconButton {
    // Overriding lots of parent properties
}
```

### Configuration Management

**Use readonly for constants:**
```qml
readonly property color backgroundColor: "#1e1e2e"
```

**Group related settings:**
```qml
readonly property QtObject colors: QtObject {
    property color background: "#1e1e2e"
    property color surface: "#313244"
    property color primary: "#6366f1"
}
```

**Provide sensible defaults:**
```qml
property int width: 50                    // Simple default
property string terminal: Quickshell.env("TERMINAL") || "kitty"  // Fallback
```

### Service Design

**Keep services focused:**
```qml
// Good: Focused on audio
Singleton {
    readonly property real volume: /* ... */
    function setVolume(vol: real): void { }
}

// Bad: Kitchen sink
Singleton {
    property real volume
    property string wallpaper
    property bool darkMode
    // Too many unrelated things
}
```

**Use signals for events:**
```qml
Singleton {
    signal volumeChanged(real newVolume)
    signal deviceConnected(string deviceName)
    
    function setVolume(vol: real): void {
        // ...
        volumeChanged(vol)
    }
}
```

**Lazy initialization:**
```qml
Singleton {
    property var expensiveData: null
    
    function getData() {
        if (!expensiveData) {
            expensiveData = loadExpensiveData()
        }
        return expensiveData
    }
}
```

### Module Organization

**One responsibility per file:**
```qml
// Good:
// BarWrapper.qml - window management
// Bar.qml - layout
// Logo.qml - logo component

// Bad:
// Bar.qml - everything in one file (500+ lines)
```

**Minimize dependencies:**
```qml
// Good: Only import what you need
import qs.services.Audio
import qs.config.Appearance

// Bad: Import everything
import qs.services
import qs.config
```

**Use Loaders for optional/heavy components:**
```qml
Loader {
    active: Config.dashboard.enabled
    sourceComponent: Dashboard {}
}
```

### Performance Tips

**Use Loaders for conditional UI:**
```qml
Loader {
    active: visible
    sourceComponent: HeavyComponent {}
}
```

**Bind to specific properties:**
```qml
// Good: Specific binding
text: Time.currentDate.getHours()

// Less good: Entire object
property var time: Time.currentDate
text: time.getHours()  // Might re-evaluate more often
```

**Avoid creating objects in loops:**
```qml
// Good: Reuse delegate
ListView {
    delegate: AppItem {}
    reuseItems: true
}

// Bad: Create new objects
Repeater {
    model: 1000
    Rectangle { }  // Creates 1000 rectangles
}
```

---

## Quick Reference

### Directory Cheat Sheet

| Directory | Purpose | Files | Singletons? |
|-----------|---------|-------|-------------|
| `assets/` | Static resources | Images, scripts, shaders | No |
| `components/` | Reusable UI | Buttons, text, containers | No |
| `components/controls/` | Interactive UI | Buttons, sliders, switches | No |
| `components/containers/` | Layouts | Windows, lists, views | No |
| `components/effects/` | Visual effects | Shadows, blur, masks | No |
| `components/widgets/` | Composite UI | Clock, battery, etc. | No |
| `config/` | Configuration | Theme, settings, flags | Yes |
| `modules/` | Features | Bar, launcher, etc. | No |
| `services/` | System integration | Audio, network, time | Yes |
| `utils/` | Helpers | Paths, formatters | Usually |

### Import Patterns

```qml
// External modules
import Quickshell
import QtQuick
import QtQuick.Layouts

// Project modules (with aliases)
import qs.components
import qs.components.controls
import qs.config
import qs.services
import qs.utils

// Relative imports (within module)
import "components"
import "../shared"
```

### Common File Patterns

**Config Singleton:**
```qml
pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#1e1e2e"
}
```

**Service Singleton:**
```qml
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    readonly property var data: manager.data
    
    function doSomething(): void { }
    
    SomeManager { id: manager }
}
```

**Module Wrapper:**
```qml
import qs.config
import Quickshell

PanelWindow {
    required property ShellScreen screen
    
    Content { anchors.fill: parent }
}
```

**Reusable Component:**
```qml
import qs.config
import QtQuick

Rectangle {
    property alias text: label.text
    
    color: Config.appearance.colors.surface
    
    Text {
        id: label
        color: Config.appearance.colors.text
    }
}
```

### Decision Checklist

**Before creating a new file, ask:**

- [ ] Is this configuration? → `config/`
- [ ] Is this a system integration? → `services/`
- [ ] Is this a utility/helper? → `utils/`
- [ ] Is this a reusable UI component? → `components/`
- [ ] Is this a major feature? → `modules/[feature]/`
- [ ] Is this specific to one module? → `modules/[feature]/components/`

**Before making something a singleton:**

- [ ] Is it stateful data shared across the app?
- [ ] Is it configuration?
- [ ] Is it a system integration?
- [ ] Will there only ever be ONE instance?

If all answers are "yes", make it a singleton. Otherwise, don't.

### Migration Checklist

Phase 1: Structure
- [ ] Create directory structure
- [ ] Set up import aliases (optional)

Phase 2: Configuration
- [ ] Extract all hardcoded values to config files
- [ ] Create `Config.qml` aggregator
- [ ] Update components to use config

Phase 3: Services
- [ ] Identify system integrations
- [ ] Create service singletons
- [ ] Move logic from components to services

Phase 4: Components
- [ ] Identify reusable components
- [ ] Categorize into subdirectories
- [ ] Move and update imports

Phase 5: Modules
- [ ] Create module directories
- [ ] Apply Wrapper pattern where appropriate
- [ ] Move feature files into modules

Phase 6: Cleanup
- [ ] Simplify shell.qml
- [ ] Remove unused files
- [ ] Test everything

---

## Conclusion

This architecture provides:

- **Scalability** - Easy to add new features
- **Maintainability** - Predictable file locations
- **Reusability** - Components shared across modules
- **Clarity** - Clear separation of concerns
- **Flexibility** - Modules can be enabled/disabled

### When to Migrate

**Do migrate when:**
- Adding a new major feature
- Refactoring existing code
- Code is becoming hard to navigate
- You have time for careful refactoring

**Don't migrate when:**
- In the middle of adding a feature
- Under time pressure
- Current structure is working fine

### Getting Started

1. **Start small** - Migrate one module at a time
2. **Begin with config** - Extract configuration first
3. **Test frequently** - Ensure everything works after each change
4. **Use this guide** - Reference decision trees and patterns

### Additional Resources

- [Quickshell Documentation](https://quickshell.outfoxxed.me)
- [Caelestia Shell GitHub](https://github.com/caelestia-dots/shell)
- [QML Best Practices](https://doc.qt.io/qt-6/qml-codingconventions.html)

---

## Appendix: Real Migration Experience (2026-02-12)

### What Worked Well

1. **Config extraction was straightforward** - Creating `Appearance.qml` with all colors/spacing first made subsequent steps easier
2. **Service singletons eliminated prop drilling** - No more passing `bluetoothManager` and `notificationServer` through components
3. **Wrapper pattern simplified code** - Separating window management from content made both cleaner
4. **Component extraction improved maintainability** - `DeviceList` and `DeviceItem` are much cleaner than the monolithic `BluetoothManager.qml`
5. **Relative imports worked well** - Using `import "../../config"` pattern was simple and effective

### Challenges Encountered

1. **Import path updates** - Had to update imports in all files to use relative paths (e.g., `../../config` instead of root-relative)
2. **Property name consistency** - Had to carefully track config property paths (e.g., `Config.appearance.colors.text` → `Appearance.colors.text`)
3. **Module naming ambiguity** - `modules/launcher/Wrapper.qml` had to be imported carefully to avoid conflicts
4. **Bluetooth reference in Bar** - Bar's bluetooth toggle needed to reference `bluetoothModule.visible` from shell scope

### Time Investment

- **Planning**: 30 minutes (analyzing structure, reading guide)
- **Directory setup**: 5 minutes
- **Config extraction**: 20 minutes (creating all config files)
- **Service creation**: 15 minutes (Time, Bluetooth, Notifs singletons)
- **Component migration**: 10 minutes (ClockWidget)
- **Module creation**: 90 minutes (Bar, Launcher, Notifications, Bluetooth with components)
- **Import fixes**: 30 minutes (updating all imports and references)
- **Testing & cleanup**: 20 minutes
- **Total**: ~3.5 hours for complete migration

### Actual File Count

**Before**: 7 QML files at root/modules level
**After**: 22 QML files in organized structure
- 6 config files
- 3 service files
- 1 widget component
- 10 module files (4 wrappers, 4 content, 2 bluetooth components)
- 1 shell.qml
- 1 qmldir

### Benefits Realized

1. **Easier to navigate** - Know exactly where to find things
2. **Simpler to modify themes** - Change one color in `Appearance.qml`, affects everywhere
3. **Better code reuse** - `ClockWidget` and `DeviceItem` are properly reusable now
4. **More testable** - Each module can be tested independently
5. **Easier to extend** - Adding a new module is clear and straightforward

### Recommendations for Future Migrations

1. **Do it in one session** - Easier to track changes and fix imports
2. **Backup first** - Keep old files in `old-structure/` until tested
3. **Extract config early** - Makes everything else reference consistent values
4. **Use qmldir** - Helps with import organization
5. **Test incrementally** - Check each module as you create it
6. **Document as you go** - Write migration notes immediately

### Next Additions to Consider

Based on the Caelestia patterns, consider adding:

1. **utils/Paths.qml** - XDG path constants
2. **utils/Icons.qml** - Icon name mappings
3. **components/controls/** - Reusable buttons, sliders, switches
4. **components/effects/** - Elevation, shadows, blur effects
5. **modules/dashboard/** - System info dashboard
6. **modules/workspaces/** - Workspace switcher for Hyprland

### Lessons for ARCHITECTURE_GUIDE.md Improvements

1. The guide could benefit from more concrete "before/after" examples
2. Import path patterns should be shown more explicitly
3. The qmldir section could be expanded with actual examples
4. Migration time estimates would be helpful
5. Common pitfalls section would prevent issues

---

*This guide is a living document. Update it as your architecture evolves and you discover new patterns.*

*Last updated: 2026-02-12 - Added real migration experience from my-desktop restructure*
