import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

AppDialog {
    id: missingVaultDialog
    headerIcon: "\ue002"
    headerIconColor: "#ef5350"
    headerTitle: "Vault Not Found"
    width: 380
    height: 240

    signal removeRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        Text {
            text: "This vault file could not be found. It may have been moved or deleted."
            font.pixelSize: 14
            color: "#b0b0b0"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Text {
            text: "Would you like to remove it from the recent vaults list?"
            font.pixelSize: 14
            color: "#b0b0b0"
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 12

            Item { Layout.fillWidth: true }

            Button {
                text: "Cancel"
                flat: true
                onClicked: missingVaultDialog.close()
            }

            Button {
                text: "Remove"
                highlighted: true
                Material.accent: "#ef5350"
                onClicked: {
                    missingVaultDialog.removeRequested()
                    missingVaultDialog.close()
                }
            }
        }
    }
}
