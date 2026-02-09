import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 500
    minimumWidth: 600
    minimumHeight: 400
    title: "Password Manager" + (vaultController && vaultController.vaultName ? " - " + vaultController.vaultName : "")

    Material.theme: Material.Dark
    Material.accent: Material.Blue

    property bool vaultUnlocked: false

    color: "#1e1e1e"

    Loader {
        id: mainLoader
        anchors.fill: parent
        sourceComponent: vaultUnlocked ? mainViewComponent : unlockComponent
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
