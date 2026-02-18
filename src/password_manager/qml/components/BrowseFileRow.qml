import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

Row {
    id: browseRow

    property string placeholderText: "Choose a file..."
    property string dialogTitle: "Select File"
    property var nameFilters: []
    property int fileMode: FileDialog.OpenFile
    property string currentFile: ""
    property alias text: browseField.text

    signal fileSelected(string path)

    width: parent ? parent.width : 0
    spacing: 10

    TextField {
        id: browseField
        width: parent.width - browseBtn.width - 10
        placeholderText: browseRow.placeholderText
        readOnly: true
    }

    Button {
        id: browseBtn
        text: "Browse"
        flat: true
        onClicked: browseFileDialog.open()
    }

    FileDialog {
        id: browseFileDialog
        title: browseRow.dialogTitle
        fileMode: browseRow.fileMode
        nameFilters: browseRow.nameFilters
        currentFile: browseRow.currentFile
        onAccepted: {
            var path = selectedFile.toString()
            if (path.startsWith("file:///")) {
                path = path.substring(8)
                if (path.length > 1 && path.charAt(1) !== ':') {
                    path = "/" + path
                }
            }
            browseField.text = path
            browseRow.fileSelected(path)
        }
    }
}
