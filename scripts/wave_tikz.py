#!/usr/bin/env python3
"""Draw report-quality digital waveforms as TikZ/LaTeX from a VCD file.

The lab forbids GTKWave screenshots; this script reads the recorded VCD (the
same data GTKWave would show) and writes a vector TikZ picture instead, so the
figure stays sharp at any zoom and uses the fonts of the report.

Usage:
    python3 wave_tikz.py --vcd results/x.vcd --t0 196000000 --t1 198100000 \
            --row key_in:bit --row 'cnt_press:bus:dec' --out fig.tex

Row syntax:  <signal-suffix>:bit
             <signal-suffix>:bus[:hex|:dec]
             <signal-suffix>:analog:<vmax>     (a counter drawn on its own
                                                scale: 0 at the bottom of the
                                                row, vmax at the top)
"""
import argparse

from vcd_util import VCD


# ----------------------------------------------------------------------
# helpers
# ----------------------------------------------------------------------
def tex(text):
    """Escape the few characters that matter in a TikZ label."""
    return (str(text).replace('\\', r'\textbackslash{}')
                    .replace('_', r'\_')
                    .replace('%', r'\%')
                    .replace('&', r'\&')
                    .replace('#', r'\#'))


def nice_step(span, target=6):
    """Pick a 1/2/5 x 10^k step that gives about `target` ticks."""
    raw = span / float(target)
    base = 1.0
    while base * 10 <= raw:
        base *= 10
    for mult in (1, 2, 5, 10):
        if base * mult >= raw:
            return base * mult
    return base * 10


def fmt_time(t):
    """Format a time in ns with the smallest sensible unit."""
    a = abs(t)
    if a >= 1e6:
        return '%g ms' % (t / 1e6)
    if a >= 1e3:
        return '%g us' % (t / 1e3)
    return '%g ns' % t


def fmt_value(v, base):
    if v is None:
        return 'x'
    if base == 'hex':
        return '%X' % v
    if base == 'bin':
        return format(v, '03b')
    return str(v)


class Row:
    def __init__(self, spec):
        parts = spec.split(':')
        self.sig = parts[0]
        self.kind = parts[1] if len(parts) > 1 else 'bit'
        self.fmt = parts[2] if len(parts) > 2 else 'hex'
        self.vmax = float(parts[2]) if (self.kind == 'analog' and len(parts) > 2) else 1.0
        self.vlabel = parts[3] if (self.kind == 'analog' and len(parts) > 3) else None
        self.label = self.sig


# ----------------------------------------------------------------------
# drawing
# ----------------------------------------------------------------------
def render(vcd, rows, t0, t1, out, width=16.6, rowh=0.46, pitch=0.72,
           ticks=None, spans=(), anns=(), value_labels=True,
           label_x=-0.12, standalone=False, caption=None):
    span = float(t1 - t0)
    scale = width / span

    def X(t):
        return (t - t0) * scale

    n = len(rows)
    ytop_of = lambda i: -i * pitch
    ybot_of = lambda i: -i * pitch - rowh

    L = []
    L.append(r'\begin{tikzpicture}[x=1cm,y=1cm,font=\sffamily\scriptsize,'
             r'>=Stealth]')
    L.append(r'  \definecolor{wv}{HTML}{242521}')
    L.append(r'  \definecolor{wvgrid}{HTML}{D8D8D0}')
    L.append(r'  \definecolor{wvhl}{HTML}{9B4C2A}')
    L.append(r'  \definecolor{wvfill}{HTML}{F2F1EC}')

    # grid and time axis
    step = nice_step(span) if ticks is None else ticks
    t = (int(t0 / step) + 1) * step
    grid = []
    while t < t1:
        grid.append(t)
        t += step
    for t in grid:
        x = X(t)
        L.append(r'  \draw[wvgrid,densely dotted,line width=0.4pt] (%.3f,0.28) -- (%.3f,%.3f);'
                 % (x, x, ybot_of(n - 1) - 0.18))
        L.append(r'  \node[font=\fontsize{5.6}{6.6}\selectfont,text=black!60,'
                 r'anchor=north] at (%.3f,%.3f) {%s};'
                 % (x, ybot_of(n - 1) - 0.2, fmt_time(t)))

    # shaded spans
    for (a, b, text) in spans:
        xa, xb = X(a), X(b)
        L.append(r'  \fill[wvfill] (%.3f,%.3f) rectangle (%.3f,%.3f);'
                 % (xa, 0.24, xb, ybot_of(n - 1) - 0.16))
    # re-draw grid over the shading
    for t in grid:
        x = X(t)
        L.append(r'  \draw[wvgrid,densely dotted,line width=0.4pt] (%.3f,0.28) -- (%.3f,%.3f);'
                 % (x, x, ybot_of(n - 1) - 0.16))

    for (a, b, text) in spans:
        L.append(r'  \draw[wvhl,dashed,line width=0.5pt] (%.3f,0.24) -- (%.3f,%.3f);'
                 % (X(a), X(a), ybot_of(n - 1) - 0.16))
        L.append(r'  \draw[wvhl,dashed,line width=0.5pt] (%.3f,0.24) -- (%.3f,%.3f);'
                 % (X(b), X(b), ybot_of(n - 1) - 0.16))
        if text:
            L.append(r'  \node[font=\fontsize{5.8}{7}\selectfont,text=wvhl,'
                     r'anchor=north] at (%.3f,0.30) {%s};'
                     % ((X(a) + X(b)) / 2.0, text))

    for i, row in enumerate(rows):
        yt, yb = ytop_of(i), ybot_of(i)
        ym = (yt + yb) / 2.0
        ser = vcd.series(row.sig)
        # label and row rule
        L.append(r'  \node[anchor=east,font=\ttfamily\fontsize{7}{8}\selectfont] '
                 r'at (%.3f,%.3f) {%s};' % (label_x, ym, tex(row.label)))
        L.append(r'  \draw[wvgrid,line width=0.3pt] (-0.02,%.3f) -- (%.3f,%.3f);'
                 % (yb, X(t1), yb))

        # sample the series on the window
        # If the recording starts after the window (a $dumpon window), use
        # the first value recorded at or after t0 as the value at the start.
        first = 0
        for (tt, vv) in ser:
            if tt >= t0:
                first = 0 if vv is None else vv
                break
        v0 = vcd.value_at(ser, t0, first)
        pts = [(t0, first if v0 is None else v0)]
        for (tt, vv) in ser:
            if t0 < tt < t1:
                if pts and pts[-1][0] == tt:
                    pts[-1] = (tt, vv)
                else:
                    pts.append((tt, vv))
        if pts and pts[-1][0] < t1:
            pass

        if row.kind == 'analog':
            # A counter drawn against its own scale: 0 at the bottom of the
            # row, vmax at the top.  The series is decimated to about 1500
            # points, which is far more than the figure can resolve.
            step_n = max(1, len(pts) // 1500)
            path = []
            for k in range(0, len(pts), step_n):
                tt, vv = pts[k]
                v = 0.0 if vv is None else float(vv)
                y = yb + max(0.0, min(1.0, v / row.vmax)) * (yt - yb)
                path.append((X(tt), y))
            if pts[-1][0] >= t0:
                v = 0.0 if pts[-1][1] is None else float(pts[-1][1])
                path.append((X(t1), yb + max(0.0, min(1.0, v / row.vmax)) * (yt - yb)))
            d = ' -- '.join('(%.3f,%.3f)' % p for p in path)
            L.append(r'  \draw[wvgrid,line width=0.4pt,densely dashed] '
                     r'(0,%.3f) -- (%.3f,%.3f);' % (yt, X(t1), yt))
            L.append(r'  \draw[wv,line width=0.6pt] %s;' % d)
            L.append(r'  \node[font=\fontsize{5.2}{6.2}\selectfont,text=black!55,'
                     r'anchor=east] at (%.3f,%.3f) {%s};'
                     % (X(t1) - 0.06, yt + 0.07,
                        tex(row.vlabel if row.vlabel else
                            fmt_value(int(row.vmax), 'dec'))))
            continue

        if row.kind == 'bit':
            # Staircase polyline with a minimum high-phase width: a one-clock
            # pulse (40 ns) or a two-line vsync pulse (64 us) would be a
            # hairline on a ms axis, so an edge is moved to keep every pulse
            # at least MIN_W cm wide.  The captions of the waveform figures
            # state this convention.
            MIN_W = 0.055
            lvl = lambda v: yt if v else yb
            edges = [(pts[0][0], lvl(pts[0][1]))]
            for (tt, vv) in pts[1:]:
                t_prev, l_prev = edges[-1]
                if (l_prev == yt) and ((tt - t_prev) * scale < MIN_W):
                    tt = t_prev + MIN_W / scale
                if tt <= t_prev:
                    tt = t_prev + 1e-6
                edges.append((tt, lvl(vv)))
            path = [(X(edges[0][0]), edges[0][1])]
            for (tt, level) in edges[1:]:
                x = X(tt)
                path.append((x, path[-1][1]))     # horizontal at the old level
                path.append((x, level))           # vertical transition
            path.append((X(t1), path[-1][1]))
            d = ' -- '.join('(%.3f,%.3f)' % p for p in path)
            L.append(r'  \draw[wv,line width=0.7pt] %s;' % d)
        else:
            # bus: hexagon segments with crossing transitions
            slant = min(0.09, 0.5 * scale * 1e6)   # cm
            for k, (tt, vv) in enumerate(pts):
                a = X(tt)
                b = X(pts[k + 1][0]) if k + 1 < len(pts) else X(t1)
                a2 = a + (slant if k > 0 else 0.0)
                b2 = b - (slant if k + 1 < len(pts) else 0.0)
                if b2 < a2:
                    a2, b2 = a, b
                if k > 0:
                    L.append(r'  \draw[wv,line width=0.6pt] (%.3f,%.3f) -- (%.3f,%.3f) '
                             r'-- (%.3f,%.3f);' % (a2 - slant, yt, a2, ym, a2 - slant, yb))
                L.append(r'  \draw[wv,line width=0.6pt] (%.3f,%.3f) -- (%.3f,%.3f);'
                         % (a2, yt, b2, yt))
                L.append(r'  \draw[wv,line width=0.6pt] (%.3f,%.3f) -- (%.3f,%.3f);'
                         % (a2, yb, b2, yb))
                if value_labels and (b2 - a2) > 0.30:
                    L.append(r'  \node[font=\ttfamily\fontsize{6}{7}\selectfont] '
                             r'at (%.3f,%.3f) {%s};'
                             % ((a2 + b2) / 2.0, ym, fmt_value(vv, row.fmt)))

    # annotation lines
    for (t, text, up) in anns:
        x = X(t)
        L.append(r'  \draw[wvhl,line width=0.6pt,dashed] (%.3f,0.22) -- (%.3f,%.3f);'
                 % (x, x, ybot_of(n - 1) - 0.14))
        L.append(r'  \node[font=\fontsize{5.8}{7}\selectfont,text=wvhl,anchor=south]'
                 r' at (%.3f,0.26) {%s};' % (x, tex(text)))

    L.append(r'\end{tikzpicture}')

    body = '\n'.join(L)
    if standalone:
        doc = (r'\documentclass[border=2pt]{standalone}' '\n'
               r'\usepackage[T1]{fontenc}' '\n'
               r'\usepackage{lmodern}' '\n'
               r'\usepackage{tikz}' '\n'
               r'\usetikzlibrary{arrows.meta}' '\n'
               r'\begin{document}' '\n' + body + '\n' + r'\end{document}' '\n')
        open(out, 'w').write(doc)
    else:
        header = '%% generated by wave_tikz.py from %s\n' % vcd.path
        if caption:
            header += '%% %s\n' % caption
        open(out, 'w').write(header + body + '\n')
    return body


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--vcd', required=True)
    ap.add_argument('--t0', type=float, required=True)
    ap.add_argument('--t1', type=float, required=True)
    ap.add_argument('--row', action='append', default=[])
    ap.add_argument('--out', required=True)
    ap.add_argument('--width', type=float, default=16.6)
    ap.add_argument('--label', action='append', default=[],
                    help='label for the matching --row, in order')
    ap.add_argument('--span', action='append', default=[],
                    help='t0,t1,text')
    ap.add_argument('--ann', action='append', default=[])
    ap.add_argument('--standalone', action='store_true')
    args = ap.parse_args()

    vcd = VCD(args.vcd)
    rows = [Row(s) for s in args.row]
    for i, lab in enumerate(args.label):
        if i < len(rows):
            rows[i].label = lab
    spans = []
    for s in args.span:
        a, b, txt = s.split(',', 2)
        spans.append((float(a), float(b), txt))
    anns = []
    for s in args.ann:
        a, txt = s.split(',', 1)
        anns.append((float(a), txt, True))

    render(vcd, rows, args.t0, args.t1, args.out, width=args.width,
           spans=spans, anns=anns, standalone=args.standalone)


if __name__ == '__main__':
    main()
