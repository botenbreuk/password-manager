import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects

Dialog {
    id: dialog

    property string headerIcon: ""
    property color headerIconColor: "#1976D2"
    property string headerTitle: ""

    default property alias dialogContent: contentContainer.data

    title: ""
    modal: true
    anchors.centerIn: parent
    padding: 0
    topPadding: 0
    dim: true

    Material.theme: Material.Dark
    Material.accent: "#1976D2"

    Overlay.modal: Rectangle {
        color: "#D0000000"
    }

    background: Rectangle {
        color: "#E8141414"
        radius: 16
        border.color: "#404040"
        border.width: 1

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#80000000"
            shadowBlur: 1.5
            shadowVerticalOffset: 8
        }
    }

    header: Rectangle {
        height: 60
        color: "#252525"
        radius: 16

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 20
            color: "#252525"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 16

            Text {
                text: dialog.headerIcon
                font.family: "Material Icons"
                font.pixelSize: 28
                color: dialog.headerIconColor
            }

            Text {
                text: dialog.headerTitle
                font.pixelSize: 20
                font.weight: Font.DemiBold
                color: "#ffffff"
            }

            Item { Layout.fillWidth: true }

            RoundButton {
                width: 36
                height: 36
                flat: true
                onClicked: dialog.close()

                Text {
                    anchors.centerIn: parent
                    text: "\ue5cd"
                    font.family: "Material Icons"
                    font.pixelSize: 20
                    color: "#808080"
                }
            }
        }
    }

    footer: Item { height: 0 }

    Item {
        id: contentContainer
        anchors.fill: parent
    }
}
