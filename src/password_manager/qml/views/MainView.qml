import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material
import QtQuick.Effects

Item {
    id: mainView
    focus: true

    // Edit mode state
    property bool editMode: false
    property int editingRow: -1

    // Sidebar state
    property bool sidebarExpanded: true
    property string searchQuery: ""
    property bool showFavoritesOnly: false

    // Click outside to unfocus search
    MouseArea {
        anchors.fill: parent
        onClicked: mainView.forceActiveFocus()
        propagateComposedEvents: true
        z: -1
    }

    // TOTP refresh trigger (changes every 30 seconds)
    property int totpRefreshTrigger: 0
    property int totpRemainingSeconds: 30 - (Math.floor(Date.now() / 1000) % 30)

    Timer {
        id: totpTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var currentPeriod = Math.floor(Date.now() / 1000 / 30)
            if (currentPeriod !== totpRefreshTrigger) {
                totpRefreshTrigger = currentPeriod
            }
            totpRemainingSeconds = 30 - (Math.floor(Date.now() / 1000) % 30)
        }
    }

    // Header bar
    Rectangle {
        id: headerBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 56
        color: "#252525"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 20
            spacing: 12

            // Hamburger menu button
            RoundButton {
                width: 40
                height: 40
                flat: true
                ToolTip.visible: hovered
                ToolTip.text: sidebarExpanded ? "Collapse menu" : "Expand menu"
                onClicked: sidebarExpanded = !sidebarExpanded

                Text {
                    anchors.centerIn: parent
                    text: "\ue5d2"
                    font.family: "Material Icons"
                    font.pixelSize: 24
                    color: "#e0e0e0"
                }
            }

            Text {
                text: "\ue897"
                font.family: "Material Icons"
                font.pixelSize: 28
                color: "#1976D2"
            }

            Text {
                text: vaultController && vaultController.vaultName ? vaultController.vaultName : "Password Manager"
                font.pixelSize: 18
                font.weight: Font.Medium
                color: "#ffffff"
            }

            Item { Layout.fillWidth: true }

            // Search bar
            Rectangle {
                Layout.preferredWidth: 250
                height: 36
                color: "#1e1e1e"
                radius: 18
                border.color: searchField.activeFocus ? "#1976D2" : "#3a3a3a"
                border.width: 1

                Behavior on border.color {
                    ColorAnimation { duration: 150 }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: "\ue8b6"
                        font.family: "Material Icons"
                        font.pixelSize: 18
                        color: "#707070"
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        TextInput {
                            id: searchField
                            anchors.fill: parent
                            anchors.topMargin: 1
                            verticalAlignment: TextInput.AlignVCenter
                            color: "#ffffff"
                            font.pixelSize: 13
                            clip: true
                            onTextChanged: searchQuery = text
                        }

                        Text {
                            anchors.fill: parent
                            anchors.topMargin: 1
                            verticalAlignment: Text.AlignVCenter
                            text: "Search passwords..."
                            color: "#606060"
                            font.pixelSize: 13
                            visible: searchField.text === "" && !searchField.activeFocus
                        }
                    }

                    Text {
                        text: "\ue5cd"
                        font.family: "Material Icons"
                        font.pixelSize: 18
                        color: "#707070"
                        visible: searchField.text !== ""
                        opacity: clearSearchMouse.containsMouse ? 1 : 0.7

                        MouseArea {
                            id: clearSearchMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchField.text = ""
                                searchField.focus = false
                            }
                        }
                    }
                }
            }

            Item { width: 8 }

            RoundButton {
                width: 40
                height: 40
                flat: true
                ToolTip.visible: hovered
                ToolTip.text: "Lock vault"
                onClicked: {
                    vaultController.closeVault()
                    root.vaultUnlocked = false
                }

                Text {
                    anchors.centerIn: parent
                    text: "\ue898"
                    font.family: "Material Icons"
                    font.pixelSize: 22
                    color: "#e0e0e0"
                }
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#3d3d3d"
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.topMargin: headerBar.height + 16
        anchors.margins: 16
        spacing: 16

        // Collapsible sidebar
        Rectangle {
            id: sidebar
            Layout.fillHeight: true
            Layout.preferredWidth: sidebarExpanded ? 220 : 60
            color: "#252525"
            radius: 12

            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#40000000"
                shadowBlur: 0.5
                shadowVerticalOffset: 2
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                // Navigation section
                SidebarItem {
                    icon: "\ue899"
                    label: "All Passwords"
                    expanded: sidebarExpanded
                    selected: !showFavoritesOnly
                    badgeCount: passwordList.count
                    onClicked: showFavoritesOnly = false
                }

                SidebarItem {
                    icon: "\ue838"
                    label: "Favorites"
                    expanded: sidebarExpanded
                    selected: showFavoritesOnly
                    badgeCount: passwordController ? passwordController.passwordModel.favoriteCount : 0
                    onClicked: showFavoritesOnly = true
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    height: 1
                    color: "#3a3a3a"
                }

                // Tools section header
                Text {
                    text: "TOOLS"
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    font.letterSpacing: 1
                    color: "#606060"
                    visible: sidebarExpanded
                    Layout.leftMargin: 12
                    Layout.bottomMargin: 4
                }

                SidebarItem {
                    icon: "\ue73c"
                    label: "Password Generator"
                    expanded: sidebarExpanded
                    onClicked: generatorPopup.open()
                }

                SidebarItem {
                    icon: "\ue2c4"
                    label: "Export Data"
                    expanded: sidebarExpanded
                    onClicked: exportDialog.open()
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    height: 1
                    color: "#3a3a3a"
                }

                // Settings section (collapsible)
                SidebarSection {
                    icon: "\ue8b8"
                    label: "Settings"
                    expanded: sidebarExpanded

                    SidebarItem {
                        icon: "\ue897"
                        label: "Security"
                        expanded: sidebarExpanded
                        indent: true
                        onClicked: securityDialog.open()
                    }

                    SidebarItem {
                        icon: "\ue312"
                        label: "Keyboard Shortcuts"
                        expanded: sidebarExpanded
                        indent: true
                        onClicked: shortcutsPopup.open()
                    }
                }

                Item { Layout.fillHeight: true }

                // About section at bottom
                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    height: 1
                    color: "#3a3a3a"
                }

                SidebarItem {
                    icon: "\ue88e"
                    label: "About"
                    expanded: sidebarExpanded
                    onClicked: aboutPopup.open()
                }
            }
        }

        // Password list (main panel)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 70
            color: "#252525"
            radius: 12

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#40000000"
                shadowBlur: 0.5
                shadowVerticalOffset: 2
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Panel header
                Rectangle {
                    Layout.fillWidth: true
                    height: 52
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 10

                        Text {
                            text: searchQuery !== "" ? "Search Results" : (showFavoritesOnly ? "Favorites" : "Saved Passwords")
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: "#ffffff"
                        }

                        Rectangle {
                            width: countText.width + 16
                            height: 24
                            radius: 12
                            color: "#1976D2"
                            visible: passwordList.count > 0

                            Text {
                                id: countText
                                anchors.centerIn: parent
                                text: passwordList.count
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: "#ffffff"
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        height: 1
                        color: "#3a3a3a"
                    }
                }

                // Column headers
                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    color: "#2a2a2a"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 10

                        Text {
                            text: "WEBSITE"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            font.letterSpacing: 0.5
                            color: "#808080"
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                        }
                        Text {
                            text: "USERNAME"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            font.letterSpacing: 0.5
                            color: "#808080"
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                        }
                        Text {
                            text: "PASSWORD"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            font.letterSpacing: 0.5
                            color: "#808080"
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                        }
                        Text {
                            text: "TOTP"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            font.letterSpacing: 0.5
                            color: "#808080"
                            Layout.preferredWidth: 115
                        }
                        Item {
                            Layout.preferredWidth: 132
                        }
                    }
                }

                // Password list
                ListView {
                    id: passwordList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: passwordController ? passwordController.passwordModel : null

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: Rectangle {
                        id: delegateItem
                        width: passwordList.width
                        height: matchesSearch ? 56 : 0
                        visible: matchesSearch
                        clip: true
                        color: editMode && editingRow === index ? "#1976D2" + "30" : (mouseArea.containsMouse ? "#2f2f2f" : "transparent")

                        property bool matchesSearch: {
                            // Filter by favorites if enabled
                            if (showFavoritesOnly && !model.favorite) return false
                            // Filter by search query
                            if (searchQuery === "") return true
                            var query = searchQuery.toLowerCase()
                            return model.website.toLowerCase().indexOf(query) !== -1 ||
                                   model.username.toLowerCase().indexOf(query) !== -1
                        }

                        Behavior on height {
                            NumberAnimation { duration: 150 }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            spacing: 10

                            // Website - clickable link
                            Text {
                                text: model.website
                                font.pixelSize: 14
                                color: websiteMouseArea.containsMouse ? "#1976D2" : "#ffffff"
                                font.underline: websiteMouseArea.containsMouse
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1

                                MouseArea {
                                    id: websiteMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: passwordController.openWebsite(index)
                                }
                            }

                            // Username - clickable to copy
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                height: 28
                                color: "transparent"
                                border.color: usernameMouseArea.containsMouse ? "#505050" : "transparent"
                                border.width: 1
                                radius: 14

                                Text {
                                    anchors.centerIn: parent
                                    text: model.username
                                    font.pixelSize: 14
                                    color: usernameMouseArea.containsMouse ? "#ffffff" : "#a0a0a0"
                                }

                                MouseArea {
                                    id: usernameMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: passwordController.copyUsername(index)
                                }

                                ToolTip {
                                    visible: usernameMouseArea.containsMouse
                                    text: "Click to copy"
                                    y: -height - 5
                                    contentItem: Text {
                                        text: "Click to copy"
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                    }
                                    background: Rectangle {
                                        color: "#424242"
                                        radius: 4
                                    }
                                }
                            }

                            // Password - clickable to copy
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                height: 28
                                color: "transparent"
                                border.color: passwordMouseArea.containsMouse ? "#505050" : "transparent"
                                border.width: 1
                                radius: 14

                                Text {
                                    anchors.centerIn: parent
                                    text: model.visible ? model.password : "\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022"
                                    font.pixelSize: 14
                                    color: passwordMouseArea.containsMouse ? "#ffffff" : "#a0a0a0"
                                    font.letterSpacing: model.visible ? 0 : 2
                                }

                                MouseArea {
                                    id: passwordMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: passwordController.copyPassword(index)
                                }

                                ToolTip {
                                    visible: passwordMouseArea.containsMouse
                                    text: "Click to copy"
                                    y: -height - 5
                                    contentItem: Text {
                                        text: "Click to copy"
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                    }
                                    background: Rectangle {
                                        color: "#424242"
                                        radius: 4
                                    }
                                }
                            }

                            // TOTP code display with timer
                            Rectangle {
                                Layout.preferredWidth: 115
                                height: 28
                                color: "transparent"
                                border.color: totpMouseArea.containsMouse ? "#3d8b40" : "transparent"
                                border.width: 1
                                radius: 14
                                visible: model.hasTotp

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    Text {
                                        id: totpCodeText
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: {
                                            // Reference totpRefreshTrigger to force refresh
                                            var trigger = totpRefreshTrigger
                                            return model.hasTotp ? passwordController.generateTotp(index) : ""
                                        }
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        font.family: "Menlo"
                                        color: totpMouseArea.containsMouse ? "#66BB6A" : "#4CAF50"
                                    }

                                    // Circular timer
                                    Canvas {
                                        id: timerCanvas
                                        width: 18
                                        height: 18
                                        anchors.verticalCenter: parent.verticalCenter

                                        property real progress: totpRemainingSeconds / 30.0
                                        property color circleColor: totpRemainingSeconds <= 5 ? "#ef5350" : "#4CAF50"

                                        onProgressChanged: requestPaint()
                                        onCircleColorChanged: requestPaint()

                                        onPaint: {
                                            var ctx = getContext("2d")
                                            ctx.reset()

                                            var centerX = width / 2
                                            var centerY = height / 2
                                            var radius = width / 2 - 2

                                            // Background circle
                                            ctx.beginPath()
                                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                                            ctx.strokeStyle = "#404040"
                                            ctx.lineWidth = 2
                                            ctx.stroke()

                                            // Progress arc
                                            ctx.beginPath()
                                            ctx.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + (2 * Math.PI * progress))
                                            ctx.strokeStyle = circleColor
                                            ctx.lineWidth = 2
                                            ctx.stroke()
                                        }
                                    }
                                }

                                MouseArea {
                                    id: totpMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: passwordController.copyTotp(index)
                                }

                                ToolTip {
                                    visible: totpMouseArea.containsMouse
                                    text: "Click to copy"
                                    y: -height - 5
                                    contentItem: Text {
                                        text: "Click to copy"
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                    }
                                    background: Rectangle {
                                        color: "#424242"
                                        radius: 4
                                    }
                                }
                            }

                            // Empty placeholder when no TOTP
                            Item {
                                Layout.preferredWidth: 115
                                height: 28
                                visible: !model.hasTotp
                            }

                            Row {
                                spacing: 2
                                Layout.preferredWidth: 132
                                opacity: mouseArea.containsMouse ? 1 : 0.6

                                Behavior on opacity {
                                    NumberAnimation { duration: 150 }
                                }

                                RoundButton {
                                    width: 32
                                    height: 32
                                    flat: true
                                    ToolTip.visible: hovered
                                    ToolTip.text: model.favorite ? "Remove from favorites" : "Add to favorites"
                                    onClicked: passwordController.toggleFavorite(index)

                                    Text {
                                        anchors.centerIn: parent
                                        text: model.favorite ? "\ue838" : "\ue83a"
                                        font.family: "Material Icons"
                                        font.pixelSize: 16
                                        color: model.favorite ? "#FFC107" : "#e0e0e0"
                                    }
                                }
                                RoundButton {
                                    width: 32
                                    height: 32
                                    flat: true
                                    ToolTip.visible: hovered
                                    ToolTip.text: "Edit"
                                    onClicked: startEdit(index)

                                    Text {
                                        anchors.centerIn: parent
                                        text: "\ue3c9"
                                        font.family: "Material Icons"
                                        font.pixelSize: 16
                                        color: "#1976D2"
                                    }
                                }
                                RoundButton {
                                    width: 32
                                    height: 32
                                    flat: true
                                    ToolTip.visible: hovered
                                    ToolTip.text: model.visible ? "Hide password" : "Show password"
                                    onClicked: passwordController.togglePasswordVisibility(index)

                                    Text {
                                        anchors.centerIn: parent
                                        text: model.visible ? "\ue8f4" : "\ue8f5"
                                        font.family: "Material Icons"
                                        font.pixelSize: 16
                                        color: "#e0e0e0"
                                    }
                                }
                                RoundButton {
                                    width: 32
                                    height: 32
                                    flat: true
                                    ToolTip.visible: hovered
                                    ToolTip.text: "Delete"
                                    onClicked: passwordController.deleteEntry(index)

                                    Text {
                                        anchors.centerIn: parent
                                        text: "\ue872"
                                        font.family: "Material Icons"
                                        font.pixelSize: 16
                                        color: "#ef5350"
                                    }
                                }
                            }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            height: 1
                            color: "#2a2a2a"
                            visible: index < passwordList.count - 1
                        }
                    }

                    // Empty state
                    Item {
                        anchors.fill: parent
                        visible: passwordList.count === 0

                        Column {
                            anchors.centerIn: parent
                            spacing: 12

                            Text {
                                text: "\ue899"
                                font.family: "Material Icons"
                                font.pixelSize: 64
                                color: "#404040"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "No passwords yet"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: "#606060"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "Add your first password using the form"
                                font.pixelSize: 13
                                color: "#505050"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }
        }

        // Entry form (right panel)
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 280
            color: "#252525"
            radius: 12

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#40000000"
                shadowBlur: 0.5
                shadowVerticalOffset: 2
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                // Form header
                Row {
                    spacing: 10
                    Layout.bottomMargin: 4

                    Text {
                        text: editMode ? "\ue3c9" : "\ue145"
                        font.family: "Material Icons"
                        font.pixelSize: 22
                        color: "#1976D2"
                    }

                    Text {
                        text: editMode ? "Edit Entry" : "Add New Entry"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: "#ffffff"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#3a3a3a"
                }

                // Website field
                Column {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "Website"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#909090"
                    }

                    TextField {
                        id: websiteField
                        width: parent.width
                        placeholderText: "e.g., github.com"
                        onAccepted: usernameField.focus = true
                    }

                    Text {
                        text: passwordController ? passwordController.urlError : ""
                        color: "#ef5350"
                        font.pixelSize: 11
                        visible: passwordController && passwordController.urlError !== ""
                    }
                }

                // Username field
                Column {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "Username"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#909090"
                    }

                    TextField {
                        id: usernameField
                        width: parent.width
                        placeholderText: "e.g., john@email.com"
                        onAccepted: passwordField.focus = true
                    }

                    Text {
                        text: passwordController ? passwordController.usernameError : ""
                        color: "#ef5350"
                        font.pixelSize: 11
                        visible: passwordController && passwordController.usernameError !== ""
                    }
                }

                // Password field
                Column {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "Password"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#909090"
                    }

                    TextField {
                        id: passwordField
                        width: parent.width
                        placeholderText: "Enter password"
                        echoMode: TextInput.Password
                        onAccepted: totpField.focus = true
                    }

                    Text {
                        text: passwordController ? passwordController.passwordError : ""
                        color: "#ef5350"
                        font.pixelSize: 11
                        visible: passwordController && passwordController.passwordError !== ""
                    }
                }

                // TOTP field
                Column {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "TOTP Key (optional)"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#909090"
                    }

                    TextField {
                        id: totpField
                        width: parent.width
                        placeholderText: "e.g., JBSWY3DPEHPK3PXP"
                        onAccepted: editMode ? updateEntry() : addEntry()
                    }

                    Text {
                        text: passwordController ? passwordController.totpError : ""
                        color: "#ef5350"
                        font.pixelSize: 11
                        visible: passwordController && passwordController.totpError !== ""
                    }

                    Text {
                        text: "Base32 secret for 2FA codes"
                        font.pixelSize: 10
                        color: "#606060"
                        visible: !passwordController || passwordController.totpError === ""
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.minimumHeight: 10
                }

                // Action buttons
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        id: actionButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        highlighted: true
                        font.weight: Font.Medium
                        onClicked: editMode ? updateEntry() : addEntry()

                        contentItem: Row {
                            spacing: 8
                            anchors.centerIn: parent

                            Text {
                                text: editMode ? "\ue161" : "\ue145"
                                font.family: "Material Icons"
                                font.pixelSize: 18
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: editMode ? "Save Changes" : "Add Password"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Button {
                        id: cancelButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        flat: true
                        visible: editMode
                        onClicked: cancelEdit()

                        contentItem: Row {
                            spacing: 8
                            anchors.centerIn: parent

                            Text {
                                text: "\ue5cd"
                                font.family: "Material Icons"
                                font.pixelSize: 18
                                color: "#909090"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "Cancel"
                                font.pixelSize: 14
                                color: "#909090"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }
    }

    function startEdit(row) {
        editMode = true
        editingRow = row
        websiteField.text = passwordController.getWebsite(row)
        usernameField.text = passwordController.getUsername(row)
        passwordField.text = passwordController.getPassword(row)
        totpField.text = passwordController.getTotpKey(row)
        websiteField.focus = true
    }

    function cancelEdit() {
        editMode = false
        editingRow = -1
        websiteField.text = ""
        usernameField.text = ""
        passwordField.text = ""
        totpField.text = ""
    }

    function addEntry() {
        if (passwordController && passwordController.addEntry(websiteField.text, usernameField.text, passwordField.text, totpField.text)) {
            websiteField.text = ""
            usernameField.text = ""
            passwordField.text = ""
            totpField.text = ""
            websiteField.focus = true
        }
    }

    function updateEntry() {
        if (passwordController && passwordController.updateEntry(editingRow, websiteField.text, usernameField.text, passwordField.text, totpField.text)) {
            cancelEdit()
        }
    }

    function generateRandomPassword(length, useUppercase, useLowercase, useNumbers, useSymbols) {
        var chars = ""
        if (useLowercase) chars += "abcdefghijklmnopqrstuvwxyz"
        if (useUppercase) chars += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        if (useNumbers) chars += "0123456789"
        if (useSymbols) chars += "!@#$%^&*()_+-=[]{}|;:,.<>?"
        if (chars === "") chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

        var password = ""
        for (var i = 0; i < length; i++) {
            password += chars.charAt(Math.floor(Math.random() * chars.length))
        }
        return password
    }

    // Sidebar Item Component
    component SidebarItem: Rectangle {
        id: sidebarItem
        Layout.fillWidth: true
        height: 40
        radius: 8
        color: selected ? "#1976D2" + "30" : (itemMouse.containsMouse ? "#2f2f2f" : "transparent")
        opacity: enabled ? 1.0 : 0.5

        property string icon: ""
        property string label: ""
        property bool expanded: true
        property bool selected: false
        property bool indent: false
        property int badgeCount: 0
        readonly property alias hovered: itemMouse.containsMouse

        signal clicked()

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        MouseArea {
            id: itemMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (parent.enabled) parent.clicked()
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: indent ? 24 : 8
            anchors.rightMargin: 8
            spacing: 10

            Text {
                text: icon
                font.family: "Material Icons"
                font.pixelSize: 20
                color: selected ? "#1976D2" : "#a0a0a0"
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: label
                font.pixelSize: 13
                color: selected ? "#ffffff" : "#c0c0c0"
                visible: expanded
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Rectangle {
                width: badgeText.width + 12
                height: 20
                radius: 10
                color: "#1976D2"
                visible: expanded && badgeCount > 0

                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: badgeCount
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: "#ffffff"
                }
            }
        }

        ToolTip {
            visible: itemMouse.containsMouse && !expanded
            text: label
            delay: 500
        }
    }

    // Sidebar Section Component (collapsible)
    component SidebarSection: ColumnLayout {
        id: sidebarSection
        Layout.fillWidth: true
        spacing: 2

        property string icon: ""
        property string label: ""
        property bool expanded: true
        property bool sectionExpanded: true

        default property alias content: sectionContent.children

        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: sectionMouse.containsMouse ? "#2f2f2f" : "transparent"

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            MouseArea {
                id: sectionMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sectionExpanded = !sectionExpanded
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 10

                Text {
                    text: icon
                    font.family: "Material Icons"
                    font.pixelSize: 20
                    color: "#a0a0a0"
                    Layout.preferredWidth: 24
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: label
                    font.pixelSize: 13
                    color: "#c0c0c0"
                    visible: expanded
                    Layout.fillWidth: true
                }

                Text {
                    text: sectionExpanded ? "\ue5cf" : "\ue5ce"
                    font.family: "Material Icons"
                    font.pixelSize: 18
                    color: "#606060"
                    visible: expanded

                    Behavior on text {
                        SequentialAnimation {
                            PropertyAnimation { target: parent; property: "opacity"; to: 0; duration: 75 }
                            PropertyAction {}
                            PropertyAnimation { target: parent; property: "opacity"; to: 1; duration: 75 }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: sectionContent
            Layout.fillWidth: true
            visible: sectionExpanded && expanded
            spacing: 2

            Behavior on visible {
                NumberAnimation { duration: 150 }
            }
        }
    }

    // Password Generator Dialog
    Dialog {
        id: generatorPopup
        title: ""
        modal: true
        width: 462
        height: 440
        anchors.centerIn: parent
        padding: 0
        topPadding: 0
        dim: true

        Material.theme: Material.Dark
        Material.accent: "#1976D2"

        Overlay.modal: Rectangle {
            color: "#D0000000"
        }

        background: Rectangle {
            color: "#E8141414"
            radius: 16
            border.color: "#404040"
            border.width: 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#80000000"
                shadowBlur: 1.5
                shadowVerticalOffset: 8
            }
        }

        header: Rectangle {
            height: 60
            color: "#252525"
            radius: 16

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 20
                color: "#252525"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 16

                Text {
                    text: "\ue73c"
                    font.family: "Material Icons"
                    font.pixelSize: 28
                    color: "#1976D2"
                }

                Text {
                    text: "Password Generator"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    color: "#ffffff"
                }

                Item { Layout.fillWidth: true }

                RoundButton {
                    width: 36
                    height: 36
                    flat: true
                    onClicked: generatorPopup.close()

                    Text {
                        anchors.centerIn: parent
                        text: "\ue5cd"
                        font.family: "Material Icons"
                        font.pixelSize: 20
                        color: "#808080"
                    }
                }
            }
        }

        footer: Item { height: 0 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            // Generated password display
            Rectangle {
                Layout.fillWidth: true
                Layout.bottomMargin: 8
                height: 48
                color: "#1e1e1e"
                radius: 8
                border.color: "#3a3a3a"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        id: generatedPasswordText
                        text: generateRandomPassword(genLengthSlider.value, genUppercase.checked, genLowercase.checked, genNumbers.checked, genSymbols.checked)
                        font.pixelSize: 15
                        font.family: "Menlo"
                        color: "#ffffff"
                        Layout.fillWidth: true
                        elide: Text.ElideMiddle
                    }

                    RoundButton {
                        width: 32
                        height: 32
                        flat: true
                        ToolTip.visible: hovered
                        ToolTip.text: "Copy to clipboard"
                        onClicked: {
                            if (passwordController) {
                                passwordController.copyToClipboard(generatedPasswordText.text)
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "\ue14d"
                            font.family: "Material Icons"
                            font.pixelSize: 18
                            color: "#1976D2"
                        }
                    }

                    RoundButton {
                        width: 32
                        height: 32
                        flat: true
                        ToolTip.visible: hovered
                        ToolTip.text: "Generate new"
                        onClicked: generatedPasswordText.text = generateRandomPassword(genLengthSlider.value, genUppercase.checked, genLowercase.checked, genNumbers.checked, genSymbols.checked)

                        Text {
                            anchors.centerIn: parent
                            text: "\ue5d5"
                            font.family: "Material Icons"
                            font.pixelSize: 18
                            color: "#808080"
                        }
                    }
                }
            }

            // Length slider
            Column {
                Layout.fillWidth: true
                spacing: 6

                Row {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "\ue8ff"
                        font.family: "Material Icons"
                        font.pixelSize: 16
                        color: "#1976D2"
                    }

                    Text {
                        text: "Length"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: "#ffffff"
                    }

                    Item { width: parent.width - 180 }

                    Text {
                        text: genLengthSlider.value + " characters"
                        font.pixelSize: 13
                        color: "#808080"
                    }
                }

                Slider {
                    id: genLengthSlider
                    width: parent.width
                    from: 8
                    to: 64
                    value: 16
                    stepSize: 1
                    onValueChanged: generatedPasswordText.text = generateRandomPassword(value, genUppercase.checked, genLowercase.checked, genNumbers.checked, genSymbols.checked)
                }
            }

            // Character options
            Column {
                Layout.fillWidth: true
                spacing: 6

                Row {
                    spacing: 8

                    Text {
                        text: "\ue8d3"
                        font.family: "Material Icons"
                        font.pixelSize: 16
                        color: "#1976D2"
                    }

                    Text {
                        text: "Character Types"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: "#ffffff"
                    }
                }

                GridLayout {
                    width: parent.width
                    columns: 2
                    rowSpacing: 4
                    columnSpacing: 8

                    CheckBox {
                        id: genUppercase
                        text: "Uppercase (A-Z)"
                        checked: true
                        onCheckedChanged: generatedPasswordText.text = generateRandomPassword(genLengthSlider.value, checked, genLowercase.checked, genNumbers.checked, genSymbols.checked)
                    }

                    CheckBox {
                        id: genLowercase
                        text: "Lowercase (a-z)"
                        checked: true
                        onCheckedChanged: generatedPasswordText.text = generateRandomPassword(genLengthSlider.value, genUppercase.checked, checked, genNumbers.checked, genSymbols.checked)
                    }

                    CheckBox {
                        id: genNumbers
                        text: "Numbers (0-9)"
                        checked: true
                        onCheckedChanged: generatedPasswordText.text = generateRandomPassword(genLengthSlider.value, genUppercase.checked, genLowercase.checked, checked, genSymbols.checked)
                    }

                    CheckBox {
                        id: genSymbols
                        text: "Symbols (!@#$)"
                        checked: true
                        onCheckedChanged: generatedPasswordText.text = generateRandomPassword(genLengthSlider.value, genUppercase.checked, genLowercase.checked, genNumbers.checked, checked)
                    }
                }
            }

            Item { Layout.preferredHeight: 12 }

            Button {
                text: "Use This Password"
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                highlighted: true
                font.weight: Font.Medium
                font.pixelSize: 14
                onClicked: {
                    passwordField.text = generatedPasswordText.text
                    generatorPopup.close()
                }
            }
        }
    }

    // Keyboard Shortcuts Dialog
    Dialog {
        id: shortcutsPopup
        title: ""
        modal: true
        width: 450
        height: 420
        anchors.centerIn: parent
        padding: 0
        topPadding: 0
        dim: true

        Material.theme: Material.Dark
        Material.accent: "#1976D2"

        Overlay.modal: Rectangle {
            color: "#D0000000"
        }

        background: Rectangle {
            color: "#E8141414"
            radius: 16
            border.color: "#404040"
            border.width: 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#80000000"
                shadowBlur: 1.5
                shadowVerticalOffset: 8
            }
        }

        header: Rectangle {
            height: 60
            color: "#252525"
            radius: 16

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 20
                color: "#252525"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 16

                Text {
                    text: "\ue312"
                    font.family: "Material Icons"
                    font.pixelSize: 28
                    color: "#1976D2"
                }

                Text {
                    text: "Keyboard Shortcuts"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    color: "#ffffff"
                }

                Item { Layout.fillWidth: true }

                RoundButton {
                    width: 36
                    height: 36
                    flat: true
                    onClicked: shortcutsPopup.close()

                    Text {
                        anchors.centerIn: parent
                        text: "\ue5cd"
                        font.family: "Material Icons"
                        font.pixelSize: 20
                        color: "#808080"
                    }
                }
            }
        }

        footer: Item { height: 0 }

        ListView {
            anchors.fill: parent
            anchors.margins: 20
            clip: true
            spacing: 6

            model: ListModel {
                ListElement { shortcut: "Ctrl/Cmd + F"; action: "Search passwords" }
                ListElement { shortcut: "Ctrl/Cmd + N"; action: "Add new password" }
                ListElement { shortcut: "Ctrl/Cmd + L"; action: "Lock vault" }
                ListElement { shortcut: "Ctrl/Cmd + G"; action: "Generate password" }
                ListElement { shortcut: "Escape"; action: "Cancel / Close dialog" }
                ListElement { shortcut: "Enter"; action: "Submit form" }
                ListElement { shortcut: "Ctrl/Cmd + ,"; action: "Toggle sidebar" }
            }

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                height: 44
                color: "transparent"
                radius: 8

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 16

                    Rectangle {
                        Layout.preferredWidth: 150
                        height: 32
                        color: "#252525"
                        radius: 6
                        border.color: "#404040"

                        Text {
                            anchors.centerIn: parent
                            text: model.shortcut
                            font.pixelSize: 12
                            font.family: "Menlo"
                            color: "#c0c0c0"
                        }
                    }

                    Text {
                        text: model.action
                        font.pixelSize: 14
                        color: "#e0e0e0"
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    // About Dialog
    Dialog {
        id: aboutPopup
        title: ""
        modal: true
        width: 380
        height: 320
        anchors.centerIn: parent
        padding: 0
        topPadding: 0
        dim: true

        Material.theme: Material.Dark
        Material.accent: "#1976D2"

        Overlay.modal: Rectangle {
            color: "#D0000000"
        }

        background: Rectangle {
            color: "#E8141414"
            radius: 16
            border.color: "#404040"
            border.width: 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#80000000"
                shadowBlur: 1.5
                shadowVerticalOffset: 8
            }
        }

        header: Rectangle {
            height: 60
            color: "#252525"
            radius: 16

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 20
                color: "#252525"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 16

                Text {
                    text: "\ue88e"
                    font.family: "Material Icons"
                    font.pixelSize: 28
                    color: "#1976D2"
                }

                Text {
                    text: "About"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    color: "#ffffff"
                }

                Item { Layout.fillWidth: true }

                RoundButton {
                    width: 36
                    height: 36
                    flat: true
                    onClicked: aboutPopup.close()

                    Text {
                        anchors.centerIn: parent
                        text: "\ue5cd"
                        font.family: "Material Icons"
                        font.pixelSize: 20
                        color: "#808080"
                    }
                }
            }
        }

        footer: Item { height: 0 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Item { Layout.fillHeight: true }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                Text {
                    text: "\ue897"
                    font.family: "Material Icons"
                    font.pixelSize: 56
                    color: "#1976D2"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Password Manager"
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Version 1.0.0"
                    font.pixelSize: 14
                    color: "#808080"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Secure password storage with TOTP support"
                    font.pixelSize: 13
                    color: "#606060"
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // Export Dialog
    Dialog {
        id: exportDialog
        title: ""
        modal: true
        width: 462
        height: 340
        anchors.centerIn: parent
        padding: 0
        topPadding: 0
        dim: true

        Material.theme: Material.Dark
        Material.accent: "#1976D2"

        property string selectedFormat: "csv"
        property bool exportSuccess: false
        property string locationError: ""

        Overlay.modal: Rectangle {
            color: "#D0000000"
        }

        background: Rectangle {
            color: "#E8141414"
            radius: 16
            border.color: "#404040"
            border.width: 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#80000000"
                shadowBlur: 1.5
                shadowVerticalOffset: 8
            }
        }

        header: Rectangle {
            height: 60
            color: "#252525"
            radius: 16

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 20
                color: "#252525"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 16

                Text {
                    text: exportDialog.exportSuccess ? "\ue86c" : "\ue2c4"
                    font.family: "Material Icons"
                    font.pixelSize: 28
                    color: exportDialog.exportSuccess ? "#4CAF50" : "#1976D2"
                }

                Text {
                    text: exportDialog.exportSuccess ? "Export Successful" : "Export Data"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    color: "#ffffff"
                }

                Item { Layout.fillWidth: true }

                RoundButton {
                    width: 36
                    height: 36
                    flat: true
                    onClicked: exportDialog.close()

                    Text {
                        anchors.centerIn: parent
                        text: "\ue5cd"
                        font.family: "Material Icons"
                        font.pixelSize: 20
                        color: "#808080"
                    }
                }
            }
        }

        footer: Item { height: 0 }

        // Success view
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            visible: exportDialog.exportSuccess

            Item { Layout.fillHeight: true }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                Text {
                    text: "\ue86c"
                    font.family: "Material Icons"
                    font.pixelSize: 56
                    color: "#4CAF50"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Your passwords have been exported successfully!"
                    font.pixelSize: 14
                    color: "#c0c0c0"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: exportLocationField.text
                    font.pixelSize: 12
                    color: "#808080"
                    Layout.alignment: Qt.AlignHCenter
                    elide: Text.ElideMiddle
                    Layout.maximumWidth: 400
                }
            }

            Item { Layout.fillHeight: true }

            Button {
                text: "Done"
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                highlighted: true
                font.weight: Font.Medium
                font.pixelSize: 14
                onClicked: exportDialog.close()
            }
        }

        // Export form view
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12
            visible: !exportDialog.exportSuccess

            // Format selection
            Column {
                Layout.fillWidth: true
                spacing: 6

                Row {
                    spacing: 8

                    Text {
                        text: "\ue873"
                        font.family: "Material Icons"
                        font.pixelSize: 16
                        color: "#1976D2"
                    }

                    Text {
                        text: "Export Format"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: "#ffffff"
                    }
                }

                Row {
                    width: parent.width
                    spacing: 0

                    Rectangle {
                        width: parent.width / 2
                        height: 40
                        topLeftRadius: 8
                        bottomLeftRadius: 8
                        topRightRadius: 0
                        bottomRightRadius: 0
                        color: exportDialog.selectedFormat === "csv" ? "#1976D2" : (csvMouseArea.containsMouse ? "#353535" : "#2a2a2a")
                        border.color: exportDialog.selectedFormat === "csv" ? "#1976D2" : "#404040"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "CSV"
                            font.pixelSize: 14
                            font.weight: exportDialog.selectedFormat === "csv" ? Font.Medium : Font.Normal
                            color: exportDialog.selectedFormat === "csv" ? "#ffffff" : "#a0a0a0"
                        }

                        MouseArea {
                            id: csvMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: exportDialog.selectedFormat = "csv"
                        }
                    }

                    Rectangle {
                        width: parent.width / 2
                        height: 40
                        topLeftRadius: 0
                        bottomLeftRadius: 0
                        topRightRadius: 8
                        bottomRightRadius: 8
                        color: exportDialog.selectedFormat === "json" ? "#1976D2" : (jsonMouseArea.containsMouse ? "#353535" : "#2a2a2a")
                        border.color: exportDialog.selectedFormat === "json" ? "#1976D2" : "#404040"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "JSON"
                            font.pixelSize: 14
                            font.weight: exportDialog.selectedFormat === "json" ? Font.Medium : Font.Normal
                            color: exportDialog.selectedFormat === "json" ? "#ffffff" : "#a0a0a0"
                        }

                        MouseArea {
                            id: jsonMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: exportDialog.selectedFormat = "json"
                        }
                    }
                }
            }

            // Save location
            Column {
                Layout.fillWidth: true
                spacing: 6

                Row {
                    spacing: 8

                    Text {
                        text: "\ue2c8"
                        font.family: "Material Icons"
                        font.pixelSize: 16
                        color: "#1976D2"
                    }

                    Text {
                        text: "Save Location"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: "#ffffff"
                    }
                }

                Row {
                    width: parent.width
                    spacing: 10

                    TextField {
                        id: exportLocationField
                        width: parent.width - exportBrowseButton.width - 10
                        placeholderText: "Choose where to save..."
                        readOnly: true
                    }

                    Button {
                        id: exportBrowseButton
                        text: "Browse"
                        flat: true
                        onClicked: exportFileDialog.open()
                    }
                }

                Text {
                    text: exportDialog.locationError
                    color: "#ef5350"
                    font.pixelSize: 11
                    visible: exportDialog.locationError !== ""
                }
            }

            Item { Layout.fillHeight: true }

            Button {
                text: "Export"
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                highlighted: true
                font.weight: Font.Medium
                font.pixelSize: 14
                onClicked: {
                    if (exportLocationField.text.trim() === "") {
                        exportDialog.locationError = "Please choose a location"
                        return
                    }
                    exportDialog.locationError = ""

                    var success = false
                    if (exportDialog.selectedFormat === "csv") {
                        success = passwordController.exportToCsv(exportLocationField.text)
                    } else {
                        success = passwordController.exportToJson(exportLocationField.text)
                    }

                    if (success) {
                        exportDialog.exportSuccess = true
                    }
                }
            }
        }

        onClosed: {
            exportSuccess = false
            locationError = ""
            exportLocationField.text = ""
        }
    }

    FileDialog {
        id: exportFileDialog
        title: "Export Passwords"
        fileMode: FileDialog.SaveFile
        nameFilters: exportDialog.selectedFormat === "csv"
            ? ["CSV Files (*.csv)"]
            : ["JSON Files (*.json)"]
        currentFile: "file:///" + (vaultController && vaultController.vaultName ? vaultController.vaultName.toLowerCase().replace(/ /g, "-") : "passwords") + (exportDialog.selectedFormat === "csv" ? ".csv" : ".json")
        onAccepted: {
            var path = selectedFile.toString()
            if (path.startsWith("file:///")) {
                path = path.substring(8)
                if (path.length > 1 && path.charAt(1) !== ':') {
                    path = "/" + path
                }
            }
            exportLocationField.text = path
        }
    }

    // Security Settings Dialog
    Dialog {
        id: securityDialog
        title: ""
        modal: true
        width: 480
        height: 520
        anchors.centerIn: parent
        padding: 0
        topPadding: 0
        dim: true

        Material.theme: Material.Dark
        Material.accent: "#1976D2"

        property string nameError: ""
        property string currentPasswordError: ""
        property string newPasswordError: ""
        property string confirmPasswordError: ""
        property bool nameSuccess: false
        property bool passwordSuccess: false

        Overlay.modal: Rectangle {
            color: "#D0000000"
        }

        background: Rectangle {
            color: "#E8141414"
            radius: 16
            border.color: "#404040"
            border.width: 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#80000000"
                shadowBlur: 1.5
                shadowVerticalOffset: 8
            }
        }

        header: Rectangle {
            height: 60
            color: "#252525"
            radius: 16

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 20
                color: "#252525"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 16

                Text {
                    text: "\ue897"
                    font.family: "Material Icons"
                    font.pixelSize: 28
                    color: "#1976D2"
                }

                Text {
                    text: "Security Settings"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    color: "#ffffff"
                }

                Item { Layout.fillWidth: true }

                RoundButton {
                    width: 36
                    height: 36
                    flat: true
                    onClicked: securityDialog.close()

                    Text {
                        anchors.centerIn: parent
                        text: "\ue5cd"
                        font.family: "Material Icons"
                        font.pixelSize: 20
                        color: "#808080"
                    }
                }
            }
        }

        footer: Item { height: 0 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // Change Vault Name Section
            Column {
                Layout.fillWidth: true
                spacing: 6

                Row {
                    spacing: 8

                    Text {
                        text: "\ue8d3"
                        font.family: "Material Icons"
                        font.pixelSize: 16
                        color: "#1976D2"
                    }

                    Text {
                        text: "Vault Name"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: "#ffffff"
                    }
                }

                Row {
                    width: parent.width
                    spacing: 10

                    TextField {
                        id: vaultNameField
                        width: parent.width - changeNameButton.width - 10
                        placeholderText: "Enter new vault name"
                        text: vaultController ? vaultController.vaultName : ""
                    }

                    Button {
                        id: changeNameButton
                        text: "Save"
                        highlighted: true
                        onClicked: {
                            if (vaultNameField.text.trim() === "") {
                                securityDialog.nameError = "Vault name cannot be empty"
                                securityDialog.nameSuccess = false
                                return
                            }
                            if (vaultController.changeVaultName(vaultNameField.text)) {
                                securityDialog.nameError = ""
                                securityDialog.nameSuccess = true
                            } else {
                                securityDialog.nameError = "Failed to change vault name"
                                securityDialog.nameSuccess = false
                            }
                        }
                    }
                }

                Text {
                    text: securityDialog.nameError
                    color: "#ef5350"
                    font.pixelSize: 11
                    visible: securityDialog.nameError !== ""
                }

                Text {
                    text: "Vault name changed successfully"
                    color: "#4CAF50"
                    font.pixelSize: 11
                    visible: securityDialog.nameSuccess
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#3a3a3a"
            }

            // Change Master Password Section
            Column {
                Layout.fillWidth: true
                spacing: 6

                Row {
                    spacing: 8

                    Text {
                        text: "\ue899"
                        font.family: "Material Icons"
                        font.pixelSize: 16
                        color: "#1976D2"
                    }

                    Text {
                        text: "Change Master Password"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: "#ffffff"
                    }
                }

                TextField {
                    id: currentPasswordField
                    width: parent.width
                    placeholderText: "Current password"
                    echoMode: TextInput.Password
                }

                Text {
                    text: securityDialog.currentPasswordError
                    color: "#ef5350"
                    font.pixelSize: 11
                    visible: securityDialog.currentPasswordError !== ""
                }

                TextField {
                    id: newPasswordField
                    width: parent.width
                    placeholderText: "New password"
                    echoMode: TextInput.Password
                }

                Text {
                    text: securityDialog.newPasswordError
                    color: "#ef5350"
                    font.pixelSize: 11
                    visible: securityDialog.newPasswordError !== ""
                }

                TextField {
                    id: confirmNewPasswordField
                    width: parent.width
                    placeholderText: "Confirm new password"
                    echoMode: TextInput.Password
                }

                Text {
                    text: securityDialog.confirmPasswordError
                    color: "#ef5350"
                    font.pixelSize: 11
                    visible: securityDialog.confirmPasswordError !== ""
                }

                Row {
                    spacing: 6

                    Text {
                        text: "\ue88e"
                        font.family: "Material Icons"
                        font.pixelSize: 14
                        color: "#606060"
                    }

                    Text {
                        text: "Min 8 chars with upper, lower, digit && special"
                        font.pixelSize: 11
                        color: "#606060"
                    }
                }

                Text {
                    text: "Password changed successfully"
                    color: "#4CAF50"
                    font.pixelSize: 11
                    visible: securityDialog.passwordSuccess
                }
            }

            Item { Layout.fillHeight: true }

            Button {
                text: "Change Password"
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                highlighted: true
                font.weight: Font.Medium
                font.pixelSize: 14
                onClicked: {
                    var valid = true
                    securityDialog.currentPasswordError = ""
                    securityDialog.newPasswordError = ""
                    securityDialog.confirmPasswordError = ""
                    securityDialog.passwordSuccess = false

                    if (currentPasswordField.text === "") {
                        securityDialog.currentPasswordError = "Current password is required"
                        valid = false
                    }

                    if (!vaultController.validateMasterPassword(newPasswordField.text)) {
                        securityDialog.newPasswordError = "Password doesn't meet requirements"
                        valid = false
                    }

                    if (newPasswordField.text !== confirmNewPasswordField.text) {
                        securityDialog.confirmPasswordError = "Passwords do not match"
                        valid = false
                    }

                    if (!valid) return

                    if (vaultController.changeMasterPassword(currentPasswordField.text, newPasswordField.text)) {
                        securityDialog.passwordSuccess = true
                        currentPasswordField.text = ""
                        newPasswordField.text = ""
                        confirmNewPasswordField.text = ""
                    } else {
                        securityDialog.currentPasswordError = "Current password is incorrect"
                    }
                }
            }
        }

        onClosed: {
            nameError = ""
            currentPasswordError = ""
            newPasswordError = ""
            confirmPasswordError = ""
            nameSuccess = false
            passwordSuccess = false
            currentPasswordField.text = ""
            newPasswordField.text = ""
            confirmNewPasswordField.text = ""
        }

        onOpened: {
            vaultNameField.text = vaultController ? vaultController.vaultName : ""
        }
    }

    // Keyboard shortcuts
    Shortcut {
        sequence: "Ctrl+F"
        onActivated: searchField.forceActiveFocus()
    }

    Shortcut {
        sequence: "Ctrl+N"
        onActivated: {
            cancelEdit()
            websiteField.focus = true
        }
    }

    Shortcut {
        sequence: "Ctrl+L"
        onActivated: {
            vaultController.closeVault()
            root.vaultUnlocked = false
        }
    }

    Shortcut {
        sequence: "Ctrl+G"
        onActivated: generatorPopup.open()
    }

    Shortcut {
        sequence: "Ctrl+,"
        onActivated: sidebarExpanded = !sidebarExpanded
    }

    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (generatorPopup.visible) generatorPopup.close()
            else if (shortcutsPopup.visible) shortcutsPopup.close()
            else if (aboutPopup.visible) aboutPopup.close()
            else if (editMode) cancelEdit()
            else if (searchField.activeFocus) {
                searchField.text = ""
                searchField.focus = false
            }
        }
    }
}
