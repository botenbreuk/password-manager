import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: qrGeneratorView
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#252525"
    radius: 12

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#40000000"
        shadowBlur: 0.5
        shadowVerticalOffset: 2
    }

    Column {
        anchors.centerIn: parent
        spacing: 12

        Text {
            text: "\ue1a3"
            font.family: "Material Icons"
            font.pixelSize: 64
            color: "#404040"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Not supported yet"
            font.pixelSize: 18
            font.weight: Font.Medium
            color: "#606060"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "TOTP QR Code Generator is coming soon"
            font.pixelSize: 13
            color: "#505050"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
