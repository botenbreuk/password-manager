#!/usr/bin/env python3
"""Convert icon.svg to platform-specific icon formats."""
import io
import struct
import subprocess
import sys
from pathlib import Path

try:
    import cairosvg
    from PIL import Image
except ImportError:
    print("Missing dependencies. Install with: pip install cairosvg Pillow")
    sys.exit(1)

PROJECT_ROOT = Path(__file__).parent.parent
SVG_PATH = PROJECT_ROOT / "icon.svg"
OUTPUT_DIR = Path(__file__).parent / "icons"


def svg_to_png(size: int) -> Image.Image:
    """Render SVG to a PIL Image at the given size."""
    png_data = cairosvg.svg2png(
        url=str(SVG_PATH), output_width=size, output_height=size
    )
    return Image.open(io.BytesIO(png_data))


def create_ico(output_path: Path) -> None:
    """Create a Windows .ico file with multiple sizes."""
    sizes = [16, 24, 32, 48, 64, 128, 256]
    images = [svg_to_png(s) for s in sizes]
    images[0].save(output_path, format="ICO", sizes=[(s, s) for s in sizes], append_images=images[1:])
    print(f"Created {output_path} ({output_path.stat().st_size:,} bytes)")


def create_icns(output_path: Path) -> None:
    """Create a macOS .icns file."""
    # .icns requires specific icon types
    icon_types = [
        ("icp4", 16),
        ("icp5", 32),
        ("icp6", 64),
        ("ic07", 128),
        ("ic08", 256),
        ("ic09", 512),
        ("ic10", 1024),
    ]

    entries = []
    for type_code, size in icon_types:
        img = svg_to_png(size)
        buf = io.BytesIO()
        img.save(buf, format="PNG")
        png_bytes = buf.getvalue()
        entries.append((type_code.encode("ascii"), png_bytes))

    # Build ICNS file: magic + length header, then entries
    body = b""
    for type_code, png_bytes in entries:
        entry_length = 8 + len(png_bytes)  # type(4) + length(4) + data
        body += type_code + struct.pack(">I", entry_length) + png_bytes

    total_length = 8 + len(body)  # icns header(8) + body
    icns_data = b"icns" + struct.pack(">I", total_length) + body

    output_path.write_bytes(icns_data)
    print(f"Created {output_path} ({output_path.stat().st_size:,} bytes)")


def create_png(output_path: Path) -> None:
    """Create a 256x256 PNG for Linux."""
    img = svg_to_png(256)
    img.save(output_path, format="PNG")
    print(f"Created {output_path} ({output_path.stat().st_size:,} bytes)")


def main():
    if not SVG_PATH.exists():
        print(f"Error: {SVG_PATH} not found")
        sys.exit(1)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Converting {SVG_PATH}...")
    create_ico(OUTPUT_DIR / "icon.ico")
    create_icns(OUTPUT_DIR / "icon.icns")
    create_png(OUTPUT_DIR / "icon.png")
    print("Done!")


if __name__ == "__main__":
    main()
