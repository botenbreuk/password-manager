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

    // View switching
    property string currentView: "passwords"

    // Form style: "dialog" or "panel"
    property bool useDialogMode: vaultController ? vaultController.entryFormStyle === "dialog" : false

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
            currentView: mainView.currentView
            totalCount: passwordListPanel.count
            favoriteCount: passwordController ? passwordController.passwordModel.favoriteCount : 0
            onShowAllClicked: { mainView.currentView = "passwords"; mainView.showFavoritesOnly = false }
            onShowFavoritesClicked: { mainView.currentView = "passwords"; mainView.showFavoritesOnly = true }
            onOpenTotpQrGenerator: mainView.currentView = "totpQrGenerator"
            onOpenGenerator: generatorDialog.open()
            onOpenExport: exportDialog.open()
            onOpenGeneral: mainView.currentView = "general"
            onOpenSecurity: mainView.currentView = "security"
            onOpenShortcuts: mainView.currentView = "shortcuts"
            onOpenAbout: aboutDialog.open()
        }

        PasswordListPanel {
            id: passwordListPanel
            visible: mainView.currentView === "passwords"
            model: passwordController ? passwordController.passwordModel : null
            searchQuery: mainView.searchQuery
            showFavoritesOnly: mainView.showFavoritesOnly
            editMode: mainView.editMode
            editingRow: mainView.editingRow
            totpRefreshTrigger: mainView.totpRefreshTrigger
            totpRemainingSeconds: mainView.totpRemainingSeconds
            showAddButton: mainView.useDialogMode
            onAddRequested: activeForm().openForAdd()
            onEditRequested: function(row) { startEdit(row) }
            onDeleteRequested: function(row) { passwordController.deleteEntry(row) }
            onToggleFavoriteRequested: function(row) { passwordController.toggleFavorite(row) }
            onCopyUsernameRequested: function(row) { passwordController.copyUsername(row) }
            onCopyPasswordRequested: function(row) { passwordController.copyPassword(row) }
            onCopyTotpRequested: function(row) { passwordController.copyTotp(row) }
            onOpenWebsiteRequested: function(row) { passwordController.openWebsite(row) }
            onToggleVisibilityRequested: function(row) { passwordController.togglePasswordVisibility(row) }
        }

        PasswordEntryFormPanel {
            id: entryFormPanel
            visible: mainView.currentView === "passwords" && !mainView.useDialogMode
            onAddRequested: function(website, username, password, totpKey) { addEntry(website, username, password, totpKey) }
            onUpdateRequested: function(website, username, password, totpKey) { updateEntry(website, username, password, totpKey) }
            onOpenGenerator: generatorDialog.open()
        }

        Loader {
            id: totpQrGeneratorLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            active: mainView.currentView === "totpQrGenerator"
            visible: active
            source: "totp/TotpQrGeneratorView.qml"
        }

        Loader {
            id: securitySettingsLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            active: mainView.currentView === "security"
            visible: active
            source: "security/SecuritySettingsView.qml"
        }

        Loader {
            id: shortcutsLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            active: mainView.currentView === "shortcuts"
            visible: active
            source: "settings/KeyboardShortcutsView.qml"
        }

        Loader {
            id: generalSettingsLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            active: mainView.currentView === "general"
            visible: active
            source: "settings/GeneralSettingsView.qml"
        }
    }

    // Dialogs
    PasswordEntryForm {
        id: entryForm
        onAddRequested: function(website, username, password, totpKey) { addEntry(website, username, password, totpKey) }
        onUpdateRequested: function(website, username, password, totpKey) { updateEntry(website, username, password, totpKey) }
        onOpenGenerator: generatorDialog.open()
    }

    PasswordGeneratorDialog {
        id: generatorDialog
        onPasswordGenerated: function(pw) { activeForm().setPassword(pw) }
    }

    AboutDialog {
        id: aboutDialog
    }

    ExportDialog {
        id: exportDialog
    }

    // Returns the currently active entry form (dialog or panel)
    function activeForm() {
        return useDialogMode ? entryForm : entryFormPanel
    }

    // Orchestration functions
    function startEdit(row) {
        editMode = true
        editingRow = row
        activeForm().loadEntry(
            passwordController.getWebsite(row),
            passwordController.getUsername(row),
            passwordController.getPassword(row),
            passwordController.getTotpKey(row)
        )
    }

    function cancelEdit() {
        editMode = false
        editingRow = -1
        activeForm().close()
    }

    function addEntry(website, username, password, totpKey) {
        if (passwordController && passwordController.addEntry(website, username, password, totpKey)) {
            activeForm().close()
        }
    }

    function updateEntry(website, username, password, totpKey) {
        if (passwordController && passwordController.updateEntry(editingRow, website, username, password, totpKey)) {
            editMode = false
            editingRow = -1
            activeForm().close()
        }
    }

    // Keyboard shortcuts
    Shortcut {
        sequence: "Ctrl+F"
        onActivated: headerBar.focusSearch()
    }

    Shortcut {
        sequence: "Ctrl+N"
        onActivated: activeForm().openForAdd()
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
            if (useDialogMode && entryForm.visible) entryForm.close()
            else if (generatorDialog.visible) generatorDialog.close()
            else if (aboutDialog.visible) aboutDialog.close()
            else if (exportDialog.visible) exportDialog.close()
            else headerBar.clearSearch()
        }
    }
}
