#!/usr/bin/env python3
"""Generate pixel-art sprite assets for the Sluggers bubble gun system.

Outputs:
  godot/assets/sprites/s_bubble.png     – 16x16 translucent bubble
  godot/assets/sprites/s_bubble_gun.png – 16x8  side-view bubble gun

Uses only Python stdlib (struct + zlib) – no Pillow required.
"""
import math
import os
import struct
import zlib


# ── PNG writer ──────────────────────────────────────────────────────────────

def _png_chunk(tag: bytes, data: bytes) -> bytes:
    raw = tag + data
    return (struct.pack('>I', len(data))
            + raw
            + struct.pack('>I', zlib.crc32(raw) & 0xFFFFFFFF))


def write_png(path: str, width: int, height: int,
              pixels: list) -> None:
    """Write an RGBA PNG.  pixels is a flat list of (r,g,b,a) tuples."""
    ihdr = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    raw = bytearray()
    for y in range(height):
        raw.append(0)          # filter-type: None
        for x in range(width):
            r, g, b, a = pixels[y * width + x]
            raw += bytes([r & 0xFF, g & 0xFF, b & 0xFF, a & 0xFF])
    png = (b'\x89PNG\r\n\x1a\n'
           + _png_chunk(b'IHDR', ihdr)
           + _png_chunk(b'IDAT', zlib.compress(bytes(raw), 9))
           + _png_chunk(b'IEND', b''))
    with open(path, 'wb') as f:
        f.write(png)
    print(f'Written {path}  ({width}x{height})')


# ── Bubble sprite (16x16) ────────────────────────────────────────────────────

def make_bubble(size: int = 16) -> list:
    """Translucent blue circle with white top-left highlight."""
    T       = (  0,   0,   0,   0)   # transparent
    OUTLINE = ( 60, 140, 255, 240)   # deep blue ring
    FILL    = (120, 200, 255, 140)   # light blue fill (semi-transparent)
    HILIGHT = (255, 255, 255, 210)   # white highlight

    cx = cy = (size - 1) / 2.0
    outer_r = size / 2.0 - 0.5
    inner_r = outer_r - 1.5
    # Highlight offset: upper-left quadrant
    hi_cx, hi_cy, hi_r = cx - 2.5, cy - 2.5, 1.8

    pixels = []
    for y in range(size):
        for x in range(size):
            dx, dy   = x - cx,    y - cy
            hdx, hdy = x - hi_cx, y - hi_cy
            dist  = math.sqrt(dx  * dx  + dy  * dy)
            hdist = math.sqrt(hdx * hdx + hdy * hdy)
            if hdist <= hi_r:
                pixels.append(HILIGHT)
            elif dist <= inner_r:
                pixels.append(FILL)
            elif dist <= outer_r:
                pixels.append(OUTLINE)
            else:
                pixels.append(T)
    return pixels


# ── Bubble-gun sprite (16x8) ─────────────────────────────────────────────────

def make_bubble_gun() -> list:
    """Simple side-view pixel-art gun facing right (barrel on left)."""
    T  = (  0,   0,   0,   0)   # transparent
    MZ = (  0, 255, 240, 255)   # muzzle flash (bright cyan)
    BR = (  0, 180, 200, 255)   # barrel (teal)
    GD = (  0, 130, 150, 255)   # barrel underside (dark teal)
    GR = (160, 160, 170, 255)   # body (light grey)
    GB = (110, 110, 120, 255)   # body shadow (dark grey)
    HN = ( 75,  65,  80, 255)   # handle (dark purple-grey)

    # 16 columns × 8 rows; gun faces right, muzzle at col 0.
    art = [
        # 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
        [T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T ],  # row 0
        [T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T ],  # row 1
        [T,   BR,  BR,  BR,  BR,  BR,  BR,  BR,  BR,  GR,  GR,  GR,  T,   T,   T,   T ],  # row 2
        [MZ,  BR,  BR,  BR,  BR,  BR,  BR,  BR,  BR,  GR,  GR,  GR,  GR,  T,   T,   T ],  # row 3
        [T,   GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  GB,  GB,  GB,  GR,  T,   T,   T ],  # row 4
        [T,   T,   T,   T,   T,   T,   T,   T,   T,   GB,  GB,  GB,  GR,  T,   T,   T ],  # row 5
        [T,   T,   T,   T,   T,   T,   T,   T,   T,   HN,  HN,  HN,  HN,  T,   T,   T ],  # row 6
        [T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T ],  # row 7
    ]
    pixels = []
    for row in art:
        pixels.extend(row)
    return pixels


# ── Entry point ──────────────────────────────────────────────────────────────

if __name__ == '__main__':
    out_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                           'godot', 'assets', 'sprites')
    os.makedirs(out_dir, exist_ok=True)

    write_png(os.path.join(out_dir, 's_bubble.png'),     16, 16, make_bubble())
    write_png(os.path.join(out_dir, 's_bubble_gun.png'), 16,  8, make_bubble_gun())
    print('Done.')
