import QtQuick
import QtQuick.Controls

Rectangle {
    id: cell

    property string displayText: ""
    property bool masked: false
    property color textColor: "#a0a0a0"

    signal copyClicked()

    height: 28
    color: "transparent"
    border.color: cellMouseArea.containsMouse ? "#505050" : "transparent"
    border.width: 1
    radius: 14

    Text {
        anchors.centerIn: parent
        text: cell.masked ? "\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022" : cell.displayText
        font.pixelSize: 14
        color: cellMouseArea.containsMouse ? "#ffffff" : cell.textColor
        font.letterSpacing: cell.masked ? 2 : 0
    }

    MouseArea {
        id: cellMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: cell.copyClicked()
    }

    ToolTip {
        visible: cellMouseArea.containsMouse
        text: "Click to copy"
        y: -height - 5
        contentItem: Text {
            text: "Click to copy"
            color: "#ffffff"
            font.pixelSize: 12
        }
        background: Rectangle {
            color: "#424242"
            radius: 4
        }
    }
}
