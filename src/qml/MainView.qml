import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Password table (left, 70%)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 70
            color: "#2d2d2d"
            border.color: "#3d3d3d"
            border.width: 1
            radius: 4

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 1
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#353535"
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        Text {
                            text: "Website"
                            font.bold: true
                            color: "#e0e0e0"
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                        }
                        Text {
                            text: "Username"
                            font.bold: true
                            color: "#e0e0e0"
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                        }
                        Text {
                            text: "Password"
                            font.bold: true
                            color: "#e0e0e0"
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                        }
                        Item {
                            Layout.preferredWidth: 100
                        }
                    }
                }

                // List
                ListView {
                    id: passwordList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: vaultController ? vaultController.passwordModel : null

                    delegate: Rectangle {
                        width: passwordList.width
                        height: 50
                        color: index % 2 === 0 ? "#2d2d2d" : "#333333"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Text {
                                text: model.website
                                color: "#e0e0e0"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                            }
                            Text {
                                text: model.username
                                color: "#b0b0b0"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                            }
                            Text {
                                text: model.visible ? model.password : "••••••••"
                                color: "#b0b0b0"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                            }

                            Row {
                                spacing: 2
                                Layout.preferredWidth: 100

                                RoundButton {
                                    width: 32
                                    height: 32
                                    flat: true
                                    ToolTip.visible: hovered
                                    ToolTip.text: "Copy password"
                                    onClicked: vaultController.copyPassword(index)

                                    Text {
                                        anchors.centerIn: parent
                                        text: "\ue14d"
                                        font.family: "Material Icons"
                                        font.pixelSize: 18
                                        color: "#e0e0e0"
                                    }
                                }
                                RoundButton {
                                    width: 32
                                    height: 32
                                    flat: true
                                    ToolTip.visible: hovered
                                    ToolTip.text: "Show/hide password"
                                    onClicked: vaultController.togglePasswordVisibility(index)

                                    Text {
                                        anchors.centerIn: parent
                                        text: model.visible ? "\ue8f5" : "\ue8f4"
                                        font.family: "Material Icons"
                                        font.pixelSize: 18
                                        color: "#e0e0e0"
                                    }
                                }
                                RoundButton {
                                    width: 32
                                    height: 32
                                    flat: true
                                    ToolTip.visible: hovered
                                    ToolTip.text: "Delete"
                                    onClicked: vaultController.deleteEntry(index)

                                    Text {
                                        anchors.centerIn: parent
                                        text: "\ue872"
                                        font.family: "Material Icons"
                                        font.pixelSize: 18
                                        color: "#ff6b6b"
                                    }
                                }
                            }
                        }
                    }

                    // Empty state
                    Text {
                        anchors.centerIn: parent
                        text: "No passwords stored yet"
                        color: "#666"
                        visible: passwordList.count === 0
                    }
                }
            }
        }

        // Entry form (right, 30%)
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 250
            color: "#2d2d2d"
            border.color: "#3d3d3d"
            border.width: 1
            radius: 4

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                Text {
                    text: "Add New Entry"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#e0e0e0"
                }

                // Website field
                TextField {
                    id: websiteField
                    Layout.fillWidth: true
                    placeholderText: "Website"
                    onAccepted: usernameField.focus = true
                }
                Text {
                    text: vaultController ? vaultController.urlError : ""
                    color: "#ff6b6b"
                    font.pixelSize: 11
                    visible: vaultController && vaultController.urlError !== ""
                }

                // Username field
                TextField {
                    id: usernameField
                    Layout.fillWidth: true
                    placeholderText: "Username"
                    onAccepted: passwordField.focus = true
                }
                Text {
                    text: vaultController ? vaultController.usernameError : ""
                    color: "#ff6b6b"
                    font.pixelSize: 11
                    visible: vaultController && vaultController.usernameError !== ""
                }

                // Password field
                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    placeholderText: "Password"
                    echoMode: TextInput.Password
                    onAccepted: addEntry()
                }
                Text {
                    text: vaultController ? vaultController.passwordError : ""
                    color: "#ff6b6b"
                    font.pixelSize: 11
                    visible: vaultController && vaultController.passwordError !== ""
                }

                Button {
                    text: "Add"
                    Layout.fillWidth: true
                    onClicked: addEntry()
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }

    function addEntry() {
        if (vaultController && vaultController.addEntry(websiteField.text, usernameField.text, passwordField.text)) {
            websiteField.text = ""
            usernameField.text = ""
            passwordField.text = ""
            websiteField.focus = true
        }
    }
}
