# Password Manager

## Setup

### Create a virtual environment

```bash
python -m venv venv
```

### Activate the virtual environment

**macOS/Linux:**
```bash
source venv/bin/activate
```

**Windows:**
```bash
venv\Scripts\activate
```

### Install dependencies

```bash
pip install -r requirements.txt
```

## Running the Project

```bash
python src/main.py
```

## Unit Tests

Run all tests:
```bash
pytest
```

Run tests with verbose output:
```bash
pytest -v
```

Run a specific test file:
```bash
pytest tests/test_main.py
```

Run tests with coverage (requires `pytest-cov`):
```bash
pip install pytest-cov
pytest --cov=src
```

## Managing Dependencies

### Add a new dependency

1. Install the package:
   ```bash
   pip install package-name
   ```

2. Update `requirements.txt`:
   ```bash
   pip freeze > requirements.txt
   ```

### Install from requirements.txt

```bash
pip install -r requirements.txt
```

### Upgrade a dependency

```bash
pip install --upgrade package-name
pip freeze > requirements.txt
```

### Remove a dependency

```bash
pip uninstall package-name
pip freeze > requirements.txt
```

## Project Configuration (pyproject.toml)

`pyproject.toml` is the modern standard for Python project configuration. It replaces older files like `setup.py` and combines project metadata with tool configurations.

### Structure

```toml
[project]
name = "password-manager"      # Package name
version = "0.1.0"              # Semantic version
description = ""               # Project description
requires-python = ">=3.9"      # Minimum Python version
dependencies = []              # Runtime dependencies

[project.optional-dependencies]
dev = ["pytest>=7.0.0"]        # Development dependencies

[tool.pytest.ini_options]
testpaths = ["tests"]          # Tool-specific configuration
```

### Install as editable package

Install the project with dev dependencies:
```bash
pip install -e ".[dev]"
```

This allows importing your package (`from src import ...`) and installs dev tools.

### Adding dependencies to pyproject.toml

**Runtime dependency** (needed to run the app):
```toml
dependencies = ["requests>=2.28", "click>=8.0"]
```

**Dev dependency** (only for development):
```toml
[project.optional-dependencies]
dev = ["pytest>=7.0.0", "black", "ruff"]
```

### Adding tool configurations

Configure tools like black, ruff, or mypy:

```toml
[tool.black]
line-length = 88

[tool.ruff]
select = ["E", "F", "W"]

[tool.mypy]
strict = true
```

### pyproject.toml vs requirements.txt

| pyproject.toml | requirements.txt |
|----------------|------------------|
| Defines project metadata | Lists pinned versions |
| Flexible version ranges | Exact versions for reproducibility |
| Separates dev/runtime deps | Single flat list |
| Use for development | Use for production deployments |
