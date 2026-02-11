from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QUrl
from PyQt6.QtGui import QGuiApplication, QDesktopServices

from password_manager.core.vault import VaultManager
from password_manager.models.password_model import PasswordListModel
from password_manager.core.validators import validate_url, validate_username, validate_totp_key
from password_manager.core.totp import generate_totp


class PasswordController(QObject):
    urlErrorChanged = pyqtSignal()
    usernameErrorChanged = pyqtSignal()
    passwordErrorChanged = pyqtSignal()
    totpErrorChanged = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._vault: VaultManager = None
        self._password_model = PasswordListModel(self)
        self._url_error = ""
        self._username_error = ""
        self._password_error = ""
        self._totp_error = ""

    def set_vault(self, vault: VaultManager):
        """Set the vault manager and load entries."""
        self._vault = vault
        self._load_entries()

    def clear(self):
        """Clear the password model when vault is closed."""
        self._vault = None
        self._password_model.load_entries([])

    def _load_entries(self):
        if self._vault:
            entries = self._vault.get_all_passwords()
            self._password_model.load_entries(entries)

    @pyqtProperty(PasswordListModel, constant=True)
    def passwordModel(self):
        return self._password_model

    @pyqtProperty(str, notify=urlErrorChanged)
    def urlError(self):
        return self._url_error

    @pyqtProperty(str, notify=usernameErrorChanged)
    def usernameError(self):
        return self._username_error

    @pyqtProperty(str, notify=passwordErrorChanged)
    def passwordError(self):
        return self._password_error

    @pyqtProperty(str, notify=totpErrorChanged)
    def totpError(self):
        return self._totp_error

    def _validate_entry(self, website: str, username: str, password: str, totp_key: str) -> bool:
        """Validate entry fields and set error messages."""
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

        if totp_key and not validate_totp_key(totp_key):
            self._totp_error = "Invalid TOTP key (must be base32: A-Z, 2-7)"
            valid = False
        else:
            self._totp_error = ""
        self.totpErrorChanged.emit()

        return valid

    @pyqtSlot(str, str, str, str, result=bool)
    def addEntry(self, website: str, username: str, password: str, totp_key: str = "") -> bool:
        if not self._vault:
            return False

        if not self._validate_entry(website, username, password, totp_key):
            return False

        entry_id = self._vault.add_password(website, username, password, totp_key)
        self._password_model.add_entry(entry_id, website, username, password, totp_key)
        return True

    @pyqtSlot(int)
    def deleteEntry(self, row: int):
        if not self._vault:
            return

        entry_id = self._password_model.getEntryId(row)
        if entry_id >= 0:
            self._vault.delete_password(entry_id)
            self._password_model.remove_entry(row)

    @pyqtSlot(int, str, str, str, str, result=bool)
    def updateEntry(self, row: int, website: str, username: str, password: str, totp_key: str = "") -> bool:
        if not self._vault:
            return False

        if not self._validate_entry(website, username, password, totp_key):
            return False

        entry_id = self._password_model.getEntryId(row)
        if entry_id >= 0:
            self._vault.update_password(entry_id, website, username, password, totp_key)
            self._password_model.update_entry(row, website, username, password, totp_key)
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

    @pyqtSlot(int, result=str)
    def getTotpKey(self, row: int) -> str:
        return self._password_model.getTotpKey(row)

    @pyqtSlot(int)
    def copyPassword(self, row: int):
        password = self._password_model.getPassword(row)
        if password:
            clipboard = QGuiApplication.clipboard()
            clipboard.setText(password)

    @pyqtSlot(int)
    def copyUsername(self, row: int):
        username = self._password_model.getUsername(row)
        if username:
            clipboard = QGuiApplication.clipboard()
            clipboard.setText(username)

    @pyqtSlot(int)
    def copyTotp(self, row: int):
        totp_key = self._password_model.getTotpKey(row)
        if totp_key:
            code = generate_totp(totp_key)
            if code:
                clipboard = QGuiApplication.clipboard()
                clipboard.setText(code)

    @pyqtSlot(int, result=str)
    def generateTotp(self, row: int) -> str:
        totp_key = self._password_model.getTotpKey(row)
        if totp_key:
            return generate_totp(totp_key)
        return ""

    @pyqtSlot(int)
    def openWebsite(self, row: int):
        website = self._password_model.getWebsite(row)
        if website:
            if not website.startswith("http://") and not website.startswith("https://"):
                website = "https://" + website
            QDesktopServices.openUrl(QUrl(website))

    @pyqtSlot(int)
    def togglePasswordVisibility(self, row: int):
        self._password_model.toggleVisibility(row)
