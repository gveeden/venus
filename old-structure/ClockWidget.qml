import QtQuick

Text {
  required property string time
  property real fontSize

  text: time
  color: "white"
  font.pointSize: fontSize
  horizontalAlignment: Text.AlignHCenter
  verticalAlignment: Text.AlignVCenter
}
