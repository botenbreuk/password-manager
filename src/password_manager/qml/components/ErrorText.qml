import QtQuick

Text {
    property string errorMessage: ""
    property int fontSize: 11

    text: errorMessage
    color: "#ef5350"
    font.pixelSize: fontSize
    visible: errorMessage !== ""
}
