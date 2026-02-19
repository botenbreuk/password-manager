import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

Rectangle {
    id: sidebar
    Layout.fillHeight: true
    Layout.preferredWidth: expanded ? 220 : 60
    color: "#252525"
    radius: 12

    property bool expanded: true
    property bool showFavoritesOnly: false
    property string currentView: "passwords"
    property int totalCount: 0
    property int favoriteCount: 0

    signal showAllClicked()
    signal showFavoritesClicked()
    signal openTotpQrGenerator()
    signal openGenerator()
    signal openExport()
    signal openSecurity()
    signal openShortcuts()
    signal openAbout()

    Behavior on Layout.preferredWidth {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#40000000"
        shadowBlur: 0.5
        shadowVerticalOffset: 2
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        SidebarItem {
            icon: "\ue899"
            label: "All Passwords"
            expanded: sidebar.expanded
            selected: sidebar.currentView === "passwords" && !sidebar.showFavoritesOnly
            badgeCount: sidebar.totalCount
            onClicked: sidebar.showAllClicked()
        }

        SidebarItem {
            icon: "\ue838"
            label: "Favorites"
            expanded: sidebar.expanded
            selected: sidebar.currentView === "passwords" && sidebar.showFavoritesOnly
            badgeCount: sidebar.favoriteCount
            onClicked: sidebar.showFavoritesClicked()
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            height: 1
            color: "#3a3a3a"
        }

        Text {
            text: "TOOLS"
            font.pixelSize: 10
            font.weight: Font.Medium
            font.letterSpacing: 1
            color: "#606060"
            visible: sidebar.expanded
            Layout.leftMargin: 12
            Layout.bottomMargin: 4
        }

        SidebarItem {
            icon: "\ue73c"
            label: "Password Generator"
            expanded: sidebar.expanded
            onClicked: sidebar.openGenerator()
        }

        SidebarItem {
            icon: "\ue2c4"
            label: "Export Data"
            expanded: sidebar.expanded
            onClicked: sidebar.openExport()
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            height: 1
            color: "#3a3a3a"
        }

        SidebarSection {
            icon: "\ue425"
            label: "TOTP Utils"
            expanded: sidebar.expanded

            SidebarItem {
                icon: "\ue1a3"
                label: "QR Code Generator"
                expanded: sidebar.expanded
                indent: true
                selected: sidebar.currentView === "totpQrGenerator"
                onClicked: sidebar.openTotpQrGenerator()
            }
        }

        SidebarSection {
            icon: "\ue8b8"
            label: "Settings"
            expanded: sidebar.expanded

            SidebarItem {
                icon: "\ue897"
                label: "Security"
                expanded: sidebar.expanded
                indent: true
                selected: sidebar.currentView === "security"
                onClicked: sidebar.openSecurity()
            }

            SidebarItem {
                icon: "\ue312"
                label: "Keyboard Shortcuts"
                expanded: sidebar.expanded
                indent: true
                onClicked: sidebar.openShortcuts()
            }
        }

        Item { Layout.fillHeight: true }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 4
            height: 1
            color: "#3a3a3a"
        }

        SidebarItem {
            icon: "\ue88e"
            label: "About"
            expanded: sidebar.expanded
            onClicked: sidebar.openAbout()
        }
    }
}
