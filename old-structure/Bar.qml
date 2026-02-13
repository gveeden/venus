import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import "modules"

Scope {
  required property var bluetoothManager
  property string currentTime
  
  Process {
    id: dateProc
    command: ["date", "+%H:%M %a %d %b"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: currentTime = this.text
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 30

      color: "#1e1e2e"

      RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 15

        Text {
          text: "󰂯 " + (bluetoothManager.bluetoothEnabled ? "On" : "Off")
          color: bluetoothManager.bluetoothEnabled ? "#89b4fa" : "#6c7086"
          font.pixelSize: 14

          MouseArea {
            anchors.fill: parent
            onClicked: bluetoothManager.visible = !bluetoothManager.visible
          }
        }

        Text {
          text: UPower.displayDevice ? 
            `Battery: ${Math.round(UPower.displayDevice.percentage * 100)}%` : 
            "No battery"
          color: "white"
          font.pointSize: fontSize
        }

      ClockWidget {
        fontSize: fontSize
        time: currentTime
      }
      }
    }
  }
}
