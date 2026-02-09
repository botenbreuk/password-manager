import sys
from pathlib import Path

from PyQt6.QtGui import QGuiApplication, QFontDatabase
from PyQt6.QtQml import QQmlApplicationEngine

from models import VaultController


def main():
    app = QGuiApplication(sys.argv)
    app.setApplicationName("Password Manager")

    # Load Material Icons font
    font_path = Path(__file__).parent / "resources" / "MaterialIcons-Regular.ttf"
    QFontDatabase.addApplicationFont(str(font_path))

    # Create vault controller with app as parent to control lifetime
    vault_controller = VaultController(app)

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("vaultController", vault_controller)

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
