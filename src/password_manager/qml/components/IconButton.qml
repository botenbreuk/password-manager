import QtQuick
import QtQuick.Controls

RoundButton {
    id: control
    width: 40
    height: 40
    flat: true

    property string materialIcon: ""
    property color iconColor: "#e0e0e0"
    property int iconSize: 22
    property string tooltip: ""

    ToolTip.visible: hovered && tooltip !== ""
    ToolTip.text: tooltip

    Text {
        anchors.centerIn: parent
        text: control.materialIcon
        font.family: "Material Icons"
        font.pixelSize: control.iconSize
        color: control.iconColor
    }
}
