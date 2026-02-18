import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: headerBar
    height: 56
    color: "#252525"

    property bool sidebarExpanded: true
    property alias searchText: searchField.text

    signal toggleSidebar()
    signal lockVault()
    signal searchChanged(string query)

    function focusSearch() {
        searchField.forceActiveFocus()
    }

    function clearSearch() {
        searchField.text = ""
        searchField.focus = false
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 20
        spacing: 12

        IconButton {
            materialIcon: "\ue5d2"
            iconSize: 24
            tooltip: sidebarExpanded ? "Collapse menu" : "Expand menu"
            onClicked: headerBar.toggleSidebar()
        }

        Text {
            text: "\ue897"
            font.family: "Material Icons"
            font.pixelSize: 28
            color: "#1976D2"
        }

        Text {
            text: vaultController && vaultController.vaultName ? vaultController.vaultName : "Password Manager"
            font.pixelSize: 18
            font.weight: Font.Medium
            color: "#ffffff"
        }

        Item { Layout.fillWidth: true }

        // Search bar
        Rectangle {
            Layout.preferredWidth: 250
            height: 36
            color: "#1e1e1e"
            radius: 18
            border.color: searchField.activeFocus ? "#1976D2" : "#3a3a3a"
            border.width: 1

            Behavior on border.color {
                ColorAnimation { duration: 150 }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    text: "\ue8b6"
                    font.family: "Material Icons"
                    font.pixelSize: 18
                    color: "#707070"
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    TextInput {
                        id: searchField
                        anchors.fill: parent
                        anchors.topMargin: 1
                        verticalAlignment: TextInput.AlignVCenter
                        color: "#ffffff"
                        font.pixelSize: 13
                        clip: true
                        onTextChanged: headerBar.searchChanged(text)
                    }

                    Text {
                        anchors.fill: parent
                        anchors.topMargin: 1
                        verticalAlignment: Text.AlignVCenter
                        text: "Search passwords..."
                        color: "#606060"
                        font.pixelSize: 13
                        visible: searchField.text === "" && !searchField.activeFocus
                    }
                }

                Text {
                    text: "\ue5cd"
                    font.family: "Material Icons"
                    font.pixelSize: 18
                    color: "#707070"
                    visible: searchField.text !== ""
                    opacity: clearSearchMouse.containsMouse ? 1 : 0.7

                    MouseArea {
                        id: clearSearchMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: headerBar.clearSearch()
                    }
                }
            }
        }

        Item { width: 8 }

        IconButton {
            materialIcon: "\ue898"
            tooltip: "Lock vault"
            onClicked: headerBar.lockVault()
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: "#3d3d3d"
    }
}
