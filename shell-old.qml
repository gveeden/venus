import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

ShellRoot {
    id: root

    NotificationServer {
        id: notificationService
    }

    BluetoothManager {
        id: bluetoothManager
    }

    Bar {
        bluetoothManager: bluetoothManager
    }

    NotificationPopup {
        id: notificationWindow
        notificationServer: notificationService
    }

    Launcher {
        id: launcher
        visible: false
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void {
            launcher.visible = !launcher.visible;
        }
    }
}
