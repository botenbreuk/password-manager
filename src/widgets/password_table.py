from PyQt6.QtWidgets import (
    QTableWidget,
    QTableWidgetItem,
    QHeaderView,
    QPushButton,
)


class PasswordTable(QTableWidget):
    def __init__(self):
        super().__init__()
        self.setColumnCount(4)
        self.setHorizontalHeaderLabels(["Website", "Username", "Password", ""])
        self.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeMode.Stretch)
        self.horizontalHeader().setSectionResizeMode(1, QHeaderView.ResizeMode.Stretch)
        self.horizontalHeader().setSectionResizeMode(2, QHeaderView.ResizeMode.Stretch)
        self.horizontalHeader().setSectionResizeMode(3, QHeaderView.ResizeMode.Fixed)
        self.setColumnWidth(3, 50)

    def add_entry(self, site: str, username: str):
        row = self.rowCount()
        self.insertRow(row)
        self.setItem(row, 0, QTableWidgetItem(site))
        self.setItem(row, 1, QTableWidgetItem(username))
        self.setItem(row, 2, QTableWidgetItem("••••••••"))

        delete_button = QPushButton("🗑")
        delete_button.setFixedSize(30, 30)
        delete_button.clicked.connect(lambda _, r=row: self._delete_row(r))
        self.setCellWidget(row, 3, delete_button)

    def _delete_row(self, row: int):
        self.removeRow(row)
        self._update_delete_buttons()

    def _update_delete_buttons(self):
        for row in range(self.rowCount()):
            delete_button = QPushButton("🗑")
            delete_button.setFixedSize(30, 30)
            delete_button.clicked.connect(lambda _, r=row: self._delete_row(r))
            self.setCellWidget(row, 3, delete_button)
