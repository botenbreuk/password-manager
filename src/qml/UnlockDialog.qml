import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material
import QtQuick.Effects

Item {
    id: unlockView

    signal unlockSuccessful()
    signal createNewVault()

    property string fileError: ""
    property string passwordError: ""
    property string selectedVaultPath: ""

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1a1a1a" }
            GradientStop { position: 1.0; color: "#252525" }
        }

        Column {
            anchors.centerIn: parent
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
            Rectangle {
                width: parent.width
                height: formColumn.height + 48
                color: "#252525"
                radius: 16

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "#40000000"
                    shadowBlur: 1.0
                    shadowVerticalOffset: 4
                }

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

                        Text {
                            text: fileError
                            color: "#ef5350"
                            font.pixelSize: 12
                            visible: fileError !== ""
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

                        Text {
                            text: passwordError
                            color: "#ef5350"
                            font.pixelSize: 12
                            visible: passwordError !== ""
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
                    text: "Unlock Vault"
                    highlighted: true
                    font.weight: Font.Medium
                    font.pixelSize: 15
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

    FileDialog {
        id: openFileDialog
        title: "Open Vault File"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Vault Files (*.vault)"]
        onAccepted: {
            var path = selectedFile.toString()
            if (path.startsWith("file://")) {
                path = path.substring(7)
            }
            selectedVaultPath = path
            fileField.text = path
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

        if (vaultController.openVault(selectedVaultPath, passwordField.text)) {
            unlockSuccessful()
        } else {
            passwordError = "Failed to unlock vault. Incorrect password?"
        }
    }
}
