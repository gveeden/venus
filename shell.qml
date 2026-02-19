import Quickshell
import Quickshell.Io
import QtQuick
import "./modules/bar" as Bar
import "./modules/launcher" as Launcher
import "./modules/notifications" as Notifications
import "./modules/bluetooth" as BluetoothModule
import "./modules/networks" as NetworksModule
import "./modules/clipse" as ClipseModule
import "./modules/battery" as BatteryModule
import "./modules/calendar" as CalendarModule
import "./modules/settings" as SettingsModule
import "./modules/osd" as OsdModule
import "./modules/sound" as SoundModule
import "./services"

ShellRoot {
    id: root

    // Theme storage - using FileView for persistence
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

    // Sound module (needs to be before bar)
    SoundModule.Wrapper {
        id: soundModule
    }

    // Modules
    Bar.BarWrapper {
        id: barModule
        bluetoothModule: bluetoothModule
        networksModule: networksModule
        batteryModule: batteryModule
        calendarModule: calendarModule
        soundModule: soundModule
    }

    Launcher.Wrapper {
        id: launcherModule
        visible: false
    }

    // Connect launcher to notification history
    Connections {
        target: launcherModule
        function onOpenNotificationHistory() {
            notificationModule.openHistory();
        }
    }

    Notifications.Wrapper {
        id: notificationModule
    }

    // IPC Handler for notification history toggle
    IpcHandler {
        target: "notification-history"
        function open(): void {
            notificationModule.openHistory();
        }
    }

    // OSD module for volume/brightness notifications
    OsdModule.Wrapper {
        id: osdModule
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
