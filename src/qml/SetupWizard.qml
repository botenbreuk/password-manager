import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material

Dialog {
    id: setupDialog
    title: "Create New Vault"
    modal: true
    width: 450
    height: 550
    anchors.centerIn: parent
    standardButtons: Dialog.Cancel

    Material.theme: Material.Dark
    Material.accent: Material.Blue

    signal vaultCreated()

    property string nameError: ""
    property string passwordError: ""
    property string confirmError: ""
    property string locationError: ""

    background: Rectangle {
        color: "#2d2d2d"
        border.color: "#3d3d3d"
        radius: 8
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        // Header
        Text {
            text: "Setup Your Password Vault"
            font.bold: true
            font.pixelSize: 18
            color: "#e0e0e0"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "Create a secure vault to store your passwords.\nThe database will be encrypted with your master password."
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            color: "#888"
        }

        // Step 1: Vault name
        Text {
            text: "Step 1: Choose a name for your vault"
            font.bold: true
            color: "#e0e0e0"
            Layout.topMargin: 10
        }

        TextField {
            id: nameField
            Layout.fillWidth: true
            placeholderText: "e.g., Personal, Work, Family"
        }
        Text {
            text: nameError
            color: "#ff6b6b"
            font.pixelSize: 11
            visible: nameError !== ""
        }

        // Step 2: Master password
        Text {
            text: "Step 2: Create a master password"
            font.bold: true
            color: "#e0e0e0"
            Layout.topMargin: 10
        }

        TextField {
            id: passwordField
            Layout.fillWidth: true
            placeholderText: "Master password"
            echoMode: TextInput.Password
        }
        Text {
            text: passwordError
            color: "#ff6b6b"
            font.pixelSize: 11
            visible: passwordError !== ""
        }

        TextField {
            id: confirmField
            Layout.fillWidth: true
            placeholderText: "Confirm master password"
            echoMode: TextInput.Password
        }
        Text {
            text: confirmError
            color: "#ff6b6b"
            font.pixelSize: 11
            visible: confirmError !== ""
        }

        // Step 3: Vault location
        Text {
            text: "Step 3: Choose where to save your vault"
            font.bold: true
            color: "#e0e0e0"
            Layout.topMargin: 10
        }

        RowLayout {
            Layout.fillWidth: true

            TextField {
                id: locationField
                Layout.fillWidth: true
                placeholderText: "Vault file location"
                readOnly: true
            }

            Button {
                text: "Browse..."
                onClicked: fileDialog.open()
            }
        }
        Text {
            text: locationError
            color: "#ff6b6b"
            font.pixelSize: 11
            visible: locationError !== ""
        }

        Item {
            Layout.fillHeight: true
        }

        Button {
            text: "Create Vault"
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            highlighted: true
            onClicked: createVault()
        }
    }

    FileDialog {
        id: fileDialog
        title: "Save Vault File"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Vault Files (*.vault)"]
        currentFile: "file:///" + (nameField.text || "vault") + ".vault"
        onAccepted: {
            var path = selectedFile.toString()
            if (path.startsWith("file://")) {
                path = path.substring(7)
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
            passwordError = "Min 8 chars, upper, lower, digit, special"
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
            locationError = "Please choose a location for your vault"
            valid = false
        } else {
            locationError = ""
        }

        if (!valid) return

        vaultController.createVault(locationField.text, nameField.text.trim(), passwordField.text)
        setupDialog.close()
        vaultCreated()
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
