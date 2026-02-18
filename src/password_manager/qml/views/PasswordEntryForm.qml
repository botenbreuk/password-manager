import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

Rectangle {
    id: entryForm
    Layout.fillHeight: true
    Layout.preferredWidth: 280
    color: "#252525"
    radius: 12

    property bool editMode: false

    signal addRequested(string website, string username, string password, string totpKey)
    signal updateRequested(string website, string username, string password, string totpKey)
    signal cancelRequested()
    signal openGenerator()

    function setPassword(pw) {
        passwordField.text = pw
    }

    function loadEntry(website, username, password, totpKey) {
        websiteField.text = website
        usernameField.text = username
        passwordField.text = password
        totpField.text = totpKey
        websiteField.field.forceActiveFocus()
    }

    function clearFields() {
        websiteField.text = ""
        usernameField.text = ""
        passwordField.text = ""
        totpField.text = ""
    }

    function focusWebsite() {
        websiteField.field.forceActiveFocus()
    }

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
                text: entryForm.editMode ? "\ue3c9" : "\ue145"
                font.family: "Material Icons"
                font.pixelSize: 22
                color: "#1976D2"
            }

            Text {
                text: entryForm.editMode ? "Edit Entry" : "Add New Entry"
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

        FormField {
            id: websiteField
            label: "Website"
            placeholderText: "e.g., github.com"
            errorMessage: passwordController ? passwordController.urlError : ""
            field.onAccepted: usernameField.field.forceActiveFocus()
        }

        FormField {
            id: usernameField
            label: "Username"
            placeholderText: "e.g., john@email.com"
            errorMessage: passwordController ? passwordController.usernameError : ""
            field.onAccepted: passwordField.field.forceActiveFocus()
        }

        FormField {
            id: passwordField
            label: "Password"
            placeholderText: "Enter password"
            isPassword: true
            errorMessage: passwordController ? passwordController.passwordError : ""
            field.onAccepted: totpField.forceActiveFocus()
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
                onAccepted: entryForm.editMode ? entryForm.updateRequested(websiteField.text, usernameField.text, passwordField.text, totpField.text) : entryForm.addRequested(websiteField.text, usernameField.text, passwordField.text, totpField.text)
            }

            Text {
                text: passwordController ? passwordController.totpError : ""
                color: "#ef5350"
                font.pixelSize: 11
                visible: passwordController && passwordController.totpError !== ""
            }

            Text {
                text: "Base32 secret for 2FA codes"
                font.pixelSize: 10
                color: "#606060"
                visible: !passwordController || passwordController.totpError === ""
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
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                highlighted: true
                font.weight: Font.Medium
                onClicked: entryForm.editMode ? entryForm.updateRequested(websiteField.text, usernameField.text, passwordField.text, totpField.text) : entryForm.addRequested(websiteField.text, usernameField.text, passwordField.text, totpField.text)

                contentItem: Row {
                    spacing: 8
                    anchors.centerIn: parent

                    Text {
                        text: entryForm.editMode ? "\ue161" : "\ue145"
                        font.family: "Material Icons"
                        font.pixelSize: 18
                        color: "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: entryForm.editMode ? "Save Changes" : "Add Password"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                flat: true
                visible: entryForm.editMode
                onClicked: entryForm.cancelRequested()

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
