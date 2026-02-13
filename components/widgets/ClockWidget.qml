import QtQuick

Text {
    property string timeText: ""
    property real fontSize: 14

    text: timeText
    color: "white"
    font.pixelSize: fontSize
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
