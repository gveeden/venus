import QtQuick
import Quickshell
import Quickshell.Io
import "../config"

Item {
    id: root

    function save() {
        var path = Quickshell.shellDir + "/bar_order.json";
        console.log("BarOrderStorage: Saving widget order to " + path);
        var data = {
            widgetOrder: BarConfig.widgetOrder
        };
        fileView.setText(JSON.stringify(data, null, 2));
        fileView.write();
    }

    FileView {
        id: fileView
        path: Quickshell.shellDir + "/bar_order.json"

        onLoaded: {
            console.log("BarOrderStorage: File loaded from " + path + ", attempting to parse...");
            try {
                var data = JSON.parse(text());
                if (data.widgetOrder && data.widgetOrder.length > 0) {
                    BarConfig.widgetOrder = data.widgetOrder;
                    console.log("BarOrderStorage: Loaded widget order:", JSON.stringify(data.widgetOrder));
                }
            } catch (e) {
                console.error("BarOrderStorage: Failed to parse widget order:", e);
            }
        }

        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                console.log("BarOrderStorage: No saved widget order found at " + path);
                // Don't save immediately, wait for first change
            } else {
                console.error("BarOrderStorage: Failed to load widget order from " + path + ": " + FileViewError.toString(err));
            }
        }
    }

    Component.onCompleted: {
        console.log("BarOrderStorage: Initialized with path: " + fileView.path);
    }
}
