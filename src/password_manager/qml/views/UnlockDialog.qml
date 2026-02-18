import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Effects
import "../components"

Item {
    id: unlockView

    signal unlockSuccessful()
    signal createNewVault()

    property string fileError: ""
    property string passwordError: ""
    property string selectedVaultPath: ""
    property int missingVaultIndex: -1

    Rectangle {
        anchors.fill: parent
        color: "#1e1e1e"

        Row {
            anchors.centerIn: parent
            spacing: 40

            // Recent vaults panel (left)
            ShadowCard {
                width: 280
                height: mainColumn.height

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Row {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: "\ue889"
                            font.family: "Material Icons"
                            font.pixelSize: 20
                            color: "#1976D2"
                        }

                        Text {
                            text: "Recent Vaults"
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: "#ffffff"
                        }

                        Item { width: 1; Layout.fillWidth: true }

                        Text {
                            text: "Clear"
                            font.pixelSize: 12
                            color: clearMouseArea.containsMouse ? "#1976D2" : "#606060"
                            visible: vaultController && vaultController.recentVaultsModel.rowCount() > 0
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            MouseArea {
                                id: clearMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: vaultController.clearRecentVaults()
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#3a3a3a"
                    }

                    // Empty state
                    Column {
                        width: parent.width
                        spacing: 8
                        visible: !vaultController || vaultController.recentVaultsModel.rowCount() === 0
                        topPadding: 40

                        Text {
                            text: "\ue889"
                            font.family: "Material Icons"
                            font.pixelSize: 48
                            color: "#404040"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "No recent vaults"
                            font.pixelSize: 14
                            color: "#606060"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Vaults you open will appear here"
                            font.pixelSize: 12
                            color: "#505050"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    ListView {
                        id: recentVaultsList
                        width: parent.width
                        height: Math.min(contentHeight, 300)
                        clip: true
                        spacing: 4
                        visible: vaultController && vaultController.recentVaultsModel.rowCount() > 0
                        model: vaultController ? vaultController.recentVaultsModel : null

                        delegate: Rectangle {
                            width: recentVaultsList.width
                            height: 52
                            radius: 8
                            color: vaultMouseArea.containsMouse ? "#353535" : "#00353535"

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            MouseArea {
                                id: vaultMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (vaultController.vaultExists(model.path)) {
                                        selectedVaultPath = model.path
                                        fileField.text = model.path
                                        passwordField.forceActiveFocus()
                                    } else {
                                        missingVaultIndex = index
                                        missingVaultDialog.open()
                                    }
                                }
                            }

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 8
                                spacing: 12

                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 8
                                    color: "#1976D2"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: model.name ? model.name.charAt(0).toUpperCase() : "V"
                                        font.pixelSize: 16
                                        font.weight: Font.Bold
                                        color: "#ffffff"
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 36 - 44 - 24
                                    spacing: 2

                                    Text {
                                        text: model.name ? model.name.charAt(0).toUpperCase() + model.name.slice(1) : "Vault"
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        color: "#ffffff"
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                    Text {
                                        text: {
                                            var path = model.path || ""
                                            var parts = path.split("/")
                                            return parts[parts.length - 1] || path
                                        }
                                        font.pixelSize: 11
                                        color: "#707070"
                                        elide: Text.ElideMiddle
                                        width: parent.width
                                    }
                                }

                                Rectangle {
                                    id: removeButton
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: removeMouseArea.containsMouse ? "#404040" : "transparent"
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: vaultMouseArea.containsMouse || removeMouseArea.containsMouse

                                    Text {
                                        anchors.centerIn: parent
                                        text: "\ue5cd"
                                        font.family: "Material Icons"
                                        font.pixelSize: 16
                                        color: removeMouseArea.containsMouse ? "#a0a0a0" : "#707070"
                                    }

                                    MouseArea {
                                        id: removeMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: function(mouse) {
                                            mouse.accepted = true
                                            var idx = index
                                            vaultController.removeRecentVault(idx)
                                        }
                                    }

                                    ToolTip.visible: removeMouseArea.containsMouse
                                    ToolTip.text: "Remove from list"
                                }
                            }
                        }
                    }
                }
            }

            // Main unlock form (right or center)
            Column {
                id: mainColumn
                width: 380
                spacing: 24

                // Lock icon
                Rectangle {
                    width: 72
                    height: 72
                    radius: 36
                    color: "#2a2a2a"
                    anchors.horizontalCenter: parent.horizontalCenter

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#1976D2"
                        shadowBlur: 0.8
                        shadowOpacity: 0.3
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "\ue897"
                        font.family: "Material Icons"
                        font.pixelSize: 36
                        color: "#1976D2"
                    }
                }

                // Title
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "Welcome Back"
                        font.pixelSize: 26
                        font.weight: Font.DemiBold
                        color: "#ffffff"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Enter your credentials to unlock your vault"
                        font.pixelSize: 14
                        color: "#808080"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                // Main card with all form fields
                ShadowCard {
                    width: parent.width
                    height: formColumn.height + 48

                    Column {
                        id: formColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 24
                        spacing: 20

                        // Vault file section
                        Column {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "Vault File"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#a0a0a0"
                            }

                            Row {
                                width: parent.width
                                spacing: 10

                                TextField {
                                    id: fileField
                                    width: parent.width - browseBtn.width - 10
                                    placeholderText: "Select your vault file..."
                                    readOnly: true
                                    text: selectedVaultPath
                                }

                                Button {
                                    id: browseBtn
                                    text: "Browse"
                                    flat: true
                                    onClicked: openFileDialog.open()
                                }
                            }

                            ErrorText {
                                errorMessage: unlockView.fileError
                                fontSize: 12
                            }
                        }

                        // Password section
                        Column {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "Master Password"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#a0a0a0"
                            }

                            TextField {
                                id: passwordField
                                width: parent.width
                                placeholderText: "Enter your master password"
                                echoMode: TextInput.Password
                                onAccepted: unlock()
                            }

                            ErrorText {
                                errorMessage: unlockView.passwordError
                                fontSize: 12
                            }
                        }
                    }
                }

                // Buttons
                Column {
                    width: parent.width
                    spacing: 12

                    Button {
                        width: parent.width
                        height: 48
                        text: vaultController && vaultController.loading ? "Unlocking..." : "Unlock Vault"
                        highlighted: true
                        font.weight: Font.Medium
                        font.pixelSize: 15
                        enabled: !vaultController || !vaultController.loading
                        onClicked: unlock()
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#353535"
                    }

                    Button {
                        width: parent.width
                        height: 44
                        text: "Create New Vault"
                        flat: true
                        onClicked: createNewVault()
                    }
                }
            }
        }
    }

    MissingVaultDialog {
        id: missingVaultDialog
        onRemoveRequested: {
            vaultController.removeRecentVault(missingVaultIndex)
            missingVaultIndex = -1
        }
    }

    FileDialog {
        id: openFileDialog
        title: "Open Vault File"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Vault Files (*.vault)"]
        onAccepted: {
            var path = selectedFile.toString()
            if (path.startsWith("file:///")) {
                path = path.substring(8)
                if (path.length > 1 && path.charAt(1) !== ':') {
                    path = "/" + path
                }
            }
            selectedVaultPath = path
            fileField.text = path
        }
    }

    Connections {
        target: vaultController
        function onVaultOpened() {
            unlockSuccessful()
        }
        function onVaultError(error) {
            passwordError = error || "Failed to unlock vault. Incorrect password?"
        }
    }

    function unlock() {
        var valid = true

        if (selectedVaultPath === "") {
            fileError = "Please select a vault file"
            valid = false
        } else {
            fileError = ""
        }

        if (passwordField.text === "") {
            passwordError = "Password is required"
            valid = false
        } else {
            passwordError = ""
        }

        if (!valid) return

        vaultController.openVault(selectedVaultPath, passwordField.text)
    }
}
