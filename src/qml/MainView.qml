import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects

Item {
    id: mainView

    // Edit mode state
    property bool editMode: false
    property int editingRow: -1

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
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 15

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

        // Password list (left panel)
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
                            text: "Saved Passwords"
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
                            Layout.preferredWidth: 100
                        }
                    }
                }

                // Password list
                ListView {
                    id: passwordList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: vaultController ? vaultController.passwordModel : null

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: Rectangle {
                        id: delegateItem
                        width: passwordList.width
                        height: 56
                        color: editMode && editingRow === index ? "#1976D2" + "30" : (mouseArea.containsMouse ? "#2f2f2f" : "transparent")

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
                                    onClicked: vaultController.openWebsite(index)
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
                                    onClicked: vaultController.copyUsername(index)
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
                                    onClicked: vaultController.copyPassword(index)
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
                                            return model.hasTotp ? vaultController.generateTotp(index) : ""
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
                                    onClicked: vaultController.copyTotp(index)
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
                                Layout.preferredWidth: 100
                                opacity: mouseArea.containsMouse ? 1 : 0.6

                                Behavior on opacity {
                                    NumberAnimation { duration: 150 }
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
                                    onClicked: vaultController.togglePasswordVisibility(index)

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
                                    onClicked: vaultController.deleteEntry(index)

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
                        text: vaultController ? vaultController.urlError : ""
                        color: "#ef5350"
                        font.pixelSize: 11
                        visible: vaultController && vaultController.urlError !== ""
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
                        text: vaultController ? vaultController.usernameError : ""
                        color: "#ef5350"
                        font.pixelSize: 11
                        visible: vaultController && vaultController.usernameError !== ""
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
                        text: vaultController ? vaultController.passwordError : ""
                        color: "#ef5350"
                        font.pixelSize: 11
                        visible: vaultController && vaultController.passwordError !== ""
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
                        text: vaultController ? vaultController.totpError : ""
                        color: "#ef5350"
                        font.pixelSize: 11
                        visible: vaultController && vaultController.totpError !== ""
                    }

                    Text {
                        text: "Base32 secret for 2FA codes"
                        font.pixelSize: 10
                        color: "#606060"
                        visible: !vaultController || vaultController.totpError === ""
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
        websiteField.text = vaultController.getWebsite(row)
        usernameField.text = vaultController.getUsername(row)
        passwordField.text = vaultController.getPassword(row)
        totpField.text = vaultController.getTotpKey(row)
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
        if (vaultController && vaultController.addEntry(websiteField.text, usernameField.text, passwordField.text, totpField.text)) {
            websiteField.text = ""
            usernameField.text = ""
            passwordField.text = ""
            totpField.text = ""
            websiteField.focus = true
        }
    }

    function updateEntry() {
        if (vaultController && vaultController.updateEntry(editingRow, websiteField.text, usernameField.text, passwordField.text, totpField.text)) {
            cancelEdit()
        }
    }
}
