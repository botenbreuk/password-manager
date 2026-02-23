# -*- mode: python ; coding: utf-8 -*-
"""PyInstaller spec file for Password Manager."""
import sys
from pathlib import Path

block_cipher = None

PROJECT_ROOT = Path(SPECPATH).parent
SRC_DIR = PROJECT_ROOT / "src" / "password_manager"
RELEASE_DIR = PROJECT_ROOT / "release"

# Determine platform-specific icon
if sys.platform == "darwin":
    icon_file = str(RELEASE_DIR / "icons" / "icon.icns")
elif sys.platform == "win32":
    icon_file = str(RELEASE_DIR / "icons" / "icon.ico")
else:
    icon_file = str(RELEASE_DIR / "icons" / "icon.png")

# Collect QML files preserving directory structure
qml_datas = []
for qml_file in SRC_DIR.rglob("*.qml"):
    rel = qml_file.relative_to(SRC_DIR)
    qml_datas.append((str(qml_file), str(rel.parent)))

# Collect qmldir manifest
qmldir_path = SRC_DIR / "qml" / "components" / "qmldir"
if qmldir_path.exists():
    qml_datas.append((str(qmldir_path), "qml/components"))

# Collect font resources
font_path = SRC_DIR / "resources" / "fonts" / "MaterialIcons-Regular.ttf"
if font_path.exists():
    qml_datas.append((str(font_path), "resources/fonts"))

a = Analysis(
    [str(SRC_DIR / "app.py")],
    pathex=[str(PROJECT_ROOT / "src")],
    binaries=[],
    datas=qml_datas,
    hiddenimports=[
        "password_manager",
        "password_manager.app",
        "password_manager.controllers",
        "password_manager.controllers.vault_controller",
        "password_manager.controllers.password_controller",
        "password_manager.models",
        "password_manager.models.password_model",
        "password_manager.models.recent_vaults_model",
        "password_manager.core",
        "password_manager.core.vault",
        "password_manager.core.validators",
        "password_manager.core.totp",
        "password_manager.config",
        "password_manager.config.settings",
        "sqlcipher3",
        "PyQt6.QtCore",
        "PyQt6.QtGui",
        "PyQt6.QtQml",
        "PyQt6.QtQuick",
        "PyQt6.QtQuickControls2",
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

if sys.platform == "darwin":
    # macOS: create .app bundle via COLLECT + BUNDLE
    exe = EXE(
        pyz,
        a.scripts,
        [],
        exclude_binaries=True,
        name="PasswordManager",
        debug=False,
        bootloader_ignore_signals=False,
        strip=False,
        upx=True,
        upx_exclude=[],
        runtime_tmpdir=None,
        console=False,
        disable_windowed_traceback=False,
        argv_emulation=False,
        target_arch=None,
        codesign_identity=None,
        entitlements_file=None,
        icon=icon_file,
    )

    coll = COLLECT(
        exe,
        a.binaries,
        a.zipfiles,
        a.datas,
        strip=False,
        upx=True,
        upx_exclude=[],
        name="PasswordManager",
    )

    app = BUNDLE(
        coll,
        name="PasswordManager.app",
        icon=icon_file,
        bundle_identifier="com.passwordmanager.app",
        info_plist={
            "CFBundleDisplayName": "Password Manager",
            "CFBundleShortVersionString": "0.1.0",
            "CFBundleIconFile": "icon.icns",
            "NSHighResolutionCapable": True,
        },
    )
else:
    # Windows/Linux: single executable
    exe = EXE(
        pyz,
        a.scripts,
        a.binaries,
        a.zipfiles,
        a.datas,
        [],
        name="PasswordManager",
        debug=False,
        bootloader_ignore_signals=False,
        strip=False,
        upx=True,
        upx_exclude=[],
        runtime_tmpdir=None,
        console=False,
        disable_windowed_traceback=False,
        argv_emulation=False,
        target_arch=None,
        codesign_identity=None,
        entitlements_file=None,
        icon=icon_file,
    )
