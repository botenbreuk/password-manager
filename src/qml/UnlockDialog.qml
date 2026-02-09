import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material

Item {
    id: unlockView

    signal unlockSuccessful()
    signal createNewVault()

    property string fileError: ""
    property string passwordError: ""
    property string selectedVaultPath: ""

    Rectangle {
        anchors.fill: parent
        color: "#1e1e1e"

        ColumnLayout {
            anchors.centerIn: parent
            width: 400
            spacing: 20

            // Header
            Text {
                text: "🔐"
                font.pixelSize: 48
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Unlock Your Vault"
                font.bold: true
                font.pixelSize: 24
                color: "#e0e0e0"
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                height: contentColumn.height + 40
                color: "#2d2d2d"
                border.color: "#3d3d3d"
                border.width: 1
                radius: 8

                ColumnLayout {
                    id: contentColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20
                    spacing: 15

                    // Vault file selection
                    Text {
                        text: "Vault file:"
                        color: "#e0e0e0"
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        TextField {
                            id: fileField
                            Layout.fillWidth: true
                            placeholderText: "Select vault file..."
                            readOnly: true
                            text: selectedVaultPath
                        }

                        Button {
                            text: "Browse..."
                            onClicked: openFileDialog.open()
                        }
                    }
                    Text {
                        text: fileError
                        color: "#ff6b6b"
                        font.pixelSize: 11
                        visible: fileError !== ""
                    }

                    // Password input
                    Text {
                        text: "Master password:"
                        color: "#e0e0e0"
                        Layout.topMargin: 10
                    }

                    TextField {
                        id: passwordField
                        Layout.fillWidth: true
                        placeholderText: "Enter your master password"
                        echoMode: TextInput.Password
                        onAccepted: unlock()
                    }
                    Text {
                        text: passwordError
                        color: "#ff6b6b"
                        font.pixelSize: 11
                        visible: passwordError !== ""
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Create New Vault"
                    flat: true
                    onClicked: createNewVault()
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "Unlock"
                    highlighted: true
                    onClicked: unlock()
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
