from PyQt6.QtWidgets import QMainWindow, QWidget, QHBoxLayout, QMessageBox

from widgets import PasswordTable, EntryForm
from vault import VaultManager


class MainWindow(QMainWindow):
    def __init__(self, vault: VaultManager):
        super().__init__()
        self.vault = vault

        self.setWindowTitle(f"Password Manager - {vault.vault_name}")
        self.setMinimumSize(600, 400)

        central_widget = QWidget()
        self.setCentralWidget(central_widget)

        main_layout = QHBoxLayout(central_widget)

        # Table (left, 70%)
        self.table = PasswordTable()
        self.table.entry_deleted.connect(self._on_entry_deleted)
        main_layout.addWidget(self.table, 70)

        # Form (right, 30%)
        self.form = EntryForm()
        self.form.entry_added.connect(self._on_entry_added)
        main_layout.addWidget(self.form, 30)

        # Load existing entries
        self._load_entries()

    def _load_entries(self):
        entries = self.vault.get_all_passwords()
        self.table.load_entries(entries)

    def _on_entry_added(self, site: str, username: str, password: str):
        entry_id = self.vault.add_password(site, username, password)
        self.table.add_entry(entry_id, site, username, password)

    def _on_entry_deleted(self, entry_id: int):
        self.vault.delete_password(entry_id)

    def closeEvent(self, event):
        self.vault.close()
        event.accept()
