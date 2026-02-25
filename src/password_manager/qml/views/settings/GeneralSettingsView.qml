import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../components"

Rectangle {
    id: generalView
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#252525"
    radius: 12

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
                text: "\ue8b8"
                font.family: "Material Icons"
                font.pixelSize: 28
                color: "#b0b0b0"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "General Settings"
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

        // Password Entry Form Style Section
        Column {
            Layout.fillWidth: true
            Layout.maximumWidth: 480
            spacing: 12

            ButtonGroup {
                id: formStyleGroup
                buttons: [panelRadio, dialogRadio]
            }

            SectionHeader {
                icon: "\ue150"
                label: "Password Entry Form"
            }

            Text {
                text: "Choose how the password entry form is displayed when adding or editing entries."
                font.pixelSize: 12
                color: "#909090"
                width: parent.width
                wrapMode: Text.WordWrap
            }

            Column {
                width: parent.width
                spacing: 8

                // Panel option (default)
                Rectangle {
                    width: parent.width
                    height: 56
                    radius: 8
                    color: panelRadio.checked ? "#1976D220" : "#2a2a2a"
                    border.color: panelRadio.checked ? "#1976D2" : "#3a3a3a"
                    border.width: 1

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panelRadio.checked = true
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 12
                        spacing: 4

                        RadioButton {
                            id: panelRadio
                            Layout.alignment: Qt.AlignVCenter
                            checked: vaultController ? vaultController.entryFormStyle === "panel" : true
                            onCheckedChanged: {
                                if (checked && vaultController) {
                                    vaultController.setEntryFormStyle("panel")
                                }
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Row {
                                spacing: 6

                                Text {
                                    text: "Sidebar Panel"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: "#e0e0e0"
                                }

                                Text {
                                    text: "(Default)"
                                    font.pixelSize: 11
                                    color: "#808080"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Text {
                                text: "Shows as a panel next to the password list"
                                font.pixelSize: 11
                                color: "#808080"
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: "\ue8d5"
                            font.family: "Material Icons"
                            font.pixelSize: 24
                            color: panelRadio.checked ? "#1976D2" : "#606060"
                        }
                    }
                }

                // Dialog option
                Rectangle {
                    width: parent.width
                    height: 56
                    radius: 8
                    color: dialogRadio.checked ? "#1976D220" : "#2a2a2a"
                    border.color: dialogRadio.checked ? "#1976D2" : "#3a3a3a"
                    border.width: 1

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: dialogRadio.checked = true
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 12
                        spacing: 4

                        RadioButton {
                            id: dialogRadio
                            Layout.alignment: Qt.AlignVCenter
                            checked: vaultController ? vaultController.entryFormStyle === "dialog" : false
                            onCheckedChanged: {
                                if (checked && vaultController) {
                                    vaultController.setEntryFormStyle("dialog")
                                }
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Text {
                                text: "Modal Dialog"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#e0e0e0"
                            }

                            Text {
                                text: "Opens as a centered overlay dialog"
                                font.pixelSize: 11
                                color: "#808080"
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: "\ue89e"
                            font.family: "Material Icons"
                            font.pixelSize: 24
                            color: dialogRadio.checked ? "#1976D2" : "#606060"
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
