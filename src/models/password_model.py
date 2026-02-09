from PyQt6.QtCore import QAbstractListModel, Qt, QModelIndex, pyqtSlot, QByteArray


class PasswordListModel(QAbstractListModel):
    IdRole = Qt.ItemDataRole.UserRole + 1
    WebsiteRole = Qt.ItemDataRole.UserRole + 2
    UsernameRole = Qt.ItemDataRole.UserRole + 3
    PasswordRole = Qt.ItemDataRole.UserRole + 4
    VisibleRole = Qt.ItemDataRole.UserRole + 5

    def __init__(self, parent=None):
        super().__init__(parent)
        self._entries = []

    def rowCount(self, parent=QModelIndex()):
        return len(self._entries)

    def data(self, index, role=Qt.ItemDataRole.DisplayRole):
        if not index.isValid() or index.row() >= len(self._entries):
            return None

        entry = self._entries[index.row()]

        if role == self.IdRole:
            return entry['id']
        elif role == self.WebsiteRole:
            return entry['website']
        elif role == self.UsernameRole:
            return entry['username']
        elif role == self.PasswordRole:
            return entry['password']
        elif role == self.VisibleRole:
            return entry['visible']

        return None

    def roleNames(self):
        return {
            self.IdRole: QByteArray(b'entryId'),
            self.WebsiteRole: QByteArray(b'website'),
            self.UsernameRole: QByteArray(b'username'),
            self.PasswordRole: QByteArray(b'password'),
            self.VisibleRole: QByteArray(b'visible'),
        }

    def load_entries(self, entries: list):
        self.beginResetModel()
        self._entries = []
        for entry_id, website, username, password in entries:
            self._entries.append({
                'id': entry_id,
                'website': website,
                'username': username,
                'password': password,
                'visible': False
            })
        self.endResetModel()

    def add_entry(self, entry_id: int, website: str, username: str, password: str):
        self.beginInsertRows(QModelIndex(), len(self._entries), len(self._entries))
        self._entries.append({
            'id': entry_id,
            'website': website,
            'username': username,
            'password': password,
            'visible': False
        })
        self.endInsertRows()

    @pyqtSlot(int)
    def toggleVisibility(self, row: int):
        if 0 <= row < len(self._entries):
            self._entries[row]['visible'] = not self._entries[row]['visible']
            index = self.index(row)
            self.dataChanged.emit(index, index, [self.VisibleRole])

    @pyqtSlot(int, result=str)
    def getPassword(self, row: int) -> str:
        if 0 <= row < len(self._entries):
            return self._entries[row]['password']
        return ""

    @pyqtSlot(int, result=int)
    def getEntryId(self, row: int) -> int:
        if 0 <= row < len(self._entries):
            return self._entries[row]['id']
        return -1

    def remove_entry(self, row: int):
        if 0 <= row < len(self._entries):
            self.beginRemoveRows(QModelIndex(), row, row)
            self._entries.pop(row)
            self.endRemoveRows()
