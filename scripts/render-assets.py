#!/usr/bin/env python3
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFilter
except ImportError:
    sys.exit("render-assets: Pillow is required (apt install python3-pil)")

ROOT = Path(__file__).resolve().parent.parent
SCALE = 4
RED = (224, 36, 43)
DARK_RED = (184, 27, 33)
BG = (20, 22, 26)

LEFT = [(100, 100), (190, 100), (256, 220), (190, 340), (100, 340), (156, 220)]
RIGHT = [(412, 100), (322, 100), (256, 220), (322, 340), (412, 340), (356, 220)]
BOTH = [(96, 112), (190, 112), (256, 304), (322, 112), (416, 112), (304, 408), (208, 408)]


def v_layer(size, left, right, alpha=255, background=None):
    big = size * SCALE
    k = big / 512
    img = Image.new("RGBA", (big, big), background or (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.arc((int(big * 0.18), int(big * 0.18), int(big * 0.82), int(big * 0.82)), start=42, end=318, fill=left + (alpha,), width=max(8, int(big * 0.17)))
    return img.resize((size, size), Image.LANCZOS)


def logo_color(size):
    return v_layer(size, RED, DARK_RED)


def logo_dark(size):
    big = size * SCALE
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((0, 0, big - 1, big - 1), radius=int(big * 96 / 512), fill=BG + (255,))
    d.arc((int(big * 0.18), int(big * 0.18), int(big * 0.82), int(big * 0.82)), start=42, end=318, fill=RED + (255,), width=max(8, int(big * 0.17)))
    return img.resize((size, size), Image.LANCZOS)


def logo_mono(size, color):
    return v_layer(size, color, color)


def wallpaper(w=1920, h=1080):
    try:
        import numpy as np
    except ImportError:
        sys.exit("render-assets: numpy is required for the wallpaper (apt install python3-numpy)")
    yy, xx = np.mgrid[0:h, 0:w].astype("float32")
    t = (xx / w + yy / h) / 2.0
    stops = np.array([[12, 13, 16], [20, 22, 26], [29, 16, 19]], dtype="float32")
    low = np.clip((t / 0.6), 0, 1)[..., None]
    high = np.clip((t - 0.6) / 0.4, 0, 1)[..., None]
    base = np.where(t[..., None] < 0.6, stops[0] + (stops[1] - stops[0]) * low, stops[1] + (stops[2] - stops[1]) * high)
    dist = np.sqrt((xx - 1240) ** 2 + (yy - 520) ** 2) / 620
    glow = np.clip(1 - dist, 0, 1)[..., None] * 0.28
    base = base * (1 - glow) + np.array(RED, dtype="float32") * glow
    img = Image.fromarray(base.astype("uint8"), "RGB").convert("RGBA")
    mark = Image.new("RGBA", (w * 2, h * 2), (0, 0, 0, 0))
    d = ImageDraw.Draw(mark)
    d.arc((2480, 180, 3320, 1020), start=42, end=318, fill=RED + (230,), width=170)
    mark = mark.resize((w, h), Image.LANCZOS)
    img.alpha_composite(mark)
    ImageDraw.Draw(img).line((0, 1010, w, 1010), fill=RED + (64,), width=2)
    return img.convert("RGB")


def main():
    logo = ROOT / "assets" / "logo"
    logo_color(512).save(logo / "cindra-logo-512.png")
    logo_color(256).save(logo / "cindra-logo-256.png")
    logo_color(48).save(logo / "cindra-logo-48.png")
    logo_dark(512).save(logo / "cindra-logo-dark-512.png")
    logo_mono(512, (0, 0, 0)).save(logo / "cindra-logo-mono-black-512.png")
    logo_mono(512, (255, 255, 255)).save(logo / "cindra-logo-mono-white-512.png")
    wallpaper().save(ROOT / "assets" / "wallpaper" / "cindra-default.png", optimize=True)
    print("assets rendered")


if __name__ == "__main__":
    main()
