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
