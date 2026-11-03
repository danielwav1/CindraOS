#!/usr/bin/env python3
import string
import sys
from pathlib import Path

PALETTES = {
    "dark": {
        "bg_active": "#1b1d22", "bg_inactive": "#14161a",
        "edge_active": "#e0242b", "edge_inactive": "#2a2d33",
        "text_active": "#f0f0f0", "text_inactive": "#7d828a",
        "glyph_active": "#d9dce1", "glyph_inactive": "#6b7079",
        "hover": "#3a3d44", "glyph_hover": "#ffffff",
    },
    "light": {
        "bg_active": "#eceef2", "bg_inactive": "#f6f7f9",
        "edge_active": "#e0242b", "edge_inactive": "#cfd2d8",
        "text_active": "#1d1f23", "text_inactive": "#8a8f98",
        "glyph_active": "#3a3d44", "glyph_inactive": "#9aa0a8",
        "hover": "#d6d9df", "glyph_hover": "#14161a",
    },
}

TITLE_H = 28
BTN = 18
SIDE = 4
CHARS = string.ascii_letters + string.digits


def write_xpm(path, rows):
    colors = []
    for row in rows:
        for c in row:
            if c not in colors:
                colors.append(c)
    keys = {c: CHARS[i] for i, c in enumerate(colors)}
    lines = ['/* XPM */', 'static char *img[] = {',
             '"%d %d %d 1",' % (len(rows[0]), len(rows), len(colors))]
    for c in colors:
        lines.append('"%s c %s",' % (keys[c], "None" if c is None else c))
    for i, row in enumerate(rows):
        end = "," if i < len(rows) - 1 else ""
        lines.append('"%s"%s' % ("".join(keys[c] for c in row), end))
    lines.append("};")
    path.write_text("\n".join(lines) + "\n")


def canvas(w, h, fill=None):
    return [[fill for _ in range(w)] for _ in range(h)]


def plot(grid, x, y, color, thick=1):
    for dx in range(thick):
        for dy in range(thick):
            if 0 <= y + dy < len(grid) and 0 <= x + dx < len(grid[0]):
                grid[y + dy][x + dx] = color


def line(grid, x0, y0, x1, y1, color, thick=2):
    dx, dy = abs(x1 - x0), abs(y1 - y0)
    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1
    err = dx - dy
    while True:
        plot(grid, x0, y0, color, thick)
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 > -dy:
            err -= dy
            x0 += sx
        if e2 < dx:
            err += dx
            y0 += sy


def box(grid, x0, y0, x1, y1, color, thick=1):
    line(grid, x0, y0, x1, y0, color, thick)
    line(grid, x0, y1, x1, y1, color, thick)
    line(grid, x0, y0, x0, y1, color, thick)
    line(grid, x1, y0, x1, y1, color, thick)


GLYPHS = {
    "close": lambda g, c: (line(g, 5, 5, 12, 12, c), line(g, 12, 5, 5, 12, c)),
    "hide": lambda g, c: line(g, 5, 11, 12, 11, c),
    "maximize": lambda g, c: (box(g, 5, 5, 12, 12, c), line(g, 5, 5, 12, 5, c)),
    "maximize-toggled": lambda g, c: (box(g, 4, 7, 10, 13, c), box(g, 7, 4, 13, 10, c)),
    "menu": lambda g, c: (line(g, 5, 7, 9, 11, c), line(g, 9, 11, 13, 7, c)),
    "shade": lambda g, c: (line(g, 5, 11, 9, 7, c), line(g, 9, 7, 13, 11, c)),
    "shade-toggled": lambda g, c: (line(g, 5, 7, 9, 11, c), line(g, 9, 11, 13, 7, c)),
    "stick": lambda g, c: box(g, 7, 7, 10, 10, c, 2),
    "stick-toggled": lambda g, c: box(g, 5, 5, 12, 12, c, 1),
}


def button(name, state, pal):
    grid = canvas(BTN, BTN)
    glyph = pal["glyph_active"]
    if state == "inactive":
        glyph = pal["glyph_inactive"]
    elif state in ("prelight", "pressed"):
        bg = pal["edge_active"] if name == "close" else pal["hover"]
        if state == "pressed" and name == "close":
            bg = "#b81b21"
        glyph = pal["glyph_hover"] if name == "close" else pal["glyph_active"]
        for y in range(1, BTN - 1):
            for x in range(1, BTN - 1):
                grid[y][x] = bg
    GLYPHS[name](grid, glyph)
    return grid


def title_piece(index, w, bg, edge):
    grid = canvas(w, TITLE_H, bg)
    for y in range(2):
        for x in range(w):
            grid[y][x] = edge
    if index == 1:
        for y in range(TITLE_H):
            for x in range(min(2, w)):
                grid[y][x] = edge
    if index == 5:
        for y in range(TITLE_H):
            for x in range(max(0, w - 2), w):
                grid[y][x] = edge
    return grid


def side_piece(w, h, bg, edge, left):
    grid = canvas(w, h, bg)
    cols = range(0, 2) if left else range(w - 2, w)
    for y in range(h):
        for x in cols:
            grid[y][x] = edge
    return grid


def bottom_piece(w, h, bg, edge, corner=None):
    grid = canvas(w, h, bg)
    for y in range(h - 2, h):
        for x in range(w):
            grid[y][x] = edge
    if corner == "left":
        for y in range(h):
            for x in range(2):
                grid[y][x] = edge
    elif corner == "right":
        for y in range(h):
            for x in range(w - 2, w):
                grid[y][x] = edge
    return grid


def build(variant, out):
    pal = PALETTES[variant]
    out.mkdir(parents=True, exist_ok=True)
    for state in ("active", "inactive"):
        bg, edge = pal["bg_" + state], pal["edge_" + state]
        for i in range(1, 6):
            write_xpm(out / ("title-%d-%s.xpm" % (i, state)), title_piece(i, SIDE if i != 3 else 8, bg, edge))
        write_xpm(out / ("top-left-%s.xpm" % state), title_piece(1, SIDE, bg, edge))
        write_xpm(out / ("top-right-%s.xpm" % state), title_piece(5, SIDE, bg, edge))
        write_xpm(out / ("left-%s.xpm" % state), side_piece(SIDE, 8, bg, edge, True))
        write_xpm(out / ("right-%s.xpm" % state), side_piece(SIDE, 8, bg, edge, False))
        write_xpm(out / ("bottom-%s.xpm" % state), bottom_piece(8, SIDE, bg, edge))
        write_xpm(out / ("bottom-left-%s.xpm" % state), bottom_piece(SIDE, SIDE, bg, edge, "left"))
        write_xpm(out / ("bottom-right-%s.xpm" % state), bottom_piece(SIDE, SIDE, bg, edge, "right"))
    for name in GLYPHS:
        for state in ("active", "inactive", "prelight", "pressed"):
            write_xpm(out / ("%s-%s.xpm" % (name, state)), button(name, state, pal))
    (out / "themerc").write_text(
        "active_text_color=%(text_active)s\n"
        "inactive_text_color=%(text_inactive)s\n"
        "active_border_color=%(edge_active)s\n"
        "inactive_border_color=%(edge_inactive)s\n"
        "active_color_1=%(bg_active)s\n"
        "active_color_2=%(bg_active)s\n"
        "inactive_color_1=%(bg_inactive)s\n"
        "inactive_color_2=%(bg_inactive)s\n"
        "title_shadow_active=false\n"
        "title_shadow_inactive=false\n"
        "full_width_title=true\n"
        "show_app_icon=false\n"
        "button_offset=6\n"
        "button_spacing=3\n"
        "maximized_offset=0\n"
        "title_vertical_offset_active=0\n"
        "title_vertical_offset_inactive=0\n" % pal
    )


def main():
    if len(sys.argv) != 3 or sys.argv[1] not in PALETTES:
        sys.exit("usage: gen-xfwm4.py {dark|light} OUTPUT_DIR")
    build(sys.argv[1], Path(sys.argv[2]))


if __name__ == "__main__":
    main()
