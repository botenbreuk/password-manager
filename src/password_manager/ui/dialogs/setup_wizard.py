from pathlib import Path

from PyQt6.QtWidgets import (
    QDialog,
    QVBoxLayout,
    QLabel,
    QLineEdit,
    QPushButton,
    QFileDialog,
    QHBoxLayout,
)
from PyQt6.QtCore import Qt

from password_manager.config.styles import INVALID_STYLE, VALID_STYLE, ERROR_LABEL_STYLE
from password_manager.core.validators import validate_password


class SetupWizard(QDialog):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Create New Vault")
        self.setMinimumWidth(400)
        self.setModal(True)

        self.vault_path: Path = None
        self.vault_name: str = None
        self.master_password: str = None

        layout = QVBoxLayout(self)

        # Header
        header = QLabel("Setup Your Password Vault")
        header.setStyleSheet("font-size: 18px; font-weight: bold; margin-bottom: 10px;")
        header.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(header)

        # Description
        desc = QLabel("Create a secure vault to store your passwords.\nThe database will be encrypted with your master password.")
        desc.setAlignment(Qt.AlignmentFlag.AlignCenter)
        desc.setStyleSheet("margin-bottom: 20px;")
        layout.addWidget(desc)

        # Step 1: Vault name
        step1 = QLabel("Step 1: Choose a name for your vault")
        step1.setStyleSheet("font-weight: bold;")
        layout.addWidget(step1)

        self.name_input = QLineEdit()
        self.name_input.setPlaceholderText("e.g., Personal, Work, Family")
        layout.addWidget(self.name_input)

        self.name_error = QLabel("")
        self.name_error.setStyleSheet(ERROR_LABEL_STYLE)
        layout.addWidget(self.name_error)

        # Step 2: Master password
        step2 = QLabel("Step 2: Create a master password")
        step2.setStyleSheet("font-weight: bold; margin-top: 10px;")
        layout.addWidget(step2)

        self.password_input = QLineEdit()
        self.password_input.setPlaceholderText("Master password")
        self.password_input.setEchoMode(QLineEdit.EchoMode.Password)
        layout.addWidget(self.password_input)

        self.password_error = QLabel("")
        self.password_error.setStyleSheet(ERROR_LABEL_STYLE)
        layout.addWidget(self.password_error)

        self.confirm_input = QLineEdit()
        self.confirm_input.setPlaceholderText("Confirm master password")
        self.confirm_input.setEchoMode(QLineEdit.EchoMode.Password)
        layout.addWidget(self.confirm_input)

        self.confirm_error = QLabel("")
        self.confirm_error.setStyleSheet(ERROR_LABEL_STYLE)
        layout.addWidget(self.confirm_error)

        # Step 3: Vault location
        step3 = QLabel("Step 3: Choose where to save your vault")
        step3.setStyleSheet("font-weight: bold; margin-top: 10px;")
        layout.addWidget(step3)

        location_layout = QHBoxLayout()
        self.location_input = QLineEdit()
        self.location_input.setPlaceholderText("Vault file location")
        self.location_input.setReadOnly(True)
        location_layout.addWidget(self.location_input)

        browse_button = QPushButton("Browse...")
        browse_button.clicked.connect(self._browse_location)
        location_layout.addWidget(browse_button)
        layout.addLayout(location_layout)

        self.location_error = QLabel("")
        self.location_error.setStyleSheet(ERROR_LABEL_STYLE)
        layout.addWidget(self.location_error)

        # Buttons
        button_layout = QHBoxLayout()
        button_layout.addStretch()

        cancel_button = QPushButton("Cancel")
        cancel_button.clicked.connect(self.reject)
        button_layout.addWidget(cancel_button)

        create_button = QPushButton("Create Vault")
        create_button.clicked.connect(self._create_vault)
        button_layout.addWidget(create_button)

        layout.addLayout(button_layout)

    def _browse_location(self):
        name = self.name_input.text().strip() or "vault"
        file_path, _ = QFileDialog.getSaveFileName(
            self,
            "Save Vault File",
            f"{name}.vault",
            "Vault Files (*.vault)"
        )
        if file_path:
            self.location_input.setText(file_path)

    def _create_vault(self):
        valid = True

        # Validate name
        name = self.name_input.text().strip()
        if not name:
            self.name_input.setStyleSheet(INVALID_STYLE)
            self.name_error.setText("Vault name is required")
            valid = False
        else:
            self.name_input.setStyleSheet(VALID_STYLE)
            self.name_error.setText("")

        # Validate password
        password = self.password_input.text()
        if not validate_password(password):
            self.password_input.setStyleSheet(INVALID_STYLE)
            self.password_error.setText("Min 8 chars, upper, lower, digit, special")
            valid = False
        else:
            self.password_input.setStyleSheet(VALID_STYLE)
            self.password_error.setText("")

        # Validate confirmation
        confirm = self.confirm_input.text()
        if password != confirm:
            self.confirm_input.setStyleSheet(INVALID_STYLE)
            self.confirm_error.setText("Passwords do not match")
            valid = False
        else:
            self.confirm_input.setStyleSheet(VALID_STYLE)
            self.confirm_error.setText("")

        # Validate location
        location = self.location_input.text().strip()
        if not location:
            self.location_input.setStyleSheet(INVALID_STYLE)
            self.location_error.setText("Please choose a location for your vault")
            valid = False
        else:
            self.location_input.setStyleSheet(VALID_STYLE)
            self.location_error.setText("")

        if not valid:
            return

        self.vault_path = Path(location)
        self.vault_name = name
        self.master_password = password
        self.accept()
