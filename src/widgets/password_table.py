from PyQt6.QtWidgets import (
    QTableWidget,
    QTableWidgetItem,
    QHeaderView,
    QPushButton,
)
from PyQt6.QtCore import pyqtSignal


class PasswordTable(QTableWidget):
    entry_deleted = pyqtSignal(int)

    def __init__(self):
        super().__init__()
        self._entry_ids = []

        self.setColumnCount(4)
        self.setHorizontalHeaderLabels(["Website", "Username", "Password", ""])
        self.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeMode.Stretch)
        self.horizontalHeader().setSectionResizeMode(1, QHeaderView.ResizeMode.Stretch)
        self.horizontalHeader().setSectionResizeMode(2, QHeaderView.ResizeMode.Stretch)
        self.horizontalHeader().setSectionResizeMode(3, QHeaderView.ResizeMode.Fixed)
        self.setColumnWidth(3, 50)

    def load_entries(self, entries: list):
        self.setRowCount(0)
        self._entry_ids = []

        for entry_id, website, username, _ in entries:
            self._add_row(entry_id, website, username)

    def add_entry(self, entry_id: int, site: str, username: str):
        self._add_row(entry_id, site, username)

    def _add_row(self, entry_id: int, site: str, username: str):
        row = self.rowCount()
        self._entry_ids.append(entry_id)

        self.insertRow(row)
        self.setItem(row, 0, QTableWidgetItem(site))
        self.setItem(row, 1, QTableWidgetItem(username))
        self.setItem(row, 2, QTableWidgetItem("••••••••"))

        delete_button = QPushButton("🗑")
        delete_button.setFixedSize(30, 30)
        delete_button.clicked.connect(lambda _, r=row: self._delete_row(r))
        self.setCellWidget(row, 3, delete_button)

    def _delete_row(self, row: int):
        if row < len(self._entry_ids):
            entry_id = self._entry_ids[row]
            self.entry_deleted.emit(entry_id)

        self.removeRow(row)
        self._entry_ids.pop(row)
        self._update_delete_buttons()

    def _update_delete_buttons(self):
        for row in range(self.rowCount()):
            delete_button = QPushButton("🗑")
            delete_button.setFixedSize(30, 30)
            delete_button.clicked.connect(lambda _, r=row: self._delete_row(r))
            self.setCellWidget(row, 3, delete_button)
