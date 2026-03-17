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
            widgetOrder: BarConfig.widgetOrder,
            hiddenWidgets: BarConfig.hiddenWidgets
        };
        fileView.setText(JSON.stringify(data, null, 2));
    }

    FileView {
        id: fileView
        path: Quickshell.shellDir + "/bar_order.json"

        onLoaded: {
            console.log("BarOrderStorage: File loaded from " + path + ", attempting to parse...");
            try {
                var data = JSON.parse(text());
                var loadedVisible = data.widgetOrder || [];
                var loadedHidden = data.hiddenWidgets || [];
                
                // Reconciliation: Ensure all known widgets are somewhere
                var all = BarConfig.allWidgets;
                var finalVisible = [];
                var finalHidden = [];
                
                // Check visible
                for (var i = 0; i < loadedVisible.length; i++) {
                    if (all.indexOf(loadedVisible[i]) !== -1) {
                        finalVisible.push(loadedVisible[i]);
                    }
                }
                
                // Check hidden
                for (var j = 0; j < loadedHidden.length; j++) {
                    if (all.indexOf(loadedHidden[j]) !== -1) {
                        finalHidden.push(loadedHidden[j]);
                    }
                }
                
                // Add missing ones from default list
                for (var k = 0; k < all.length; k++) {
                    if (finalVisible.indexOf(all[k]) === -1 && finalHidden.indexOf(all[k]) === -1) {
                        finalVisible.push(all[k]);
                    }
                }
                
                BarConfig.widgetOrder = finalVisible;
                BarConfig.hiddenWidgets = finalHidden;
                console.log("BarOrderStorage: Loaded and reconciled widget order:", JSON.stringify(finalVisible), "Hidden:", JSON.stringify(finalHidden));
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
