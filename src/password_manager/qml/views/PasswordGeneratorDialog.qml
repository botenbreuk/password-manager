import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

AppDialog {
    id: generatorDialog
    width: 462
    height: 440
    headerIcon: "\ue73c"
    headerTitle: "Password Generator"

    signal passwordGenerated(string password)

    function generateRandomPassword(length, useUppercase, useLowercase, useNumbers, useSymbols) {
        var chars = ""
        if (useLowercase) chars += "abcdefghijklmnopqrstuvwxyz"
        if (useUppercase) chars += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        if (useNumbers) chars += "0123456789"
        if (useSymbols) chars += "!@#$%^&*()_+-=[]{}|;:,.<>?"
        if (chars === "") chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

        var password = ""
        for (var i = 0; i < length; i++) {
            password += chars.charAt(Math.floor(Math.random() * chars.length))
        }
        return password
    }

    function regenerate() {
        generatedPasswordText.text = generateRandomPassword(genLengthSlider.value, genUppercase.checked, genLowercase.checked, genNumbers.checked, genSymbols.checked)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        // Generated password display
        Rectangle {
            Layout.fillWidth: true
            Layout.bottomMargin: 8
            height: 48
            color: "#1e1e1e"
            radius: 8
            border.color: "#3a3a3a"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    id: generatedPasswordText
                    text: generatorDialog.generateRandomPassword(genLengthSlider.value, genUppercase.checked, genLowercase.checked, genNumbers.checked, genSymbols.checked)
                    font.pixelSize: 15
                    font.family: "Menlo"
                    color: "#ffffff"
                    Layout.fillWidth: true
                    elide: Text.ElideMiddle
                }

                IconButton {
                    width: 32
                    height: 32
                    materialIcon: "\ue14d"
                    iconSize: 18
                    iconColor: "#1976D2"
                    tooltip: "Copy to clipboard"
                    onClicked: {
                        if (passwordController) {
                            passwordController.copyToClipboard(generatedPasswordText.text)
                        }
                    }
                }

                IconButton {
                    width: 32
                    height: 32
                    materialIcon: "\ue5d5"
                    iconSize: 18
                    iconColor: "#808080"
                    tooltip: "Generate new"
                    onClicked: generatorDialog.regenerate()
                }
            }
        }

        // Length slider
        Column {
            Layout.fillWidth: true
            spacing: 6

            Row {
                width: parent.width
                spacing: 8

                SectionHeader {
                    icon: "\ue8ff"
                    label: "Length"
                }

                Item { width: parent.width - 180 }

                Text {
                    text: genLengthSlider.value + " characters"
                    font.pixelSize: 13
                    color: "#808080"
                }
            }

            Slider {
                id: genLengthSlider
                width: parent.width
                from: 8
                to: 64
                value: 16
                stepSize: 1
                onValueChanged: generatorDialog.regenerate()
            }
        }

        // Character options
        Column {
            Layout.fillWidth: true
            spacing: 6

            SectionHeader {
                icon: "\ue8d3"
                label: "Character Types"
            }

            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: 4
                columnSpacing: 8

                CheckBox {
                    id: genUppercase
                    text: "Uppercase (A-Z)"
                    checked: true
                    onCheckedChanged: generatorDialog.regenerate()
                }

                CheckBox {
                    id: genLowercase
                    text: "Lowercase (a-z)"
                    checked: true
                    onCheckedChanged: generatorDialog.regenerate()
                }

                CheckBox {
                    id: genNumbers
                    text: "Numbers (0-9)"
                    checked: true
                    onCheckedChanged: generatorDialog.regenerate()
                }

                CheckBox {
                    id: genSymbols
                    text: "Symbols (!@#$)"
                    checked: true
                    onCheckedChanged: generatorDialog.regenerate()
                }
            }
        }

        Item { Layout.preferredHeight: 12 }

        Button {
            text: "Use This Password"
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            highlighted: true
            font.weight: Font.Medium
            font.pixelSize: 14
            onClicked: {
                generatorDialog.passwordGenerated(generatedPasswordText.text)
                generatorDialog.close()
            }
        }
    }
}
