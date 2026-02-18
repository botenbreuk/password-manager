import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

AppDialog {
    id: shortcutsDialog
    width: 450
    height: 420
    headerIcon: "\ue312"
    headerTitle: "Keyboard Shortcuts"

    ListView {
        anchors.fill: parent
        anchors.margins: 20
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
