import QtQuick

Row {
    property string icon: ""
    property string label: ""
    property color iconColor: "#1976D2"

    spacing: 8

    Text {
        text: icon
        font.family: "Material Icons"
        font.pixelSize: 16
        color: iconColor
    }

    Text {
        text: label
        font.pixelSize: 13
        font.weight: Font.Medium
        color: "#ffffff"
    }
}
