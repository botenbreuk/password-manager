import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../components"

Rectangle {
    id: securityView
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#252525"
    radius: 12

    property string nameError: ""
    property string currentPasswordError: ""
    property string newPasswordError: ""
    property string confirmPasswordError: ""
    property bool nameSuccess: false
    property bool passwordSuccess: false

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#40000000"
        shadowBlur: 0.5
        shadowVerticalOffset: 2
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // Header
        Row {
            spacing: 10

            Text {
                text: "\ue897"
                font.family: "Material Icons"
                font.pixelSize: 28
                color: "#b0b0b0"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Security Settings"
                font.pixelSize: 20
                font.weight: Font.Medium
                color: "#e0e0e0"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#3a3a3a"
        }

        // Change Vault Name Section
        Column {
            Layout.fillWidth: true
            Layout.maximumWidth: 480
            spacing: 12

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
                            securityView.nameError = "Vault name cannot be empty"
                            securityView.nameSuccess = false
                            return
                        }
                        if (vaultController.changeVaultName(vaultNameField.text)) {
                            securityView.nameError = ""
                            securityView.nameSuccess = true
                        } else {
                            securityView.nameError = "Failed to change vault name"
                            securityView.nameSuccess = false
                        }
                    }
                }
            }

            ErrorText {
                errorMessage: securityView.nameError
            }

            Text {
                text: "Vault name changed successfully"
                color: "#4CAF50"
                font.pixelSize: 11
                visible: securityView.nameSuccess
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.maximumWidth: 480
            height: 1
            color: "#3a3a3a"
        }

        // Change Master Password Section
        Column {
            Layout.fillWidth: true
            Layout.maximumWidth: 480
            spacing: 12

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
                errorMessage: securityView.currentPasswordError
            }

            TextField {
                id: newPasswordField
                width: parent.width
                placeholderText: "New password"
                echoMode: TextInput.Password
            }

            ErrorText {
                errorMessage: securityView.newPasswordError
            }

            TextField {
                id: confirmNewPasswordField
                width: parent.width
                placeholderText: "Confirm new password"
                echoMode: TextInput.Password
            }

            ErrorText {
                errorMessage: securityView.confirmPasswordError
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
                visible: securityView.passwordSuccess
            }

            Button {
                text: "Change Password"
                width: parent.width
                height: 44
                highlighted: true
                font.weight: Font.Medium
                font.pixelSize: 14
                onClicked: {
                    var valid = true
                    securityView.currentPasswordError = ""
                    securityView.newPasswordError = ""
                    securityView.confirmPasswordError = ""
                    securityView.passwordSuccess = false

                    if (currentPasswordField.text === "") {
                        securityView.currentPasswordError = "Current password is required"
                        valid = false
                    }

                    if (!vaultController.validateMasterPassword(newPasswordField.text)) {
                        securityView.newPasswordError = "Password doesn't meet requirements"
                        valid = false
                    }

                    if (newPasswordField.text !== confirmNewPasswordField.text) {
                        securityView.confirmPasswordError = "Passwords do not match"
                        valid = false
                    }

                    if (!valid) return

                    if (vaultController.changeMasterPassword(currentPasswordField.text, newPasswordField.text)) {
                        securityView.passwordSuccess = true
                        currentPasswordField.text = ""
                        newPasswordField.text = ""
                        confirmNewPasswordField.text = ""
                    } else {
                        securityView.currentPasswordError = "Current password is incorrect"
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
