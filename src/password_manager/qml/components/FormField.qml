import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Column {
    id: formField

    property string label: ""
    property string placeholderText: ""
    property string errorMessage: ""
    property bool isPassword: false
    property alias text: textField.text
    property alias field: textField

    spacing: 4
    Layout.fillWidth: true

    Text {
        text: formField.label
        font.pixelSize: 12
        font.weight: Font.Medium
        color: "#909090"
    }

    TextField {
        id: textField
        width: parent.width
        placeholderText: formField.placeholderText
        echoMode: formField.isPassword ? TextInput.Password : TextInput.Normal
    }

    Text {
        text: formField.errorMessage
        color: "#ef5350"
        font.pixelSize: 11
        visible: formField.errorMessage !== ""
    }
}
