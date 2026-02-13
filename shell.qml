import Quickshell
import Quickshell.Io
import "./modules/bar" as Bar
import "./modules/launcher" as Launcher
import "./modules/notifications" as Notifications
import "./modules/bluetooth" as BluetoothModule
import "./modules/networks" as NetworksModule
import "./modules/clipse" as ClipseModule
import "./modules/battery" as BatteryModule
import "./modules/calendar" as CalendarModule
import "./modules/settings" as SettingsModule
import "./services"

ShellRoot {
    id: root

    // Theme storage - loads settings on startup
    ThemeStorage {
        id: themeStorage
    }

    // Bluetooth module (needs to be before bar)
    BluetoothModule.Wrapper {
        id: bluetoothModule
    }

    // Networks module (needs to be before bar)
    NetworksModule.Wrapper {
        id: networksModule
    }

    // Battery module (needs to be before bar)
    BatteryModule.Wrapper {
        id: batteryModule
    }

    // Calendar module (needs to be before bar)
    CalendarModule.Wrapper {
        id: calendarModule
    }

    // Modules
    Bar.BarWrapper {
        id: barModule
        bluetoothModule: bluetoothModule
        networksModule: networksModule
        batteryModule: batteryModule
        calendarModule: calendarModule
    }

    Launcher.Wrapper {
        id: launcherModule
        visible: false
    }

    Notifications.Wrapper {
        id: notificationModule
    }

    ClipseModule.Wrapper {
        id: clipseModule
    }

    // Settings module
    SettingsModule.Wrapper {
        id: settingsModule
    }

    // IPC Handler for launcher toggle
    IpcHandler {
        target: "launcher"
        function toggle(): void {
            launcherModule.visible = !launcherModule.visible;
        }
    }

    // IPC Handler for clipse toggle
    IpcHandler {
        target: "clipse"
        function toggle(): void {
            clipseModule.toggle();
        }
    }

    // IPC Handler for settings toggle
    IpcHandler {
        target: "settings"
        function toggle(): void {
            settingsModule.toggle();
        }
    }
}
