import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: mainView
    focus: true

    // Edit mode state
    property bool editMode: false
    property int editingRow: -1

    // Sidebar state
    property bool sidebarExpanded: true
    property string searchQuery: ""
    property bool showFavoritesOnly: false

    // Click outside to unfocus search
    MouseArea {
        anchors.fill: parent
        onClicked: mainView.forceActiveFocus()
        propagateComposedEvents: true
        z: -1
    }

    // TOTP refresh trigger (changes every 30 seconds)
    property int totpRefreshTrigger: 0
    property int totpRemainingSeconds: 30 - (Math.floor(Date.now() / 1000) % 30)

    Timer {
        id: totpTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var currentPeriod = Math.floor(Date.now() / 1000 / 30)
            if (currentPeriod !== totpRefreshTrigger) {
                totpRefreshTrigger = currentPeriod
            }
            totpRemainingSeconds = 30 - (Math.floor(Date.now() / 1000) % 30)
        }
    }

    // Header bar
    HeaderBar {
        id: headerBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        sidebarExpanded: mainView.sidebarExpanded
        onToggleSidebar: mainView.sidebarExpanded = !mainView.sidebarExpanded
        onLockVault: {
            vaultController.closeVault()
            root.vaultUnlocked = false
        }
        onSearchChanged: function(query) { mainView.searchQuery = query }
    }

    // Main content
    RowLayout {
        anchors.fill: parent
        anchors.topMargin: headerBar.height + 16
        anchors.margins: 16
        spacing: 16

        Sidebar {
            id: sidebar
            expanded: mainView.sidebarExpanded
            showFavoritesOnly: mainView.showFavoritesOnly
            totalCount: passwordListPanel.count
            favoriteCount: passwordController ? passwordController.passwordModel.favoriteCount : 0
            onShowAllClicked: mainView.showFavoritesOnly = false
            onShowFavoritesClicked: mainView.showFavoritesOnly = true
            onOpenGenerator: generatorDialog.open()
            onOpenExport: exportDialog.open()
            onOpenSecurity: securityDialog.open()
            onOpenShortcuts: shortcutsDialog.open()
            onOpenAbout: aboutDialog.open()
        }

        PasswordListPanel {
            id: passwordListPanel
            model: passwordController ? passwordController.passwordModel : null
            searchQuery: mainView.searchQuery
            showFavoritesOnly: mainView.showFavoritesOnly
            editMode: mainView.editMode
            editingRow: mainView.editingRow
            totpRefreshTrigger: mainView.totpRefreshTrigger
            totpRemainingSeconds: mainView.totpRemainingSeconds
            onEditRequested: function(row) { startEdit(row) }
            onDeleteRequested: function(row) { passwordController.deleteEntry(row) }
            onToggleFavoriteRequested: function(row) { passwordController.toggleFavorite(row) }
            onCopyUsernameRequested: function(row) { passwordController.copyUsername(row) }
            onCopyPasswordRequested: function(row) { passwordController.copyPassword(row) }
            onCopyTotpRequested: function(row) { passwordController.copyTotp(row) }
            onOpenWebsiteRequested: function(row) { passwordController.openWebsite(row) }
            onToggleVisibilityRequested: function(row) { passwordController.togglePasswordVisibility(row) }
        }

        PasswordEntryForm {
            id: entryForm
            editMode: mainView.editMode
            onAddRequested: function(website, username, password, totpKey) { addEntry(website, username, password, totpKey) }
            onUpdateRequested: function(website, username, password, totpKey) { updateEntry(website, username, password, totpKey) }
            onCancelRequested: cancelEdit()
            onOpenGenerator: generatorDialog.open()
        }
    }

    // Dialogs
    PasswordGeneratorDialog {
        id: generatorDialog
        onPasswordGenerated: function(pw) { entryForm.setPassword(pw) }
    }

    KeyboardShortcutsDialog {
        id: shortcutsDialog
    }

    AboutDialog {
        id: aboutDialog
    }

    ExportDialog {
        id: exportDialog
    }

    SecuritySettingsDialog {
        id: securityDialog
    }

    // Orchestration functions
    function startEdit(row) {
        editMode = true
        editingRow = row
        entryForm.loadEntry(
            passwordController.getWebsite(row),
            passwordController.getUsername(row),
            passwordController.getPassword(row),
            passwordController.getTotpKey(row)
        )
    }

    function cancelEdit() {
        editMode = false
        editingRow = -1
        entryForm.clearFields()
    }

    function addEntry(website, username, password, totpKey) {
        if (passwordController && passwordController.addEntry(website, username, password, totpKey)) {
            entryForm.clearFields()
            entryForm.focusWebsite()
        }
    }

    function updateEntry(website, username, password, totpKey) {
        if (passwordController && passwordController.updateEntry(editingRow, website, username, password, totpKey)) {
            cancelEdit()
        }
    }

    // Keyboard shortcuts
    Shortcut {
        sequence: "Ctrl+F"
        onActivated: headerBar.focusSearch()
    }

    Shortcut {
        sequence: "Ctrl+N"
        onActivated: {
            cancelEdit()
            entryForm.focusWebsite()
        }
    }

    Shortcut {
        sequence: "Ctrl+L"
        onActivated: {
            vaultController.closeVault()
            root.vaultUnlocked = false
        }
    }

    Shortcut {
        sequence: "Ctrl+G"
        onActivated: generatorDialog.open()
    }

    Shortcut {
        sequence: "Ctrl+,"
        onActivated: mainView.sidebarExpanded = !mainView.sidebarExpanded
    }

    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (generatorDialog.visible) generatorDialog.close()
            else if (shortcutsDialog.visible) shortcutsDialog.close()
            else if (aboutDialog.visible) aboutDialog.close()
            else if (exportDialog.visible) exportDialog.close()
            else if (securityDialog.visible) securityDialog.close()
            else if (editMode) cancelEdit()
            else headerBar.clearSearch()
        }
    }
}
