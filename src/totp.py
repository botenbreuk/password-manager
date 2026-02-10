import hmac
import hashlib
import struct
import time
import base64


def generate_totp(secret: str, interval: int = 30, digits: int = 6) -> str:
    """Generate a TOTP code from a base32-encoded secret."""
    if not secret:
        return ""

    try:
        # Clean up the secret (remove spaces and convert to uppercase)
        secret = secret.replace(" ", "").upper()

        # Add padding if necessary
        padding = 8 - (len(secret) % 8)
        if padding != 8:
            secret += "=" * padding

        # Decode base32 secret
        key = base64.b32decode(secret)

        # Get current time step
        counter = int(time.time()) // interval

        # Pack counter as big-endian 8-byte integer
        counter_bytes = struct.pack(">Q", counter)

        # Generate HMAC-SHA1
        hmac_hash = hmac.new(key, counter_bytes, hashlib.sha1).digest()

        # Dynamic truncation
        offset = hmac_hash[-1] & 0x0F
        code = struct.unpack(">I", hmac_hash[offset:offset + 4])[0]
        code = (code & 0x7FFFFFFF) % (10 ** digits)

        # Pad with zeros if necessary
        return str(code).zfill(digits)
    except Exception:
        return ""


def get_totp_remaining_seconds(interval: int = 30) -> int:
    """Get remaining seconds until the current TOTP code expires."""
    return interval - (int(time.time()) % interval)
