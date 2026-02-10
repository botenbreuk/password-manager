from pathlib import Path

from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QUrl
from PyQt6.QtGui import QClipboard, QGuiApplication

from vault import VaultManager
from models.password_model import PasswordListModel
from validators import validate_url, validate_username, validate_password


class VaultController(QObject):
    vaultOpened = pyqtSignal()
    vaultCreated = pyqtSignal()
    vaultError = pyqtSignal(str)
    showSetupWizard = pyqtSignal()
    showUnlockDialog = pyqtSignal()

    vaultNameChanged = pyqtSignal()
    urlErrorChanged = pyqtSignal()
    usernameErrorChanged = pyqtSignal()
    passwordErrorChanged = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._vault = VaultManager()
        self._password_model = PasswordListModel(self)
        self._vault_name = ""
        self._url_error = ""
        self._username_error = ""
        self._password_error = ""

    @pyqtProperty(PasswordListModel, constant=True)
    def passwordModel(self):
        return self._password_model

    @pyqtProperty(str, notify=vaultNameChanged)
    def vaultName(self):
        return self._vault_name.capitalize() if self._vault_name else ""

    @pyqtProperty(str, notify=urlErrorChanged)
    def urlError(self):
        return self._url_error

    @pyqtProperty(str, notify=usernameErrorChanged)
    def usernameError(self):
        return self._username_error

    @pyqtProperty(str, notify=passwordErrorChanged)
    def passwordError(self):
        return self._password_error

    @pyqtSlot(str, result=bool)
    def vaultExists(self, path: str) -> bool:
        return VaultManager.exists(Path(path))

    @pyqtSlot(str, str, str)
    def createVault(self, path: str, name: str, master_password: str):
        try:
            vault_path = Path(path)
            vault_path.parent.mkdir(parents=True, exist_ok=True)
            self._vault.create(vault_path, name, master_password)
            self._vault_name = name
            self.vaultNameChanged.emit()
            self._load_entries()
            self.vaultCreated.emit()
        except Exception as e:
            self.vaultError.emit(str(e))

    @pyqtSlot(str, str, result=bool)
    def openVault(self, path: str, master_password: str) -> bool:
        if self._vault.open(Path(path), master_password):
            self._vault_name = self._vault.vault_name
            self.vaultNameChanged.emit()
            self._load_entries()
            self.vaultOpened.emit()
            return True
        return False

    @pyqtSlot()
    def closeVault(self):
        self._vault.close()

    def _load_entries(self):
        entries = self._vault.get_all_passwords()
        self._password_model.load_entries(entries)

    @pyqtSlot(str, str, str, result=bool)
    def addEntry(self, website: str, username: str, password: str) -> bool:
        # Validate
        valid = True

        if not validate_url(website):
            self._url_error = "Enter a valid URL (e.g., example.com)"
            valid = False
        else:
            self._url_error = ""
        self.urlErrorChanged.emit()

        if not validate_username(username):
            self._username_error = "Username cannot be empty"
            valid = False
        else:
            self._username_error = ""
        self.usernameErrorChanged.emit()

        if not password.strip():
            self._password_error = "Password cannot be empty"
            valid = False
        else:
            self._password_error = ""
        self.passwordErrorChanged.emit()

        if not valid:
            return False

        entry_id = self._vault.add_password(website, username, password)
        self._password_model.add_entry(entry_id, website, username, password)
        return True

    @pyqtSlot(int)
    def deleteEntry(self, row: int):
        entry_id = self._password_model.getEntryId(row)
        if entry_id >= 0:
            self._vault.delete_password(entry_id)
            self._password_model.remove_entry(row)

    @pyqtSlot(int, str, str, str, result=bool)
    def updateEntry(self, row: int, website: str, username: str, password: str) -> bool:
        # Validate
        valid = True

        if not validate_url(website):
            self._url_error = "Enter a valid URL (e.g., example.com)"
            valid = False
        else:
            self._url_error = ""
        self.urlErrorChanged.emit()

        if not validate_username(username):
            self._username_error = "Username cannot be empty"
            valid = False
        else:
            self._username_error = ""
        self.usernameErrorChanged.emit()

        if not password.strip():
            self._password_error = "Password cannot be empty"
            valid = False
        else:
            self._password_error = ""
        self.passwordErrorChanged.emit()

        if not valid:
            return False

        entry_id = self._password_model.getEntryId(row)
        if entry_id >= 0:
            self._vault.update_password(entry_id, website, username, password)
            self._password_model.update_entry(row, website, username, password)
            return True
        return False

    @pyqtSlot(int, result=str)
    def getWebsite(self, row: int) -> str:
        return self._password_model.getWebsite(row)

    @pyqtSlot(int, result=str)
    def getUsername(self, row: int) -> str:
        return self._password_model.getUsername(row)

    @pyqtSlot(int, result=str)
    def getPassword(self, row: int) -> str:
        return self._password_model.getPassword(row)

    @pyqtSlot(int)
    def copyPassword(self, row: int):
        password = self._password_model.getPassword(row)
        if password:
            clipboard = QGuiApplication.clipboard()
            clipboard.setText(password)

    @pyqtSlot(int)
    def togglePasswordVisibility(self, row: int):
        self._password_model.toggleVisibility(row)

    @pyqtSlot(str, result=bool)
    def validateMasterPassword(self, password: str) -> bool:
        return validate_password(password)

    @pyqtSlot(str, result=bool)
    def validateUrl(self, url: str) -> bool:
        return validate_url(url)

    @pyqtSlot(str, result=bool)
    def validateUsername(self, username: str) -> bool:
        return validate_username(username)
