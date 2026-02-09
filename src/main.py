import sys
from pathlib import Path

from PyQt6.QtWidgets import QApplication, QMessageBox

from vault import VaultManager
from dialogs import SetupWizard, UnlockDialog
from windows import MainWindow


DEFAULT_VAULT_PATH = Path.home() / ".password_manager" / "default.vault"


def show_error(message: str):
    msg = QMessageBox()
    msg.setIcon(QMessageBox.Icon.Critical)
    msg.setWindowTitle("Error")
    msg.setText(message)
    msg.exec()


def main():
    app = QApplication(sys.argv)

    vault = VaultManager()

    while True:
        # Check if default vault exists
        if DEFAULT_VAULT_PATH.exists():
            # Show unlock dialog
            dialog = UnlockDialog(DEFAULT_VAULT_PATH)
            if dialog.exec() != UnlockDialog.DialogCode.Accepted:
                sys.exit(0)

            if dialog.create_new:
                # User wants to create a new vault
                wizard = SetupWizard()
                if wizard.exec() != SetupWizard.DialogCode.Accepted:
                    continue

                vault.create(wizard.vault_path, wizard.vault_name, wizard.master_password)
                break
            else:
                # Try to unlock
                if vault.open(dialog.vault_path, dialog.master_password):
                    break
                else:
                    show_error("Failed to unlock vault. Incorrect password?")
        else:
            # Show unlock dialog with option to browse or create new
            dialog = UnlockDialog()
            if dialog.exec() != UnlockDialog.DialogCode.Accepted:
                sys.exit(0)

            if dialog.create_new:
                # Create new vault
                wizard = SetupWizard()
                if wizard.exec() != SetupWizard.DialogCode.Accepted:
                    continue

                # Ensure parent directory exists
                wizard.vault_path.parent.mkdir(parents=True, exist_ok=True)
                vault.create(wizard.vault_path, wizard.vault_name, wizard.master_password)
                break
            else:
                # Try to unlock selected vault
                if vault.open(dialog.vault_path, dialog.master_password):
                    break
                else:
                    show_error("Failed to unlock vault. Incorrect password?")

    window = MainWindow(vault)
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
