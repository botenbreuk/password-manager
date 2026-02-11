import re


def validate_url(url: str) -> bool:
    pattern = r'^https?://[^\s/$.?#].[^\s]*$|^[a-zA-Z0-9][-a-zA-Z0-9]*(\.[a-zA-Z]{2,})+$'
    return bool(re.match(pattern, url))


def validate_username(username: str) -> bool:
    return bool(username.strip())


def validate_password(password: str) -> bool:
    if len(password) < 8:
        return False
    has_upper = bool(re.search(r'[A-Z]', password))
    has_lower = bool(re.search(r'[a-z]', password))
    has_digit = bool(re.search(r'\d', password))
    has_special = bool(re.search(r'[!@#$%^&*(),.?":{}|<>]', password))
    return has_upper and has_lower and has_digit and has_special


def validate_totp_key(key: str) -> bool:
    """Validate that a TOTP key is a valid base32 string."""
    if not key:
        return True  # Empty is valid (optional field)
    # Remove spaces and convert to uppercase
    key = key.replace(" ", "").upper()
    # Base32 only allows A-Z and 2-7
    if not re.match(r'^[A-Z2-7]+$', key):
        return False
    return True
