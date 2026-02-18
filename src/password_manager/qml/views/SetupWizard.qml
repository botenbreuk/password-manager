import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"

AppDialog {
    id: setupDialog
    width: 500
    height: 620
    headerIcon: "\ue899"
    headerTitle: "Create New Vault"

    signal vaultCreated()

    property string nameError: ""
    property string passwordError: ""
    property string confirmError: ""
    property string locationError: ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        // Step 1: Vault name
        Column {
            Layout.fillWidth: true
            spacing: 6

            SectionHeader {
                icon: "\ue8d3"
                label: "Vault Name"
            }

            TextField {
                id: nameField
                width: parent.width
                placeholderText: "e.g., Personal, Work, Family"
            }

            ErrorText {
                errorMessage: setupDialog.nameError
            }
        }

        // Step 2: Master password
        Column {
            Layout.fillWidth: true
            spacing: 6

            SectionHeader {
                icon: "\ue897"
                label: "Master Password"
            }

            TextField {
                id: passwordField
                width: parent.width
                placeholderText: "Create a strong password"
                echoMode: TextInput.Password
            }

            ErrorText {
                errorMessage: setupDialog.passwordError
            }

            TextField {
                id: confirmField
                width: parent.width
                placeholderText: "Confirm your password"
                echoMode: TextInput.Password
            }

            ErrorText {
                errorMessage: setupDialog.confirmError
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

            SectionHeader {
                icon: "\ue2c8"
                label: "Save Location"
            }

            BrowseFileRow {
                id: locationRow
                placeholderText: "Choose where to save..."
                dialogTitle: "Save Vault File"
                nameFilters: ["Vault Files (*.vault)"]
                fileMode: FileDialog.SaveFile
                currentFile: "file:///" + (nameField.text ? nameField.text.toLowerCase().replace(/ /g, "-") : "vault") + ".vault"
            }

            ErrorText {
                errorMessage: setupDialog.locationError
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

        if (locationRow.text.trim() === "") {
            locationError = "Please choose a location"
            valid = false
        } else {
            locationError = ""
        }

        if (!valid) return

        vaultController.createVault(locationRow.text, nameField.text.trim(), passwordField.text)
    }

    onOpened: {
        nameField.text = ""
        passwordField.text = ""
        confirmField.text = ""
        locationRow.text = ""
        nameError = ""
        passwordError = ""
        confirmError = ""
        locationError = ""
    }
}
