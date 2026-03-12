import "../../config"
import "../../components/containers"
import Quickshell
import QtQuick
import "." as CalendarPrivate

Scope {
    id: root
    property alias visible: calendarWindow.visible

    // Public functions for timer control
    function startCloseTimer() {
        calendarWindow.startCloseTimer();
    }

    function stopCloseTimer() {
        calendarWindow.stopCloseTimer();
    }

    DropdownWindow {
        id: calendarWindow
        windowWidth: CalendarConfig.windowWidth
        windowHeight: CalendarConfig.windowHeight
        topMargin: CalendarConfig.topMargin
        rightMargin: CalendarConfig.rightMargin
        contentMargins: CalendarConfig.contentMargins
        xMargin: 10
        yMargin: 10

        content: CalendarPrivate.Content {}
    }
}
