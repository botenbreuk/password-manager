from PyQt6.QtCore import QAbstractListModel, Qt, QModelIndex, QByteArray


class RecentVaultsModel(QAbstractListModel):
    PathRole = Qt.ItemDataRole.UserRole + 1
    NameRole = Qt.ItemDataRole.UserRole + 2

    def __init__(self, parent=None):
        super().__init__(parent)
        self._vaults = []

    def rowCount(self, parent=QModelIndex()):
        return len(self._vaults)

    def data(self, index, role=Qt.ItemDataRole.DisplayRole):
        if not index.isValid() or index.row() >= len(self._vaults):
            return None

        vault = self._vaults[index.row()]

        if role == self.PathRole:
            return vault['path']
        elif role == self.NameRole:
            return vault['name']

        return None

    def roleNames(self):
        return {
            self.PathRole: QByteArray(b'path'),
            self.NameRole: QByteArray(b'name'),
        }

    def load_vaults(self, vaults: list):
        self.beginResetModel()
        self._vaults = vaults
        self.endResetModel()

    def remove_vault(self, row: int):
        if 0 <= row < len(self._vaults):
            self.beginRemoveRows(QModelIndex(), row, row)
            self._vaults.pop(row)
            self.endRemoveRows()

    def get_path(self, row: int) -> str:
        if 0 <= row < len(self._vaults):
            return self._vaults[row]['path']
        return ""
