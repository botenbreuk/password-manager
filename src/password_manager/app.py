import sys
from pathlib import Path

from PyQt6.QtGui import QGuiApplication, QFontDatabase
from PyQt6.QtQml import QQmlApplicationEngine

from password_manager.controllers.vault_controller import VaultController
from password_manager.controllers.password_controller import PasswordController


def main():
    app = QGuiApplication(sys.argv)
    app.setApplicationName("Password Manager")

    # Load Material Icons font
    font_path = Path(__file__).parent / "resources" / "fonts" / "MaterialIcons-Regular.ttf"
    QFontDatabase.addApplicationFont(str(font_path))

    # Create controllers with app as parent to control lifetime
    password_controller = PasswordController(app)
    vault_controller = VaultController(password_controller, app)

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("vaultController", vault_controller)
    engine.rootContext().setContextProperty("passwordController", password_controller)

    # Load main QML file
    qml_file = Path(__file__).parent / "qml" / "Main.qml"
    engine.load(str(qml_file))

    if not engine.rootObjects():
        sys.exit(-1)

    exit_code = app.exec()

    # Cleanup before exit
    del engine

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
