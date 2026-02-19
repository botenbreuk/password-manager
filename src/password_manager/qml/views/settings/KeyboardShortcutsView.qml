import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../components"

Rectangle {
    id: shortcutsView
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
                text: "\ue312"
                font.family: "Material Icons"
                font.pixelSize: 28
                color: "#b0b0b0"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Keyboard Shortcuts"
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

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: 480
            clip: true
            spacing: 6

            model: ListModel {
                ListElement { shortcut: "Ctrl/Cmd + F"; action: "Search passwords" }
                ListElement { shortcut: "Ctrl/Cmd + N"; action: "Add new password" }
                ListElement { shortcut: "Ctrl/Cmd + L"; action: "Lock vault" }
                ListElement { shortcut: "Ctrl/Cmd + G"; action: "Generate password" }
                ListElement { shortcut: "Escape"; action: "Cancel / Close dialog" }
                ListElement { shortcut: "Enter"; action: "Submit form" }
                ListElement { shortcut: "Ctrl/Cmd + ,"; action: "Toggle sidebar" }
            }

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                height: 44
                color: "transparent"
                radius: 8

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 16

                    Rectangle {
                        Layout.preferredWidth: 150
                        height: 32
                        color: "#252525"
                        radius: 6
                        border.color: "#404040"

                        Text {
                            anchors.centerIn: parent
                            text: model.shortcut
                            font.pixelSize: 12
                            font.family: "Menlo"
                            color: "#c0c0c0"
                        }
                    }

                    Text {
                        text: model.action
                        font.pixelSize: 14
                        color: "#e0e0e0"
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
