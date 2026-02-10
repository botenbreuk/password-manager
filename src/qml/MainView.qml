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
                        Item {
                            Layout.preferredWidth: 144
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

                            Text {
                                text: model.website
                                font.pixelSize: 14
                                color: "#ffffff"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                            }
                            Text {
                                text: model.username
                                font.pixelSize: 14
                                color: "#a0a0a0"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                            }
                            Text {
                                text: model.visible ? model.password : "\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022"
                                font.pixelSize: 14
                                color: "#a0a0a0"
                                font.letterSpacing: model.visible ? 0 : 2
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                            }

                            Row {
                                spacing: 4
                                Layout.preferredWidth: 144
                                opacity: mouseArea.containsMouse ? 1 : 0.6

                                Behavior on opacity {
                                    NumberAnimation { duration: 150 }
                                }

                                RoundButton {
                                    width: 34
                                    height: 34
                                    flat: true
                                    ToolTip.visible: hovered
                                    ToolTip.text: "Edit"
                                    onClicked: startEdit(index)

                                    Text {
                                        anchors.centerIn: parent
                                        text: "\ue3c9"
                                        font.family: "Material Icons"
                                        font.pixelSize: 18
                                        color: "#1976D2"
                                    }
                                }
                                RoundButton {
                                    width: 34
                                    height: 34
                                    flat: true
                                    ToolTip.visible: hovered
                                    ToolTip.text: "Copy password"
                                    onClicked: vaultController.copyPassword(index)

                                    Text {
                                        anchors.centerIn: parent
                                        text: "\ue14d"
                                        font.family: "Material Icons"
                                        font.pixelSize: 18
                                        color: "#e0e0e0"
                                    }
                                }
                                RoundButton {
                                    width: 34
                                    height: 34
                                    flat: true
                                    ToolTip.visible: hovered
                                    ToolTip.text: model.visible ? "Hide password" : "Show password"
                                    onClicked: vaultController.togglePasswordVisibility(index)

                                    Text {
                                        anchors.centerIn: parent
                                        text: model.visible ? "\ue8f4" : "\ue8f5"
                                        font.family: "Material Icons"
                                        font.pixelSize: 18
                                        color: "#e0e0e0"
                                    }
                                }
                                RoundButton {
                                    width: 34
                                    height: 34
                                    flat: true
                                    ToolTip.visible: hovered
                                    ToolTip.text: "Delete"
                                    onClicked: vaultController.deleteEntry(index)

                                    Text {
                                        anchors.centerIn: parent
                                        text: "\ue872"
                                        font.family: "Material Icons"
                                        font.pixelSize: 18
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
                spacing: 16

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
                    spacing: 6

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
                    spacing: 6

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
                    spacing: 6

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
                        onAccepted: editMode ? updateEntry() : addEntry()
                    }

                    Text {
                        text: vaultController ? vaultController.passwordError : ""
                        color: "#ef5350"
                        font.pixelSize: 11
                        visible: vaultController && vaultController.passwordError !== ""
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
        websiteField.focus = true
    }

    function cancelEdit() {
        editMode = false
        editingRow = -1
        websiteField.text = ""
        usernameField.text = ""
        passwordField.text = ""
    }

    function addEntry() {
        if (vaultController && vaultController.addEntry(websiteField.text, usernameField.text, passwordField.text)) {
            websiteField.text = ""
            usernameField.text = ""
            passwordField.text = ""
            websiteField.focus = true
        }
    }

    function updateEntry() {
        if (vaultController && vaultController.updateEntry(editingRow, websiteField.text, usernameField.text, passwordField.text)) {
            cancelEdit()
        }
    }
}
