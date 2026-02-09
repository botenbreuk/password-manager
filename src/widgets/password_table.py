from PyQt6.QtWidgets import (
    QTableWidget,
    QTableWidgetItem,
    QHeaderView,
    QPushButton,
    QWidget,
    QHBoxLayout,
    QApplication,
)
from PyQt6.QtCore import pyqtSignal


class PasswordTable(QTableWidget):
    entry_deleted = pyqtSignal(int)

    def __init__(self):
        super().__init__()
        self._entry_ids = []
        self._passwords = []
        self._visible = []

        self.setColumnCount(5)
        self.setHorizontalHeaderLabels(["Website", "Username", "Password", "", ""])
        self.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeMode.Stretch)
        self.horizontalHeader().setSectionResizeMode(1, QHeaderView.ResizeMode.Stretch)
        self.horizontalHeader().setSectionResizeMode(2, QHeaderView.ResizeMode.Stretch)
        self.horizontalHeader().setSectionResizeMode(3, QHeaderView.ResizeMode.Fixed)
        self.horizontalHeader().setSectionResizeMode(4, QHeaderView.ResizeMode.Fixed)
        self.setColumnWidth(3, 80)
        self.setColumnWidth(4, 40)

    def load_entries(self, entries: list):
        self.setRowCount(0)
        self._entry_ids = []
        self._passwords = []
        self._visible = []

        for entry_id, website, username, password in entries:
            self._add_row(entry_id, website, username, password)

    def add_entry(self, entry_id: int, site: str, username: str, password: str):
        self._add_row(entry_id, site, username, password)

    def _add_row(self, entry_id: int, site: str, username: str, password: str):
        row = self.rowCount()
        self._entry_ids.append(entry_id)
        self._passwords.append(password)
        self._visible.append(False)

        self.insertRow(row)
        self.setItem(row, 0, QTableWidgetItem(site))
        self.setItem(row, 1, QTableWidgetItem(username))
        self.setItem(row, 2, QTableWidgetItem("••••••••"))

        # Action buttons (copy, show/hide)
        actions_widget = QWidget()
        actions_layout = QHBoxLayout(actions_widget)
        actions_layout.setContentsMargins(2, 2, 2, 2)
        actions_layout.setSpacing(2)

        copy_button = QPushButton("📋")
        copy_button.setFixedSize(30, 30)
        copy_button.setToolTip("Copy password")
        copy_button.clicked.connect(lambda _, r=row: self._copy_password(r))
        actions_layout.addWidget(copy_button)

        eye_button = QPushButton("👁")
        eye_button.setFixedSize(30, 30)
        eye_button.setToolTip("Show/hide password")
        eye_button.clicked.connect(lambda _, r=row: self._toggle_password(r))
        actions_layout.addWidget(eye_button)

        self.setCellWidget(row, 3, actions_widget)

        # Delete button
        delete_button = QPushButton("🗑")
        delete_button.setFixedSize(30, 30)
        delete_button.setToolTip("Delete")
        delete_button.clicked.connect(lambda _, r=row: self._delete_row(r))
        self.setCellWidget(row, 4, delete_button)

    def _copy_password(self, row: int):
        if row < len(self._passwords):
            clipboard = QApplication.clipboard()
            clipboard.setText(self._passwords[row])

    def _toggle_password(self, row: int):
        if row < len(self._visible):
            self._visible[row] = not self._visible[row]
            if self._visible[row]:
                self.item(row, 2).setText(self._passwords[row])
            else:
                self.item(row, 2).setText("••••••••")

    def _delete_row(self, row: int):
        if row < len(self._entry_ids):
            entry_id = self._entry_ids[row]
            self.entry_deleted.emit(entry_id)

        self.removeRow(row)
        self._entry_ids.pop(row)
        self._passwords.pop(row)
        self._visible.pop(row)
        self._update_buttons()

    def _update_buttons(self):
        for row in range(self.rowCount()):
            # Action buttons
            actions_widget = QWidget()
            actions_layout = QHBoxLayout(actions_widget)
            actions_layout.setContentsMargins(2, 2, 2, 2)
            actions_layout.setSpacing(2)

            copy_button = QPushButton("📋")
            copy_button.setFixedSize(30, 30)
            copy_button.setToolTip("Copy password")
            copy_button.clicked.connect(lambda _, r=row: self._copy_password(r))
            actions_layout.addWidget(copy_button)

            eye_button = QPushButton("👁")
            eye_button.setFixedSize(30, 30)
            eye_button.setToolTip("Show/hide password")
            eye_button.clicked.connect(lambda _, r=row: self._toggle_password(r))
            actions_layout.addWidget(eye_button)

            self.setCellWidget(row, 3, actions_widget)

            # Delete button
            delete_button = QPushButton("🗑")
            delete_button.setFixedSize(30, 30)
            delete_button.setToolTip("Delete")
            delete_button.clicked.connect(lambda _, r=row: self._delete_row(r))
            self.setCellWidget(row, 4, delete_button)
