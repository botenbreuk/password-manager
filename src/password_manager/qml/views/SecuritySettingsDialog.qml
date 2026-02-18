import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

AppDialog {
    id: securityDialog
    width: 480
    height: 520
    headerIcon: "\ue897"
    headerTitle: "Security Settings"

    property string nameError: ""
    property string currentPasswordError: ""
    property string newPasswordError: ""
    property string confirmPasswordError: ""
    property bool nameSuccess: false
    property bool passwordSuccess: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Change Vault Name Section
        Column {
            Layout.fillWidth: true
            spacing: 6

            SectionHeader {
                icon: "\ue8d3"
                label: "Vault Name"
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

            ErrorText {
                errorMessage: securityDialog.nameError
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

            SectionHeader {
                icon: "\ue899"
                label: "Change Master Password"
            }

            TextField {
                id: currentPasswordField
                width: parent.width
                placeholderText: "Current password"
                echoMode: TextInput.Password
            }

            ErrorText {
                errorMessage: securityDialog.currentPasswordError
            }

            TextField {
                id: newPasswordField
                width: parent.width
                placeholderText: "New password"
                echoMode: TextInput.Password
            }

            ErrorText {
                errorMessage: securityDialog.newPasswordError
            }

            TextField {
                id: confirmNewPasswordField
                width: parent.width
                placeholderText: "Confirm new password"
                echoMode: TextInput.Password
            }

            ErrorText {
                errorMessage: securityDialog.confirmPasswordError
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
