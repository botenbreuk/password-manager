from PyQt6.QtWidgets import QMainWindow, QWidget, QHBoxLayout

from ..widgets import PasswordTable, EntryForm


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Password Manager")
        self.setMinimumSize(600, 400)

        central_widget = QWidget()
        self.setCentralWidget(central_widget)

        main_layout = QHBoxLayout(central_widget)

        # Table (left, 70%)
        self.table = PasswordTable()
        main_layout.addWidget(self.table, 70)

        # Form (right, 30%)
        self.form = EntryForm()
        self.form.entry_added.connect(self._on_entry_added)
        main_layout.addWidget(self.form, 30)

    def _on_entry_added(self, site: str, username: str, password: str):
        self.table.add_entry(site, username)
