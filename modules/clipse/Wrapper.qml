import Quickshell
import Quickshell.Io
import QtQuick

Process {
    id: clipse
    running: false
    command: ["kitty", "--class", "clipse", "-e", "clipse"]

    function toggle() {
        running = !running
    }
}
