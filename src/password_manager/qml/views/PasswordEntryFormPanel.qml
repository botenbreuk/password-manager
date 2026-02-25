import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

Rectangle {
    id: entryFormPanel
    Layout.fillHeight: true
    Layout.preferredWidth: 280
    color: "#252525"
    radius: 12

    property bool editMode: false

    signal addRequested(string website, string username, string password, string totpKey)
    signal updateRequested(string website, string username, string password, string totpKey)
    signal openGenerator()

    function setPassword(pw) {
        passwordField.text = pw
    }

    function loadEntry(website, username, password, totpKey) {
        editMode = true
        websiteField.text = website
        usernameField.text = username
        passwordField.text = password
        totpField.text = totpKey
        websiteField.field.forceActiveFocus()
    }

    function openForAdd() {
        editMode = false
        clearFields()
        websiteField.field.forceActiveFocus()
    }

    function clearFields() {
        websiteField.text = ""
        usernameField.text = ""
        passwordField.text = ""
        totpField.text = ""
        if (passwordController) {
            passwordController.clearErrors()
        }
    }

    function close() {
        clearFields()
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
        anchors.margins: 16
        spacing: 12

        // Header
        Row {
            spacing: 8

            Text {
                text: entryFormPanel.editMode ? "\ue3c9" : "\ue145"
                font.family: "Material Icons"
                font.pixelSize: 20
                color: "#1976D2"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: entryFormPanel.editMode ? "Edit Entry" : "Add New Entry"
                font.pixelSize: 15
                font.weight: Font.DemiBold
                color: "#e0e0e0"
                anchors.verticalCenter: parent.verticalCenter
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

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            FormField {
                id: passwordField
                label: "Password"
                placeholderText: "Enter password"
                isPassword: true
                errorMessage: passwordController ? passwordController.passwordError : ""
                field.onAccepted: totpField.forceActiveFocus()
                Layout.fillWidth: true
            }

            IconButton {
                width: 36
                height: 36
                materialIcon: "\ue73c"
                iconSize: 20
                iconColor: "#1976D2"
                tooltip: "Generate password"
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: passwordController && passwordController.passwordError !== "" ? 20 : 0
                onClicked: entryFormPanel.openGenerator()
            }
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
                onAccepted: submitForm()
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

        Item { Layout.fillHeight: true }

        // Action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                flat: true
                text: "Cancel"
                onClicked: entryFormPanel.clearFields()
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                highlighted: true
                text: entryFormPanel.editMode ? "Save" : "Add"
                icon.source: ""
                font.weight: Font.Medium
                onClicked: submitForm()
            }
        }
    }

    function submitForm() {
        if (editMode) {
            entryFormPanel.updateRequested(websiteField.text, usernameField.text, passwordField.text, totpField.text)
        } else {
            entryFormPanel.addRequested(websiteField.text, usernameField.text, passwordField.text, totpField.text)
        }
    }
}
