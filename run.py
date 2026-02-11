#!/usr/bin/env python3
"""Run the password manager application."""
import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent / "src"))

from password_manager.app import main

if __name__ == "__main__":
    main()
