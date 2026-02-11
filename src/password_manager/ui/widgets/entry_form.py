from PyQt6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QLineEdit,
    QPushButton,
    QLabel,
)
from PyQt6.QtCore import pyqtSignal

from password_manager.config.styles import VALID_STYLE, INVALID_STYLE, ERROR_LABEL_STYLE
from password_manager.core.validators import validate_url, validate_username

class EntryForm(QWidget):
    entry_added = pyqtSignal(str, str, str)

    def __init__(self):
        super().__init__()
        layout = QVBoxLayout(self)

        # Website field
        self.site_input = QLineEdit()
        self.site_input.setPlaceholderText("Website")
        self.site_input.returnPressed.connect(self._submit)
        self.site_error = QLabel("")
        self.site_error.setStyleSheet(ERROR_LABEL_STYLE)
        layout.addWidget(self.site_input)
        layout.addWidget(self.site_error)

        # Username field
        self.username_input = QLineEdit()
        self.username_input.setPlaceholderText("Username")
        self.username_input.returnPressed.connect(self._submit)
        self.username_error = QLabel("")
        self.username_error.setStyleSheet(ERROR_LABEL_STYLE)
        layout.addWidget(self.username_input)
        layout.addWidget(self.username_error)

        # Password field
        self.password_input = QLineEdit()
        self.password_input.setPlaceholderText("Password")
        self.password_input.setEchoMode(QLineEdit.EchoMode.Password)
        self.password_input.returnPressed.connect(self._submit)
        self.password_error = QLabel("")
        self.password_error.setStyleSheet(ERROR_LABEL_STYLE)
        layout.addWidget(self.password_input)
        layout.addWidget(self.password_error)

        # Add button
        self.add_button = QPushButton("Add")
        self.add_button.clicked.connect(self._submit)
        layout.addWidget(self.add_button)

        layout.addStretch()

    def _submit(self):
        site = self.site_input.text()
        username = self.username_input.text()
        password = self.password_input.text()

        valid = True

        if not validate_url(site):
            self.site_input.setStyleSheet(INVALID_STYLE)
            self.site_error.setText("Enter a valid URL (e.g., example.com)")
            valid = False
        else:
            self.site_input.setStyleSheet(VALID_STYLE)
            self.site_error.setText("")

        if not validate_username(username):
            self.username_input.setStyleSheet(INVALID_STYLE)
            self.username_error.setText("Username cannot be empty")
            valid = False
        else:
            self.username_input.setStyleSheet(VALID_STYLE)
            self.username_error.setText("")

        if not password.strip():
            self.password_input.setStyleSheet(INVALID_STYLE)
            self.password_error.setText("Password cannot be empty")
            valid = False
        else:
            self.password_input.setStyleSheet(VALID_STYLE)
            self.password_error.setText("")

        if not valid:
            return

        self.entry_added.emit(site, username, password)
        self._clear()

    def _clear(self):
        self.site_input.clear()
        self.username_input.clear()
        self.password_input.clear()
        self.site_input.setFocus()
