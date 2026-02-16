import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material
import QtQuick.Effects

Dialog {
    id: setupDialog
    title: ""
    modal: true
    width: 500
    height: 620
    anchors.centerIn: parent
    padding: 0
    topPadding: 0
    dim: true

    Material.theme: Material.Dark
    Material.accent: "#1976D2"

    signal vaultCreated()

    property string nameError: ""
    property string passwordError: ""
    property string confirmError: ""
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

    // Custom header
    header: Rectangle {
        height: 70
        color: "#252525"
        radius: 16

        // Bottom corners should not be rounded
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
            anchors.rightMargin: 24

            Text {
                text: "\ue899"
                font.family: "Material Icons"
                font.pixelSize: 28
                color: "#1976D2"
            }

            Text {
                text: "Create New Vault"
                font.pixelSize: 20
                font.weight: Font.DemiBold
                color: "#ffffff"
            }

            Item { Layout.fillWidth: true }

            RoundButton {
                width: 36
                height: 36
                flat: true
                onClicked: setupDialog.close()

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

    // Remove default footer
    footer: Item { height: 0 }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        // Step 1: Vault name
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

            TextField {
                id: nameField
                width: parent.width
                placeholderText: "e.g., Personal, Work, Family"
            }

            Text {
                text: nameError
                color: "#ef5350"
                font.pixelSize: 11
                visible: nameError !== ""
            }
        }

        // Step 2: Master password
        Column {
            Layout.fillWidth: true
            spacing: 6

            Row {
                spacing: 8

                Text {
                    text: "\ue897"
                    font.family: "Material Icons"
                    font.pixelSize: 16
                    color: "#1976D2"
                }

                Text {
                    text: "Master Password"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: "#ffffff"
                }
            }

            TextField {
                id: passwordField
                width: parent.width
                placeholderText: "Create a strong password"
                echoMode: TextInput.Password
            }

            Text {
                text: passwordError
                color: "#ef5350"
                font.pixelSize: 11
                visible: passwordError !== ""
            }

            TextField {
                id: confirmField
                width: parent.width
                placeholderText: "Confirm your password"
                echoMode: TextInput.Password
            }

            Text {
                text: confirmError
                color: "#ef5350"
                font.pixelSize: 11
                visible: confirmError !== ""
            }

            // Password requirements hint
            Row {
                spacing: 6

                Text {
                    text: "\ue88e"
                    font.family: "Material Icons"
                    font.pixelSize: 14
                    color: "#606060"
                }

                Text {
                    text: "Min 8 chars with upper, lower, digit & special"
                    font.pixelSize: 11
                    color: "#606060"
                }
            }
        }

        // Step 3: Location
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
                    id: locationField
                    width: parent.width - browseButton.width - 10
                    placeholderText: "Choose where to save..."
                    readOnly: true
                }

                Button {
                    id: browseButton
                    text: "Browse"
                    flat: true
                    onClicked: fileDialog.open()
                }
            }

            Text {
                text: locationError
                color: "#ef5350"
                font.pixelSize: 11
                visible: locationError !== ""
            }
        }

        Item {
            Layout.preferredHeight: 20
        }

        // Create button
        Button {
            text: vaultController && vaultController.loading ? "Creating..." : "Create Vault"
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            highlighted: true
            font.weight: Font.Medium
            font.pixelSize: 14
            enabled: !vaultController || !vaultController.loading
            onClicked: createVault()
        }
    }

    Connections {
        target: vaultController
        function onVaultCreated() {
            setupDialog.close()
            vaultCreated()
        }
        function onVaultError(error) {
            locationError = error || "Failed to create vault"
        }
    }

    FileDialog {
        id: fileDialog
        title: "Save Vault File"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Vault Files (*.vault)"]
        currentFile: "file:///" + (nameField.text ? nameField.text.toLowerCase().replace(/ /g, "-") : "vault") + ".vault"
        onAccepted: {
            var path = selectedFile.toString()
            // Handle file:// URL - on Windows it's file:///C:/ so check for drive letter
            if (path.startsWith("file:///")) {
                path = path.substring(8)
                // On Unix, paths start with /, so we need file:///path -> /path
                // On Windows, paths start with drive letter, so file:///C:/path -> C:/path
                if (path.length > 1 && path.charAt(1) !== ':') {
                    path = "/" + path
                }
            }
            locationField.text = path
        }
    }

    function createVault() {
        var valid = true

        if (nameField.text.trim() === "") {
            nameError = "Vault name is required"
            valid = false
        } else {
            nameError = ""
        }

        if (!vaultController.validateMasterPassword(passwordField.text)) {
            passwordError = "Password doesn't meet requirements"
            valid = false
        } else {
            passwordError = ""
        }

        if (passwordField.text !== confirmField.text) {
            confirmError = "Passwords do not match"
            valid = false
        } else {
            confirmError = ""
        }

        if (locationField.text.trim() === "") {
            locationError = "Please choose a location"
            valid = false
        } else {
            locationError = ""
        }

        if (!valid) return

        vaultController.createVault(locationField.text, nameField.text.trim(), passwordField.text)
    }

    onOpened: {
        nameField.text = ""
        passwordField.text = ""
        confirmField.text = ""
        locationField.text = ""
        nameError = ""
        passwordError = ""
        confirmError = ""
        locationError = ""
    }
}
