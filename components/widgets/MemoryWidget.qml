import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../services"

// Memory usage widget for the bar.
// Shows a donut chart and the percentage.
Item {
    id: root
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    property real fontSize: Appearance.font.small
    property real donutSize: 16
    property real strokeWidth: 3

    RowLayout {
        id: layout
        spacing: Appearance.spacing.small
        anchors.centerIn: parent

        Canvas {
            id: donut
            implicitWidth: root.donutSize
            implicitHeight: root.donutSize

            property real percentage: Memory.memoryUsagePercent
            onPercentageChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.antialias = Canvas.HighAntialiasing;

                var x = width / 2;
                var y = height / 2;
                var radius = (width - root.strokeWidth) / 2;

                if (radius <= 0)
                    return;

                // Background circle
                ctx.beginPath();
                ctx.arc(x, y, radius, 0, 2 * Math.PI);
                ctx.lineWidth = root.strokeWidth;
                ctx.strokeStyle = Appearance.colors.surfaceHighlight;
                ctx.stroke();

                // Progress arc
                var startAngle = -0.5 * Math.PI;
                var spanAngle = (percentage / 100) * 2 * Math.PI;

                if (spanAngle > 0) {
                    ctx.beginPath();
                    ctx.arc(x, y, radius, startAngle, startAngle + spanAngle);
                    ctx.lineWidth = root.strokeWidth;
                    ctx.lineCap = "round";

                    if (percentage > 90)
                        ctx.strokeStyle = Appearance.colors.secondary;
                    else if (percentage > 70)
                        ctx.strokeStyle = Appearance.colors.secondaryContainer;
                    else
                        ctx.strokeStyle = Appearance.colors.primary;

                    ctx.stroke();
                }
            }
        }
    }
}
