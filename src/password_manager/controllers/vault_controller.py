from pathlib import Path

from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QThread

from password_manager.core.vault import VaultManager
from password_manager.models.recent_vaults_model import RecentVaultsModel
from password_manager.config.settings import SettingsManager
from password_manager.core.validators import validate_password


class VaultWorker(QThread):
    """Worker thread for vault operations to avoid UI freezing."""
    finished = pyqtSignal(bool, str)  # success, error_message

    def __init__(self, vault: VaultManager, operation: str, **kwargs):
        super().__init__()
        self._vault = vault
        self._operation = operation
        self._kwargs = kwargs
        self._result = False

    def run(self):
        try:
            if self._operation == "open":
                self._result = self._vault.open(
                    Path(self._kwargs["path"]),
                    self._kwargs["password"]
                )
                if self._result:
                    self.finished.emit(True, "")
                else:
                    self.finished.emit(False, "Incorrect password")
            elif self._operation == "create":
                self._vault.create(
                    Path(self._kwargs["path"]),
                    self._kwargs["name"],
                    self._kwargs["password"]
                )
                self._result = True
                self.finished.emit(True, "")
        except Exception as e:
            self.finished.emit(False, str(e))


class VaultController(QObject):
    vaultOpened = pyqtSignal()
    vaultCreated = pyqtSignal()
    vaultClosed = pyqtSignal()
    vaultError = pyqtSignal(str)

    vaultNameChanged = pyqtSignal()
    recentVaultsChanged = pyqtSignal()
    loadingChanged = pyqtSignal()

    def __init__(self, password_controller=None, parent=None):
        super().__init__(parent)
        self._vault = VaultManager()
        self._password_controller = password_controller
        self._recent_vaults_model = RecentVaultsModel(self)
        self._settings = SettingsManager()
        self._vault_name = ""
        self._loading = False
        self._worker = None
        self._pending_vault_path = None
        self._pending_vault_name = None
        self._load_recent_vaults()

    @pyqtProperty(bool, notify=loadingChanged)
    def loading(self):
        return self._loading

    def _set_loading(self, value: bool):
        if self._loading != value:
            self._loading = value
            self.loadingChanged.emit()

    def _load_recent_vaults(self):
        vaults = self._settings.get_recent_vaults()
        self._recent_vaults_model.load_vaults(vaults)

    def _on_vault_ready(self):
        """Called when vault is opened or created to sync with password controller."""
        if self._password_controller:
            self._password_controller.set_vault(self._vault)

    @pyqtProperty(RecentVaultsModel, notify=recentVaultsChanged)
    def recentVaultsModel(self):
        return self._recent_vaults_model

    @pyqtProperty(str, notify=vaultNameChanged)
    def vaultName(self):
        return self._vault_name.capitalize() if self._vault_name else ""

    @pyqtSlot(str, result=bool)
    def vaultExists(self, path: str) -> bool:
        return VaultManager.exists(Path(path))

    @pyqtSlot(str, str, str)
    def createVault(self, path: str, name: str, master_password: str):
        if self._loading:
            return
        self._set_loading(True)
        self._pending_vault_path = path
        self._pending_vault_name = name
        # Create parent directory synchronously (fast operation)
        vault_path = Path(path)
        vault_path.parent.mkdir(parents=True, exist_ok=True)
        self._worker = VaultWorker(self._vault, "create", path=path, name=name, password=master_password)
        self._worker.finished.connect(self._on_create_finished)
        self._worker.start()

    def _on_create_finished(self, success: bool, error: str):
        self._set_loading(False)
        if success:
            self._vault_name = self._pending_vault_name
            self.vaultNameChanged.emit()
            self._on_vault_ready()
            self._settings.add_recent_vault(self._pending_vault_path, self._pending_vault_name)
            self._load_recent_vaults()
            self.recentVaultsChanged.emit()
            self.vaultCreated.emit()
        else:
            self.vaultError.emit(error or "Failed to create vault")
        self._pending_vault_path = None
        self._pending_vault_name = None
        self._worker = None

    @pyqtSlot(str, str)
    def openVault(self, path: str, master_password: str):
        if self._loading:
            return
        self._set_loading(True)
        self._pending_vault_path = path
        self._worker = VaultWorker(self._vault, "open", path=path, password=master_password)
        self._worker.finished.connect(self._on_open_finished)
        self._worker.start()

    def _on_open_finished(self, success: bool, error: str):
        self._set_loading(False)
        if success:
            self._vault_name = self._vault.vault_name
            self.vaultNameChanged.emit()
            self._on_vault_ready()
            self._settings.add_recent_vault(self._pending_vault_path, self._vault_name)
            self._load_recent_vaults()
            self.recentVaultsChanged.emit()
            self.vaultOpened.emit()
        else:
            self.vaultError.emit(error or "Failed to open vault")
        self._pending_vault_path = None
        self._worker = None

    @pyqtSlot()
    def closeVault(self):
        self._vault.close()
        self._vault_name = ""
        self.vaultNameChanged.emit()
        if self._password_controller:
            self._password_controller.clear()
        self.vaultClosed.emit()

    @pyqtSlot(int, result=str)
    def getRecentVaultPath(self, row: int) -> str:
        return self._recent_vaults_model.get_path(row)

    @pyqtSlot(int)
    def removeRecentVault(self, row: int):
        path = self._recent_vaults_model.get_path(row)
        if path:
            self._settings.remove_recent_vault(path)
            self._recent_vaults_model.remove_vault(row)
            self.recentVaultsChanged.emit()

    @pyqtSlot()
    def clearRecentVaults(self):
        self._settings.clear_recent_vaults()
        self._recent_vaults_model.load_vaults([])
        self.recentVaultsChanged.emit()

    @pyqtSlot(str, result=bool)
    def validateMasterPassword(self, password: str) -> bool:
        return validate_password(password)

    @pyqtSlot(str, result=bool)
    def changeVaultName(self, new_name: str) -> bool:
        """Change the vault name."""
        if not new_name.strip():
            return False
        self._vault.change_vault_name(new_name.strip())
        self._vault_name = new_name.strip()
        self.vaultNameChanged.emit()
        # Update recent vaults with new name
        if self._vault.vault_path:
            self._settings.add_recent_vault(str(self._vault.vault_path), self._vault_name)
            self._load_recent_vaults()
            self.recentVaultsChanged.emit()
        return True

    @pyqtSlot(str, str, result=bool)
    def changeMasterPassword(self, current_password: str, new_password: str) -> bool:
        """Change the master password."""
        return self._vault.change_master_password(current_password, new_password)
