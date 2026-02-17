import "../../config"
import "./components"
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: Appearance.spacing.large

    property string search: ""
    signal requestClose

    function focusSearch() {
        input.forceActiveFocus();
    }

    function clearSearch() {
        root.search = "";
        input.text = "";
        currentCurrencyResult = null;
        currencyQueryPending = false;
    }

    // Calculator function
    function calculate(expr) {
        if (!expr || expr.trim() === "")
            return null;

        expr = expr.replace(/\s/g, "");

        const hasOperator = /[\+\-\*\/\^\%\(\)]/.test(expr);
        const isValidChars = /^[\d\+\-\*\/\^\%\(\)\.\s]+$/.test(expr);

        if (!isValidChars || (!hasOperator && !expr.includes("(")))
            return null;

        try {
            let sanitized = expr.replace(/\^/g, "**");
            const result = new Function("return " + sanitized)();

            if (typeof result === "number" && isFinite(result)) {
                return parseFloat(result.toFixed(6));
            }
        } catch (e) {}
        return null;
    }

    property var currentCalcResult: null
    property var currentCurrencyResult: null
    property bool currencyQueryPending: false

    Process {
        id: browserProcess
        running: false
    }

    function openBrowser(url) {
        browserProcess.command = ["xdg-open", url];
        browserProcess.running = true;
    }

    // Track running windows
    property var runningWindows: []
    property bool windowsLoaded: false

    // Process for copying to clipboard
    Process {
        id: clipboardProcess
        command: ["wl-copy"]
        running: false
    }

    function copyToClipboard(text) {
        clipboardProcess.command = ["wl-copy", text];
        clipboardProcess.running = true;
    }

    // Load running windows on startup
    Component.onCompleted: {
        refreshWindows();
    }

    function refreshWindows() {
        let winProcess = Qt.createQmlObject('
            import Quickshell.Io
            Process {
                command: ["hyprctl", "clients", "-j"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            let clients = JSON.parse(text)
                            let windows = []
                            for (let i = 0; i < clients.length; i++) {
                                let client = clients[i]
                                windows.push({
                                    address: client.address,
                                    class: client.class || "",
                                    title: client.title || "",
                                    initialClass: client.initialClass || "",
                                    workspace: client.workspace ? client.workspace.name : ""
                                })
                            }
                            root.runningWindows = windows
                            root.windowsLoaded = true
                        } catch (e) {
                            root.runningWindows = []
                            root.windowsLoaded = true
                        }
                    }
                }
            }
        ', root);
        winProcess.running = true;
    }

    TextField {
        id: input
        Layout.fillWidth: true
        Layout.preferredHeight: LauncherConfig.searchBoxHeight
        placeholderText: "What do you need?"
        placeholderTextColor: Appearance.colors.textSecondary
        focus: true
        font.pointSize: Appearance.font.large
        text: root.search

        background: Rectangle {
            color: Appearance.colors.surfaceHighlight
            radius: Appearance.rounding.medium
        }
        color: Appearance.colors.text

        onTextChanged: {
            if (text !== root.search) {
                root.search = text;
                root.currentCalcResult = root.calculate(text);

                // Check for currency conversion
                let currencyQuery = CurrencyConverter.parseQuery(text);
                if (currencyQuery && !currencyQueryPending) {
                    currencyQueryPending = true;
                    CurrencyConverter.fetchRate(currencyQuery, function (result) {
                        root.currentCurrencyResult = result;
                        root.currencyQueryPending = false;
                    });
                } else if (!currencyQuery) {
                    root.currentCurrencyResult = null;
                }

                // Clear selection when search changes
                appList.currentIndex = -1;
            }
        }

        onActiveFocusChanged: {
            if (activeFocus) {
                // Clear selection when search box is focused
                appList.currentIndex = -1;
            }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                // First ESC clears search, second ESC closes
                if (root.search !== "" || input.text !== "") {
                    root.clearSearch();
                    event.accepted = true;
                } else {
                    root.requestClose();
                    event.accepted = true;
                }
            }

            if (event.key === Qt.Key_Down) {
                appList.focus = true;
                if (appList.count > 0) {
                    appList.currentIndex = 0;
                    // Skip headers
                    while (appList.currentIndex < appList.count) {
                        let item = appList.itemAtIndex(appList.currentIndex);
                        if (item && item.modelData && item.modelData.type !== "header") {
                            break;
                        }
                        appList.currentIndex++;
                    }
                    appList.positionViewAtIndex(appList.currentIndex, ListView.Center);
                }
                event.accepted = true;
            }

            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                if (root.currentCalcResult !== null && root.search.length > 0 && appList.currentIndex < 1) {
                    root.copyToClipboard(root.currentCalcResult.toString());
                    root.requestClose();
                    root.clearSearch();
                } else if (root.currentCurrencyResult && root.currentCurrencyResult.success && appList.currentIndex < (root.currentCalcResult !== null ? 2 : 1)) {
                    root.copyToClipboard(root.currentCurrencyResult.result.toString());
                    root.requestClose();
                    root.clearSearch();
                } else if (appList.count > 0 && appList.currentIndex >= 0) {
                    let item = appList.itemAtIndex(appList.currentIndex);
                    if (item && item.item && item.item.launchOrFocus) {
                        item.item.launchOrFocus();
                    }
                } else if (appList.count > 0) {
                    let item = appList.itemAtIndex(0);
                    if (item && item.item && item.item.launchOrFocus) {
                        item.item.launchOrFocus();
                    }
                }
                event.accepted = true;
            }
        }
    }

    ListView {
        id: appList
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 0

        keyNavigationEnabled: false
        highlightFollowsCurrentItem: false
        currentIndex: -1

        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds

        model: {
            let items = [];
            let searchLower = root.search.toLowerCase();
            let calcResult = root.calculate(root.search);

            // Filter running windows
            let filteredWindows = root.runningWindows.filter(w => {
                if (searchLower === "")
                    return true;
                let classMatch = (w.class || "").toLowerCase().includes(searchLower);
                let titleMatch = (w.title || "").toLowerCase().includes(searchLower);
                let initialMatch = (w.initialClass || "").toLowerCase().includes(searchLower);
                return classMatch || titleMatch || initialMatch;
            });

            // Filter applications
            let filteredApps = DesktopEntries.applications.values.filter(app => {
                if (searchLower === "")
                    return true;
                return app.name.toLowerCase().includes(searchLower);
            }).sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()));

            // Calculator result first
            if (calcResult !== null) {
                items.push({
                    type: "calculator",
                    result: calcResult,
                    expression: root.search,
                    section: ""
                });
            }

            // Currency conversion result
            if (root.currentCurrencyResult) {
                items.push({
                    type: "currency",
                    data: root.currentCurrencyResult,
                    section: ""
                });
            }

            // Google search option - only if no calc/currency results and no apps found
            if (searchLower !== "" && calcResult === null && !root.currentCurrencyResult && filteredApps.length === 0) {
                items.push({
                    type: "search",
                    query: root.search,
                    section: ""
                });
            }

            // Running windows section
            if (filteredWindows.length > 0) {
                items.push({
                    type: "header",
                    title: "Open Windows",
                    section: "windows"
                });
                for (let i = 0; i < filteredWindows.length; i++) {
                    let win = filteredWindows[i];
                    items.push({
                        type: "window",
                        address: win.address,
                        title: win.title || win.class || "Window",
                        class: win.class,
                        workspace: win.workspace,
                        section: "windows"
                    });
                }
            }

            // Applications section
            if (filteredApps.length > 0) {
                items.push({
                    type: "header",
                    title: "Applications",
                    section: "apps"
                });
                for (let i = 0; i < filteredApps.length; i++) {
                    let app = filteredApps[i];
                    items.push({
                        type: "app",
                        app: app,
                        section: "apps"
                    });
                }
            }

            return items;
        }

        delegate: Loader {
            id: itemLoader
            width: appList.width
            height: modelData.type === "header" ? 30 : LauncherConfig.itemHeight
            sourceComponent: modelData.type === "header" ? headerComponent : modelData.type === "window" ? windowComponent : modelData.type === "calculator" ? calculatorComponent : modelData.type === "currency" ? currencyComponent : modelData.type === "search" ? searchComponent : appComponent

            property var modelData: model.modelData
            property bool isSelected: ListView.isCurrentItem
            property bool isHovered: false

            Component {
                id: headerComponent
                Rectangle {
                    color: "transparent"

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: Appearance.padding.large
                            verticalCenter: parent.verticalCenter
                        }
                        text: modelData.title
                        color: Appearance.colors.textTertiary
                        font.pixelSize: Appearance.font.small
                        font.bold: true
                    }
                }
            }

            Component {
                id: calculatorComponent
                Rectangle {
                    color: isSelected ? Qt.rgba(Appearance.colors.primary.r, Appearance.colors.primary.g, Appearance.colors.primary.b, 0.3) : isHovered ? Appearance.colors.hover : "transparent"
                    border.color: isSelected ? Appearance.colors.primary : "transparent"
                    border.width: isSelected ? 2 : 0
                    radius: Appearance.rounding.small

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: itemLoader.isHovered = true
                        onExited: itemLoader.isHovered = false
                        onClicked: {
                            appList.currentIndex = index;
                            root.copyToClipboard(modelData.result.toString());
                            root.requestClose();
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Appearance.padding.large
                        anchors.rightMargin: Appearance.padding.large
                        spacing: Appearance.spacing.medium

                        Text {
                            text: "="
                            color: Appearance.colors.primary
                            font.pixelSize: 24
                            font.bold: true
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.result.toString()
                                color: Appearance.colors.text
                                font.pointSize: Appearance.font.regular
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.expression + " (Enter to copy)"
                                color: Appearance.colors.textSecondary
                                font.pixelSize: Appearance.font.small
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }
                    }

                    function launchOrFocus() {
                        root.copyToClipboard(modelData.result.toString());
                        root.requestClose();
                        root.clearSearch();
                    }
                }
            }

            Component {
                id: currencyComponent
                Rectangle {
                    color: isSelected ? Qt.rgba(Appearance.colors.secondary.r, Appearance.colors.secondary.g, Appearance.colors.secondary.b, 0.3) : isHovered ? Appearance.colors.hover : "transparent"
                    border.color: isSelected ? Appearance.colors.secondary : "transparent"
                    border.width: isSelected ? 2 : 0
                    radius: Appearance.rounding.small

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: itemLoader.isHovered = true
                        onExited: itemLoader.isHovered = false
                        onClicked: {
                            appList.currentIndex = index;
                            copyResult();
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Appearance.padding.large
                        anchors.rightMargin: Appearance.padding.large
                        spacing: Appearance.spacing.medium

                        Text {
                            text: ""
                            color: Appearance.colors.secondary
                            font.pixelSize: 24
                            font.family: "JetBrainsMono Nerd Font"
                            visible: modelData.data && modelData.data.success
                        }

                        Text {
                            text: "󰅙"
                            color: Appearance.colors.error
                            font.pixelSize: 24
                            font.family: "JetBrainsMono Nerd Font"
                            visible: modelData.data && !modelData.data.success
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.data && modelData.data.success ? modelData.data.result + " " + modelData.data.to : (modelData.data ? modelData.data.error : "Loading...")
                                color: Appearance.colors.text
                                font.pointSize: Appearance.font.regular
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.data && modelData.data.success ? (modelData.data.amount + " " + modelData.data.from + " → " + modelData.data.to + (modelData.data.date ? " on " + modelData.data.date : "")) : (modelData.data ? modelData.data.query : "")
                                color: Appearance.colors.textSecondary
                                font.pixelSize: Appearance.font.small
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }
                    }

                    function launchOrFocus() {
                        copyResult();
                    }

                    function copyResult() {
                        if (modelData.data && modelData.data.success) {
                            // Copy only the number, not the currency unit
                            root.copyToClipboard(modelData.data.result.toString());
                            root.requestClose();
                            root.clearSearch();
                        }
                    }
                }
            }

            Component {
                id: searchComponent
                Rectangle {
                    color: isSelected ? Qt.rgba(Appearance.colors.primary.r, Appearance.colors.primary.g, Appearance.colors.primary.b, 0.3) : isHovered ? Appearance.colors.hover : "transparent"
                    border.color: isSelected ? Appearance.colors.primary : "transparent"
                    border.width: isSelected ? 2 : 0
                    radius: Appearance.rounding.small

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: itemLoader.isHovered = true
                        onExited: itemLoader.isHovered = false
                        onClicked: {
                            appList.currentIndex = index;
                            launchOrFocus();
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Appearance.padding.large
                        anchors.rightMargin: Appearance.padding.large
                        spacing: Appearance.spacing.medium

                        Text {
                            text: "󰍉"
                            color: Appearance.colors.primary
                            font.pixelSize: 24
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "Search Google for \"" + modelData.query + "\""
                                color: Appearance.colors.text
                                font.pointSize: Appearance.font.regular
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "Open in browser"
                                color: Appearance.colors.textSecondary
                                font.pixelSize: Appearance.font.small
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }
                    }

                    function launchOrFocus() {
                        root.openBrowser("https://www.google.com/search?q=" + encodeURIComponent(modelData.query));
                        root.requestClose();
                        root.clearSearch();
                    }
                }
            }

            Component {
                id: windowComponent
                Rectangle {
                    color: isSelected ? Qt.rgba(Appearance.colors.primary.r, Appearance.colors.primary.g, Appearance.colors.primary.b, 0.3) : isHovered ? Appearance.colors.hover : "transparent"
                    border.color: isSelected ? Appearance.colors.primary : "transparent"
                    border.width: isSelected ? 2 : 0
                    radius: Appearance.rounding.small

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: itemLoader.isHovered = true
                        onExited: itemLoader.isHovered = false
                        onClicked: {
                            appList.currentIndex = index;
                            focusWindow();
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Appearance.padding.large
                        anchors.rightMargin: Appearance.padding.large
                        spacing: Appearance.spacing.medium

                        Text {
                            text: "▶"
                            color: Appearance.colors.primary
                            font.pixelSize: 16
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.title
                                color: Appearance.colors.text
                                font.pointSize: Appearance.font.regular
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "Switch to window"
                                color: Appearance.colors.textSecondary
                                font.pixelSize: Appearance.font.small
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }
                    }

                    function launchOrFocus() {
                        let focusProc = Qt.createQmlObject('
                            import Quickshell.Io
                            Process {
                                command: ["hyprctl", "dispatch", "focuswindow", "address:' + modelData.address + '"]
                                running: true
                            }
                        ', parent);
                        focusProc.running = true;
                        root.requestClose();
                        root.clearSearch();
                    }

                    function focusWindow() {
                        launchOrFocus();
                    }
                }
            }

            Component {
                id: appComponent
                Rectangle {
                    color: isSelected ? Qt.rgba(Appearance.colors.primary.r, Appearance.colors.primary.g, Appearance.colors.primary.b, 0.3) : isHovered ? Appearance.colors.hover : "transparent"
                    border.color: isSelected ? Appearance.colors.primary : "transparent"
                    border.width: isSelected ? 2 : 0
                    radius: Appearance.rounding.small

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: itemLoader.isHovered = true
                        onExited: itemLoader.isHovered = false
                        onClicked: {
                            appList.currentIndex = index;
                            launchApp();
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Appearance.padding.large
                        anchors.rightMargin: Appearance.padding.large
                        spacing: Appearance.spacing.medium

                        Image {
                            source: modelData.app.icon ? Quickshell.iconPath(modelData.app.icon) : ""
                            Layout.preferredWidth: LauncherConfig.iconSize
                            Layout.preferredHeight: LauncherConfig.iconSize
                            visible: source != ""
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.app.name
                                color: Appearance.colors.text
                                font.pointSize: Appearance.font.regular
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.app.description || "Launch new instance"
                                color: Appearance.colors.textSecondary
                                font.pixelSize: Appearance.font.small
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }
                    }

                    function launchOrFocus() {
                        modelData.app.execute();
                        root.requestClose();
                        root.clearSearch();
                    }

                    function launchApp() {
                        launchOrFocus();
                    }
                }
            }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                // First ESC clears search, second ESC closes
                if (root.search !== "") {
                    root.clearSearch();
                    event.accepted = true;
                } else {
                    root.requestClose();
                    event.accepted = true;
                }
            }

            if (event.key === Qt.Key_Up) {
                if (currentIndex > 0) {
                    currentIndex--;
                    // Skip headers
                    while (currentIndex >= 0) {
                        let item = itemAtIndex(currentIndex);
                        if (item && item.modelData && item.modelData.type !== "header") {
                            break;
                        }
                        currentIndex--;
                    }
                    if (currentIndex < 0) {
                        input.focus = true;
                        currentIndex = -1;
                    } else {
                        positionViewAtIndex(currentIndex, ListView.Center);
                    }
                } else {
                    input.focus = true;
                    currentIndex = -1;
                }
                event.accepted = true;
            }

            if (event.key === Qt.Key_Down) {
                if (currentIndex < count - 1) {
                    currentIndex++;
                    // Skip headers
                    while (currentIndex < count) {
                        let item = itemAtIndex(currentIndex);
                        if (item && item.modelData && item.modelData.type !== "header") {
                            break;
                        }
                        currentIndex++;
                    }
                    if (currentIndex >= count) {
                        currentIndex = count - 1;
                    }
                    if (currentIndex >= 0) {
                        positionViewAtIndex(currentIndex, ListView.Center);
                    }
                }
                event.accepted = true;
            }

            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                if (currentIndex >= 0) {
                    let item = itemAtIndex(currentIndex);
                    if (item && item.item && item.item.launchOrFocus) {
                        item.item.launchOrFocus();
                    }
                }
                event.accepted = true;
            }
        }
    }
}
