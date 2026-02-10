import sys
from pathlib import Path
from PyQt6.QtCore import QSettings


class SettingsManager:
    MAX_RECENT_VAULTS = 5

    def __init__(self):
        if sys.platform == "win32":
            self._settings = QSettings(QSettings.Format.IniFormat, QSettings.Scope.UserScope, "PasswordManager", "PasswordManager")
        else:
            self._settings = QSettings("PasswordManager", "PasswordManager")

    def get_recent_vaults(self) -> list[dict]:
        """Returns list of recent vaults with name and path."""
        vaults = []
        size = self._settings.beginReadArray("recentVaults")
        for i in range(size):
            self._settings.setArrayIndex(i)
            path = self._settings.value("path", "")
            name = self._settings.value("name", "")
            if path and Path(path).exists():
                vaults.append({"path": path, "name": name})
        self._settings.endArray()
        return vaults

    def add_recent_vault(self, path: str, name: str):
        """Adds a vault to the recent list."""
        vaults = self.get_recent_vaults()

        # Remove if already exists
        vaults = [v for v in vaults if v["path"] != path]

        # Add to beginning
        vaults.insert(0, {"path": path, "name": name})

        # Keep only MAX_RECENT_VAULTS
        vaults = vaults[:self.MAX_RECENT_VAULTS]

        # Save
        self._settings.beginWriteArray("recentVaults")
        for i, vault in enumerate(vaults):
            self._settings.setArrayIndex(i)
            self._settings.setValue("path", vault["path"])
            self._settings.setValue("name", vault["name"])
        self._settings.endArray()

    def remove_recent_vault(self, path: str):
        """Removes a vault from the recent list."""
        vaults = self.get_recent_vaults()
        vaults = [v for v in vaults if v["path"] != path]

        self._settings.beginWriteArray("recentVaults")
        for i, vault in enumerate(vaults):
            self._settings.setArrayIndex(i)
            self._settings.setValue("path", vault["path"])
            self._settings.setValue("name", vault["name"])
        self._settings.endArray()

    def clear_recent_vaults(self):
        """Clears all recent vaults."""
        self._settings.beginWriteArray("recentVaults")
        self._settings.endArray()
