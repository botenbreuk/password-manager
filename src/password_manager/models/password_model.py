from PyQt6.QtCore import QAbstractListModel, Qt, QModelIndex, pyqtSlot, pyqtSignal, pyqtProperty, QByteArray


class PasswordListModel(QAbstractListModel):
    IdRole = Qt.ItemDataRole.UserRole + 1
    WebsiteRole = Qt.ItemDataRole.UserRole + 2
    UsernameRole = Qt.ItemDataRole.UserRole + 3
    PasswordRole = Qt.ItemDataRole.UserRole + 4
    VisibleRole = Qt.ItemDataRole.UserRole + 5
    TotpKeyRole = Qt.ItemDataRole.UserRole + 6
    HasTotpRole = Qt.ItemDataRole.UserRole + 7
    FavoriteRole = Qt.ItemDataRole.UserRole + 8

    favoriteCountChanged = pyqtSignal()

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
        elif role == self.TotpKeyRole:
            return entry['totp_key']
        elif role == self.HasTotpRole:
            return bool(entry['totp_key'])
        elif role == self.FavoriteRole:
            return entry['favorite']

        return None

    def roleNames(self):
        return {
            self.IdRole: QByteArray(b'entryId'),
            self.WebsiteRole: QByteArray(b'website'),
            self.UsernameRole: QByteArray(b'username'),
            self.PasswordRole: QByteArray(b'password'),
            self.VisibleRole: QByteArray(b'visible'),
            self.TotpKeyRole: QByteArray(b'totpKey'),
            self.HasTotpRole: QByteArray(b'hasTotp'),
            self.FavoriteRole: QByteArray(b'favorite'),
        }

    def load_entries(self, entries: list):
        self.beginResetModel()
        self._entries = []
        for entry_id, website, username, password, totp_key, favorite in entries:
            self._entries.append({
                'id': entry_id,
                'website': website,
                'username': username,
                'password': password,
                'totp_key': totp_key or '',
                'favorite': bool(favorite),
                'visible': False
            })
        self.endResetModel()
        self.favoriteCountChanged.emit()

    def add_entry(self, entry_id: int, website: str, username: str, password: str, totp_key: str = "", favorite: bool = False):
        self.beginInsertRows(QModelIndex(), len(self._entries), len(self._entries))
        self._entries.append({
            'id': entry_id,
            'website': website,
            'username': username,
            'password': password,
            'totp_key': totp_key,
            'favorite': favorite,
            'visible': False
        })
        self.endInsertRows()

    @pyqtSlot(int)
    def toggleVisibility(self, row: int):
        if 0 <= row < len(self._entries):
            self._entries[row]['visible'] = not self._entries[row]['visible']
            index = self.index(row)
            self.dataChanged.emit(index, index, [self.VisibleRole])

    def toggleFavorite(self, row: int):
        if 0 <= row < len(self._entries):
            self._entries[row]['favorite'] = not self._entries[row]['favorite']
            index = self.index(row)
            self.dataChanged.emit(index, index, [self.FavoriteRole])
            self.favoriteCountChanged.emit()
            return self._entries[row]['favorite']
        return False

    @pyqtSlot(int, result=bool)
    def isFavorite(self, row: int) -> bool:
        if 0 <= row < len(self._entries):
            return self._entries[row]['favorite']
        return False

    @pyqtProperty(int, notify=favoriteCountChanged)
    def favoriteCount(self) -> int:
        return sum(1 for entry in self._entries if entry.get('favorite', False))

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

    @pyqtSlot(int, result=str)
    def getWebsite(self, row: int) -> str:
        if 0 <= row < len(self._entries):
            return self._entries[row]['website']
        return ""

    @pyqtSlot(int, result=str)
    def getUsername(self, row: int) -> str:
        if 0 <= row < len(self._entries):
            return self._entries[row]['username']
        return ""

    @pyqtSlot(int, result=str)
    def getTotpKey(self, row: int) -> str:
        if 0 <= row < len(self._entries):
            return self._entries[row]['totp_key']
        return ""

    def remove_entry(self, row: int):
        if 0 <= row < len(self._entries):
            was_favorite = self._entries[row].get('favorite', False)
            self.beginRemoveRows(QModelIndex(), row, row)
            self._entries.pop(row)
            self.endRemoveRows()
            if was_favorite:
                self.favoriteCountChanged.emit()

    def update_entry(self, row: int, website: str, username: str, password: str, totp_key: str = ""):
        if 0 <= row < len(self._entries):
            self._entries[row]['website'] = website
            self._entries[row]['username'] = username
            self._entries[row]['password'] = password
            self._entries[row]['totp_key'] = totp_key
            index = self.index(row)
            self.dataChanged.emit(index, index, [self.WebsiteRole, self.UsernameRole, self.PasswordRole, self.TotpKeyRole, self.HasTotpRole])
