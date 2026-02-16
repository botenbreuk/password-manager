import json
import zipfile
import os
import tempfile
from pathlib import Path
from typing import Optional

import sqlcipher3


VAULT_INFO_FILE = "vault.json"
VAULT_DB_FILE = "vault.db"
VAULT_VERSION = "1.0"


class VaultManager:
    def __init__(self):
        self.vault_path: Optional[Path] = None
        self.master_password: Optional[str] = None
        self.vault_name: Optional[str] = None
        self.vault_version: Optional[str] = None
        self._db_path: Optional[Path] = None
        self._conn: Optional[sqlcipher3.Connection] = None

    @staticmethod
    def exists(path: Path) -> bool:
        return path.exists() and zipfile.is_zipfile(path)

    def create(self, path: Path, name: str, master_password: str):
        self.vault_path = path
        self.vault_name = name
        self.vault_version = VAULT_VERSION
        self.master_password = master_password

        # Create temporary encrypted database
        self._db_path = Path(tempfile.mktemp(suffix=".db"))
        self._conn = sqlcipher3.connect(str(self._db_path))
        self._conn.execute(f"PRAGMA key = '{master_password}'")
        self._init_database()

        # Save vault
        self._save()

    def open(self, path: Path, master_password: str) -> bool:
        self.vault_path = path
        self.master_password = master_password

        try:
            with zipfile.ZipFile(path, 'r') as zf:
                # Read vault info
                vault_info = json.loads(zf.read(VAULT_INFO_FILE))
                self.vault_name = vault_info.get("name", "Unknown")
                self.vault_version = vault_info.get("version", "1.0")

                # Extract encrypted database to temp file
                self._db_path = Path(tempfile.mktemp(suffix=".db"))
                self._db_path.write_bytes(zf.read(VAULT_DB_FILE))

            # Open with SQLCipher
            self._conn = sqlcipher3.connect(str(self._db_path))
            self._conn.execute(f"PRAGMA key = '{master_password}'")

            # Verify password by attempting a query
            self._conn.execute("SELECT count(*) FROM sqlite_master").fetchone()

            # Run migrations for existing vaults
            self._migrate_database()
            return True
        except Exception:
            self.vault_path = None
            self.master_password = None
            self.vault_name = None
            self.vault_version = None
            if self._db_path and self._db_path.exists():
                os.remove(self._db_path)
                self._db_path = None
            return False

    def close(self):
        if self._conn:
            self._save()
            self._conn.close()
            self._conn = None
        if self._db_path and self._db_path.exists():
            os.remove(self._db_path)
            self._db_path = None

    def _save(self):
        if not self._conn or not self.vault_path:
            return

        self._conn.commit()

        # Create vault info
        vault_info = {"name": self.vault_name, "version": VAULT_VERSION}

        # Write zip file with encrypted database
        with zipfile.ZipFile(self.vault_path, 'w', zipfile.ZIP_DEFLATED) as zf:
            zf.writestr(VAULT_INFO_FILE, json.dumps(vault_info, indent=2))
            zf.write(self._db_path, VAULT_DB_FILE)

    def _init_database(self):
        cursor = self._conn.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS passwords (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                website TEXT NOT NULL,
                username TEXT NOT NULL,
                password TEXT NOT NULL,
                totp_key TEXT DEFAULT '',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        self._conn.commit()
        self._migrate_database()

    def _migrate_database(self):
        """Add totp_key column if it doesn't exist (for existing vaults)."""
        cursor = self._conn.cursor()
        cursor.execute("PRAGMA table_info(passwords)")
        columns = [col[1] for col in cursor.fetchall()]
        if 'totp_key' not in columns:
            cursor.execute("ALTER TABLE passwords ADD COLUMN totp_key TEXT DEFAULT ''")
            self._conn.commit()

    def add_password(self, website: str, username: str, password: str, totp_key: str = ""):
        cursor = self._conn.cursor()
        cursor.execute(
            "INSERT INTO passwords (website, username, password, totp_key) VALUES (?, ?, ?, ?)",
            (website, username, password, totp_key)
        )
        self._conn.commit()
        self._save()
        return cursor.lastrowid

    def get_all_passwords(self) -> list:
        cursor = self._conn.cursor()
        cursor.execute("SELECT id, website, username, password, totp_key FROM passwords")
        return cursor.fetchall()

    def delete_password(self, password_id: int):
        cursor = self._conn.cursor()
        cursor.execute("DELETE FROM passwords WHERE id = ?", (password_id,))
        self._conn.commit()
        self._save()

    def update_password(self, password_id: int, website: str, username: str, password: str, totp_key: str = ""):
        cursor = self._conn.cursor()
        cursor.execute(
            "UPDATE passwords SET website = ?, username = ?, password = ?, totp_key = ? WHERE id = ?",
            (website, username, password, totp_key, password_id)
        )
        self._conn.commit()
        self._save()

    def change_vault_name(self, new_name: str):
        """Change the vault name."""
        self.vault_name = new_name
        self._save()

    def change_master_password(self, current_password: str, new_password: str) -> bool:
        """Change the master password. Returns True if successful."""
        if current_password != self.master_password:
            return False

        try:
            # Re-key the database with the new password
            self._conn.execute(f"PRAGMA rekey = '{new_password}'")
            self.master_password = new_password
            self._save()
            return True
        except Exception as e:
            print(f"Error changing password: {e}")
            return False
