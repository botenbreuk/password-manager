import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: sidebarSection
    Layout.fillWidth: true
    spacing: 2

    property string icon: ""
    property string label: ""
    property bool expanded: true
    property bool sectionExpanded: true

    default property alias content: sectionContent.children

    Rectangle {
        Layout.fillWidth: true
        height: 40
        radius: 8
        color: sectionMouse.containsMouse ? "#2f2f2f" : "#002f2f2f"

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        MouseArea {
            id: sectionMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: sidebarSection.sectionExpanded = !sidebarSection.sectionExpanded
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 10

            Text {
                text: sidebarSection.icon
                font.family: "Material Icons"
                font.pixelSize: 20
                color: "#a0a0a0"
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: sidebarSection.label
                font.pixelSize: 13
                color: "#c0c0c0"
                visible: sidebarSection.expanded
                Layout.fillWidth: true
            }

            Text {
                text: sidebarSection.sectionExpanded ? "\ue5cf" : "\ue5ce"
                font.family: "Material Icons"
                font.pixelSize: 18
                color: "#606060"
                visible: sidebarSection.expanded
            }
        }
    }

    ColumnLayout {
        id: sectionContent
        Layout.fillWidth: true
        visible: sidebarSection.sectionExpanded && sidebarSection.expanded
        spacing: 2
    }
}
