import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

ApplicationWindow {
    id: root
    visible: true
    width: 900
    height: 600
    minimumWidth: 700
    minimumHeight: 500
    title: "Password Manager" + (vaultController && vaultController.vaultName ? " - " + vaultController.vaultName : "")

    Material.theme: Material.Dark
    Material.accent: "#1976D2"

    property bool vaultUnlocked: false

    color: "#1a1a1a"

    // Smooth transition container
    Item {
        id: viewContainer
        anchors.fill: parent

        // Unlock view
        Loader {
            id: unlockLoader
            anchors.fill: parent
            sourceComponent: unlockComponent
            active: !vaultUnlocked
            opacity: vaultUnlocked ? 0 : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }
        }

        // Main view
        Loader {
            id: mainLoader
            anchors.fill: parent
            sourceComponent: mainViewComponent
            active: vaultUnlocked
            opacity: vaultUnlocked ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }
        }
    }

    Component {
        id: unlockComponent
        UnlockDialog {
            onUnlockSuccessful: {
                vaultUnlocked = true
            }
            onCreateNewVault: {
                setupWizardDialog.open()
            }
        }
    }

    Component {
        id: mainViewComponent
        MainView {}
    }

    SetupWizard {
        id: setupWizardDialog
        onVaultCreated: {
            vaultUnlocked = true
        }
    }

    onClosing: function(close) {
        if (vaultController) {
            vaultController.closeVault()
        }
        close.accepted = true
    }
}
