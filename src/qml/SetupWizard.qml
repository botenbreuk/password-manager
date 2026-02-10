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
    width: 550
    height: 700
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
        anchors.margins: 24
        spacing: 0

        // Step indicators
        Row {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 24
            spacing: 0

            Repeater {
                model: [
                    { num: "1", label: "Name" },
                    { num: "2", label: "Password" },
                    { num: "3", label: "Location" }
                ]

                Row {
                    spacing: 0

                    // Step circle
                    Column {
                        spacing: 6

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: "#1976D2"
                            anchors.horizontalCenter: parent.horizontalCenter

                            Text {
                                anchors.centerIn: parent
                                text: modelData.num
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                        }

                        Text {
                            text: modelData.label
                            font.pixelSize: 11
                            color: "#909090"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    // Connector line
                    Rectangle {
                        width: 40
                        height: 2
                        color: "#404040"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -10
                        visible: index < 2
                    }
                }
            }
        }

        // Scrollable content
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 20

                // Step 1: Vault name
                Rectangle {
                    Layout.fillWidth: true
                    height: step1Content.height + 32
                    color: "#252525"
                    radius: 12

                    ColumnLayout {
                        id: step1Content
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 12

                        Row {
                            spacing: 8

                            Text {
                                text: "\ue8d3"
                                font.family: "Material Icons"
                                font.pixelSize: 18
                                color: "#1976D2"
                            }

                            Text {
                                text: "Vault Name"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                        }

                        TextField {
                            id: nameField
                            Layout.fillWidth: true
                            placeholderText: "e.g., Personal, Work, Family"
                            leftPadding: 12
                        }

                        Text {
                            text: nameError
                            color: "#ef5350"
                            font.pixelSize: 11
                            visible: nameError !== ""
                        }
                    }
                }

                // Step 2: Master password
                Rectangle {
                    Layout.fillWidth: true
                    height: step2Content.height + 32
                    color: "#252525"
                    radius: 12

                    ColumnLayout {
                        id: step2Content
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 12

                        Row {
                            spacing: 8

                            Text {
                                text: "\ue897"
                                font.family: "Material Icons"
                                font.pixelSize: 18
                                color: "#1976D2"
                            }

                            Text {
                                text: "Master Password"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                        }

                        TextField {
                            id: passwordField
                            Layout.fillWidth: true
                            placeholderText: "Create a strong password"
                            echoMode: TextInput.Password
                            leftPadding: 12
                        }

                        Text {
                            text: passwordError
                            color: "#ef5350"
                            font.pixelSize: 11
                            visible: passwordError !== ""
                        }

                        TextField {
                            id: confirmField
                            Layout.fillWidth: true
                            placeholderText: "Confirm your password"
                            echoMode: TextInput.Password
                            leftPadding: 12
                        }

                        Text {
                            text: confirmError
                            color: "#ef5350"
                            font.pixelSize: 11
                            visible: confirmError !== ""
                        }

                        // Password requirements hint
                        Rectangle {
                            Layout.fillWidth: true
                            height: hintContent.height + 16
                            color: "#2a2a2a"
                            radius: 8

                            Row {
                                id: hintContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 12
                                spacing: 8

                                Text {
                                    text: "\ue88e"
                                    font.family: "Material Icons"
                                    font.pixelSize: 16
                                    color: "#707070"
                                }

                                Text {
                                    text: "Min 8 chars with upper, lower, digit & special"
                                    font.pixelSize: 12
                                    color: "#707070"
                                    wrapMode: Text.WordWrap
                                    width: parent.width - 30
                                }
                            }
                        }
                    }
                }

                // Step 3: Location
                Rectangle {
                    Layout.fillWidth: true
                    height: step3Content.height + 32
                    color: "#252525"
                    radius: 12

                    ColumnLayout {
                        id: step3Content
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 12

                        Row {
                            spacing: 8

                            Text {
                                text: "\ue2c8"
                                font.family: "Material Icons"
                                font.pixelSize: 18
                                color: "#1976D2"
                            }

                            Text {
                                text: "Save Location"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            TextField {
                                id: locationField
                                Layout.fillWidth: true
                                placeholderText: "Choose where to save..."
                                readOnly: true
                                leftPadding: 12
                            }

                            Button {
                                text: "Browse"
                                flat: true
                                onClicked: fileDialog.open()

                                contentItem: Row {
                                    spacing: 6

                                    Text {
                                        text: "\ue2c8"
                                        font.family: "Material Icons"
                                        font.pixelSize: 16
                                        color: "#1976D2"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: "Browse"
                                        font.pixelSize: 13
                                        color: "#1976D2"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        Text {
                            text: locationError
                            color: "#ef5350"
                            font.pixelSize: 11
                            visible: locationError !== ""
                        }
                    }
                }
            }
        }

        Item {
            Layout.preferredHeight: 16
        }

        // Create button
        Button {
            text: "Create Vault"
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            highlighted: true
            font.weight: Font.Medium
            font.pixelSize: 15
            onClicked: createVault()

            contentItem: Row {
                spacing: 10
                anchors.centerIn: parent

                Text {
                    text: "\ue145"
                    font.family: "Material Icons"
                    font.pixelSize: 20
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Create Vault"
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
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
