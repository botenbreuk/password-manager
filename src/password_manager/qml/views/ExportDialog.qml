import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"

AppDialog {
    id: exportDialog
    width: 462
    height: 340
    headerIcon: exportSuccess ? "\ue86c" : "\ue2c4"
    headerIconColor: exportSuccess ? "#4CAF50" : "#1976D2"
    headerTitle: exportSuccess ? "Export Successful" : "Export Data"

    property string selectedFormat: "csv"
    property bool exportSuccess: false
    property string locationError: ""

    // Success view
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16
        visible: exportDialog.exportSuccess

        Item { Layout.fillHeight: true }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            Text {
                text: "\ue86c"
                font.family: "Material Icons"
                font.pixelSize: 56
                color: "#4CAF50"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Your passwords have been exported successfully!"
                font.pixelSize: 14
                color: "#c0c0c0"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: exportLocationField.text
                font.pixelSize: 12
                color: "#808080"
                Layout.alignment: Qt.AlignHCenter
                elide: Text.ElideMiddle
                Layout.maximumWidth: 400
            }
        }

        Item { Layout.fillHeight: true }

        Button {
            text: "Done"
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            highlighted: true
            font.weight: Font.Medium
            font.pixelSize: 14
            onClicked: exportDialog.close()
        }
    }

    // Export form view
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12
        visible: !exportDialog.exportSuccess

        // Format selection
        Column {
            Layout.fillWidth: true
            spacing: 6

            SectionHeader {
                icon: "\ue873"
                label: "Export Format"
            }

            Row {
                width: parent.width
                spacing: 0

                Rectangle {
                    width: parent.width / 2
                    height: 40
                    topLeftRadius: 8
                    bottomLeftRadius: 8
                    topRightRadius: 0
                    bottomRightRadius: 0
                    color: exportDialog.selectedFormat === "csv" ? "#1976D2" : (csvMouseArea.containsMouse ? "#353535" : "#2a2a2a")
                    border.color: exportDialog.selectedFormat === "csv" ? "#1976D2" : "#404040"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "CSV"
                        font.pixelSize: 14
                        font.weight: exportDialog.selectedFormat === "csv" ? Font.Medium : Font.Normal
                        color: exportDialog.selectedFormat === "csv" ? "#ffffff" : "#a0a0a0"
                    }

                    MouseArea {
                        id: csvMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: exportDialog.selectedFormat = "csv"
                    }
                }

                Rectangle {
                    width: parent.width / 2
                    height: 40
                    topLeftRadius: 0
                    bottomLeftRadius: 0
                    topRightRadius: 8
                    bottomRightRadius: 8
                    color: exportDialog.selectedFormat === "json" ? "#1976D2" : (jsonMouseArea.containsMouse ? "#353535" : "#2a2a2a")
                    border.color: exportDialog.selectedFormat === "json" ? "#1976D2" : "#404040"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "JSON"
                        font.pixelSize: 14
                        font.weight: exportDialog.selectedFormat === "json" ? Font.Medium : Font.Normal
                        color: exportDialog.selectedFormat === "json" ? "#ffffff" : "#a0a0a0"
                    }

                    MouseArea {
                        id: jsonMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: exportDialog.selectedFormat = "json"
                    }
                }
            }
        }

        // Save location
        Column {
            Layout.fillWidth: true
            spacing: 6

            SectionHeader {
                icon: "\ue2c8"
                label: "Save Location"
            }

            Row {
                width: parent.width
                spacing: 10

                TextField {
                    id: exportLocationField
                    width: parent.width - exportBrowseButton.width - 10
                    placeholderText: "Choose where to save..."
                    readOnly: true
                }

                Button {
                    id: exportBrowseButton
                    text: "Browse"
                    flat: true
                    onClicked: exportFileDialog.open()
                }
            }

            ErrorText {
                errorMessage: exportDialog.locationError
            }
        }

        Item { Layout.fillHeight: true }

        Button {
            text: "Export"
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            highlighted: true
            font.weight: Font.Medium
            font.pixelSize: 14
            onClicked: {
                if (exportLocationField.text.trim() === "") {
                    exportDialog.locationError = "Please choose a location"
                    return
                }
                exportDialog.locationError = ""

                var success = false
                if (exportDialog.selectedFormat === "csv") {
                    success = passwordController.exportToCsv(exportLocationField.text)
                } else {
                    success = passwordController.exportToJson(exportLocationField.text)
                }

                if (success) {
                    exportDialog.exportSuccess = true
                }
            }
        }
    }

    FileDialog {
        id: exportFileDialog
        title: "Export Passwords"
        fileMode: FileDialog.SaveFile
        nameFilters: exportDialog.selectedFormat === "csv"
            ? ["CSV Files (*.csv)"]
            : ["JSON Files (*.json)"]
        currentFile: "file:///" + (vaultController && vaultController.vaultName ? vaultController.vaultName.toLowerCase().replace(/ /g, "-") : "passwords") + (exportDialog.selectedFormat === "csv" ? ".csv" : ".json")
        onAccepted: {
            var path = selectedFile.toString()
            if (path.startsWith("file:///")) {
                path = path.substring(8)
                if (path.length > 1 && path.charAt(1) !== ':') {
                    path = "/" + path
                }
            }
            exportLocationField.text = path
        }
    }

    onClosed: {
        exportSuccess = false
        locationError = ""
        exportLocationField.text = ""
    }
}
