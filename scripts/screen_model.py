#!/usr/bin/env python3
"""Independent model of the three Lab 4 screens, and the RGB565 expansion.

This module is deliberately written from the *design document* (the layout in
table 2 of the report and the 8x8 bitmaps in figure 4), not from the Verilog:
the layout is described here as a word origin plus a 96-pixel pitch, and the
glyphs as 8 lists of 8 characters.  The comparison in make_figures.py then
means something: two independent descriptions of the same screen agree.
"""
import numpy as np

# RGB565 colours of the ten colour bars, in the order of the lecture example.
BARS = [
    (0xF800, 'red'),
    (0xFC00, 'orange'),
    (0xFFE0, 'yellow'),
    (0x07E0, 'green'),
    (0x07FF, 'cyan'),
    (0x001F, 'blue'),
    (0xF81F, 'purple'),
    (0x0000, 'black'),
    (0xFFFF, 'white'),
    (0xD69A, 'gray'),
]
BAR_W = 64

# 8x8 glyphs written as pictures, so that a reader can check them by eye.
GLYPHS = {
    'M': ['##....##',
          '###..###',
          '########',
          '##.##.##',
          '##....##',
          '##....##',
          '##....##',
          '##....##'],
    'U': ['##....##',
          '##....##',
          '##....##',
          '##....##',
          '##....##',
          '##....##',
          '###..###',
          '.######.'],
    'S': ['.######.',
          '###..###',
          '###.....',
          '.######.',
          '.....###',
          '.....###',
          '###..###',
          '.######.'],
    'T': ['########',
          '########',
          '...##...',
          '...##...',
          '...##...',
          '...##...',
          '...##...',
          '...##...'],
    'E': ['########',
          '##......',
          '##......',
          '#######.',
          '##......',
          '##......',
          '##......',
          '########'],
    'N': ['##....##',
          '###...##',
          '####..##',
          '##.##.##',
          '##..####',
          '##...###',
          '##....##',
          '##....##'],
    'D': ['######..',
          '##...###',
          '##....##',
          '##....##',
          '##....##',
          '##....##',
          '##...###',
          '######..'],
}

# Words: origin of the first glyph, the glyphs, and the pitch.
WORDS = {
    1: ('MUST', 144, ['M', 'U', 'S', 'T']),
    2: ('END', 192, ['E', 'N', 'D']),
}
PITCH = 96
TEXT_Y0 = 208
GLYPH = 64


def rgb565_to_rgb888(v):
    """Expand a 16-bit RGB565 word to 8-bit per channel."""
    r = (v >> 11) & 0x1F
    g = (v >> 5) & 0x3F
    b = v & 0x1F
    return (r * 255 // 31, g * 255 // 63, b * 255 // 31)


def glyph_rows(ch):
    return [sum(1 << (7 - i) for i, c in enumerate(row) if c == '#')
            for row in GLYPHS[ch]]


def model(sel):
    """Return a 480x640 uint16 array of RGB565 words for screen `sel`."""
    img = np.zeros((480, 640), dtype=np.uint16)
    if sel == 0:
        for x in range(640):
            img[:, x] = BARS[x // BAR_W][0]
        return img

    name, x0, letters = WORDS[sel]
    for k, ch in enumerate(letters):
        rows = glyph_rows(ch)
        for r in range(8):
            for c in range(8):
                if (rows[r] >> (7 - c)) & 1:
                    y = TEXT_Y0 + r * 8
                    x = x0 + k * PITCH + c * 8
                    img[y:y + 8, x:x + 8] = 0xFFFF
    return img


def to_rgb(img):
    """Expand a 480x640 RGB565 array to a 480x640x3 uint8 image."""
    out = np.zeros(img.shape + (3,), dtype=np.uint8)
    for v in np.unique(img):
        r, g, b = rgb565_to_rgb888(int(v))
        out[img == v] = (r, g, b)
    return out


def load_hex(path):
    """Read 307,200 RGB565 words written by the testbench, in scan order."""
    with open(path) as f:
        vals = [int(line, 16) for line in f if line.strip()]
    if len(vals) != 480 * 640:
        raise ValueError('%s: %d values, expected %d' % (path, len(vals), 480 * 640))
    return np.array(vals, dtype=np.uint16).reshape(480, 640)


if __name__ == '__main__':
    for sel in (0, 1, 2):
        a = model(sel)
        from collections import Counter
        cnt = Counter(a.flatten().tolist())
        print(sel, {hex(k): v for k, v in sorted(cnt.items())})
    print('glyph ones:', {ch: sum(bin(r).count('1') for r in glyph_rows(ch))
                         for ch in GLYPHS})
