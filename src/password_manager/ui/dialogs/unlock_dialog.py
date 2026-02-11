from pathlib import Path

from PyQt6.QtWidgets import (
    QDialog,
    QVBoxLayout,
    QLabel,
    QLineEdit,
    QPushButton,
    QHBoxLayout,
    QFileDialog,
)
from PyQt6.QtCore import Qt

from password_manager.config.styles import INVALID_STYLE, VALID_STYLE, ERROR_LABEL_STYLE


class UnlockDialog(QDialog):
    def __init__(self, vault_path: Path = None, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Unlock Vault")
        self.setMinimumWidth(400)
        self.setModal(True)

        self.vault_path = vault_path
        self.master_password: str = None
        self.create_new = False

        layout = QVBoxLayout(self)

        # Header
        header = QLabel("Unlock Your Vault")
        header.setStyleSheet("font-size: 18px; font-weight: bold; margin-bottom: 10px;")
        header.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(header)

        # Vault file selection
        if not vault_path:
            file_label = QLabel("Vault file:")
            layout.addWidget(file_label)

            file_layout = QHBoxLayout()
            self.file_input = QLineEdit()
            self.file_input.setPlaceholderText("Select vault file...")
            self.file_input.setReadOnly(True)
            file_layout.addWidget(self.file_input)

            browse_button = QPushButton("Browse...")
            browse_button.clicked.connect(self._browse_file)
            file_layout.addWidget(browse_button)
            layout.addLayout(file_layout)

            self.file_error = QLabel("")
            self.file_error.setStyleSheet(ERROR_LABEL_STYLE)
            layout.addWidget(self.file_error)
        else:
            vault_label = QLabel(f"Vault: {vault_path.name}")
            vault_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
            layout.addWidget(vault_label)

        # Password input
        password_label = QLabel("Master password:")
        password_label.setStyleSheet("margin-top: 10px;")
        layout.addWidget(password_label)

        self.password_input = QLineEdit()
        self.password_input.setPlaceholderText("Enter your master password")
        self.password_input.setEchoMode(QLineEdit.EchoMode.Password)
        self.password_input.returnPressed.connect(self._unlock)
        layout.addWidget(self.password_input)

        self.password_error = QLabel("")
        self.password_error.setStyleSheet(ERROR_LABEL_STYLE)
        layout.addWidget(self.password_error)

        # Buttons
        button_layout = QHBoxLayout()

        new_vault_button = QPushButton("Create New Vault")
        new_vault_button.clicked.connect(self._create_new)
        button_layout.addWidget(new_vault_button)

        button_layout.addStretch()

        cancel_button = QPushButton("Cancel")
        cancel_button.clicked.connect(self.reject)
        button_layout.addWidget(cancel_button)

        unlock_button = QPushButton("Unlock")
        unlock_button.clicked.connect(self._unlock)
        button_layout.addWidget(unlock_button)

        layout.addLayout(button_layout)

    def _browse_file(self):
        file_path, _ = QFileDialog.getOpenFileName(
            self,
            "Open Vault File",
            "",
            "Vault Files (*.vault)"
        )
        if file_path:
            self.file_input.setText(file_path)
            self.vault_path = Path(file_path)

    def _unlock(self):
        valid = True

        # Validate file if no preset path
        if not self.vault_path:
            file_path = self.file_input.text().strip()
            if not file_path:
                self.file_input.setStyleSheet(INVALID_STYLE)
                self.file_error.setText("Please select a vault file")
                valid = False
            else:
                self.vault_path = Path(file_path)
                self.file_input.setStyleSheet(VALID_STYLE)
                self.file_error.setText("")

        # Validate password
        password = self.password_input.text()
        if not password:
            self.password_input.setStyleSheet(INVALID_STYLE)
            self.password_error.setText("Password is required")
            valid = False
        else:
            self.password_input.setStyleSheet(VALID_STYLE)
            self.password_error.setText("")

        if not valid:
            return

        self.master_password = password
        self.accept()

    def _create_new(self):
        self.create_new = True
        self.accept()
