import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

AppDialog {
    id: aboutDialog
    width: 380
    height: 320
    headerIcon: "\ue88e"
    headerTitle: "About"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Item { Layout.fillHeight: true }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            Text {
                text: "\ue897"
                font.family: "Material Icons"
                font.pixelSize: 56
                color: "#1976D2"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Password Manager"
                font.pixelSize: 22
                font.weight: Font.DemiBold
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Version 1.0.0"
                font.pixelSize: 14
                color: "#808080"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Secure password storage with TOTP support"
                font.pixelSize: 13
                color: "#606060"
                Layout.alignment: Qt.AlignHCenter
            }
        }

        Item { Layout.fillHeight: true }
    }
}
