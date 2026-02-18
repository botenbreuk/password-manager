import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: sidebarItem
    Layout.fillWidth: true
    height: 40
    radius: 8
    color: selected ? "#1976D230" : (itemMouse.containsMouse ? "#2f2f2f" : "#002f2f2f")
    opacity: enabled ? 1.0 : 0.5

    property string icon: ""
    property string label: ""
    property bool expanded: true
    property bool selected: false
    property bool indent: false
    property int badgeCount: 0
    readonly property alias hovered: itemMouse.containsMouse

    signal clicked()

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    MouseArea {
        id: itemMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (parent.enabled) parent.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: indent ? 24 : 8
        anchors.rightMargin: 8
        spacing: 10

        Text {
            text: sidebarItem.icon
            font.family: "Material Icons"
            font.pixelSize: 20
            color: sidebarItem.selected ? "#1976D2" : "#a0a0a0"
            Layout.preferredWidth: 24
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: sidebarItem.label
            font.pixelSize: 13
            color: sidebarItem.selected ? "#ffffff" : "#c0c0c0"
            visible: sidebarItem.expanded
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Rectangle {
            width: badgeText.width + 12
            height: 20
            radius: 10
            color: "#1976D2"
            visible: sidebarItem.expanded && sidebarItem.badgeCount > 0

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: sidebarItem.badgeCount
                font.pixelSize: 11
                font.weight: Font.Bold
                color: "#ffffff"
            }
        }
    }

    ToolTip {
        visible: itemMouse.containsMouse && !sidebarItem.expanded
        text: sidebarItem.label
        delay: 500
    }
}
