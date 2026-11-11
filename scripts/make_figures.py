#!/usr/bin/env python3
"""Generate every data-driven figure of the Lab 4 report.

    python3 make_figures.py --results ../results --out ../../LaTeX/figures

Inputs are the files written by the testbenches: the three captured frames
(screen_*.hex) and the VCD files.  Nothing here is a screenshot: the screens
are rebuilt from the captured RGB565 words, and the waveforms are drawn as
TikZ from the recorded VCD data.
"""
import argparse
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import screen_model as model
import wave_tikz
from vcd_util import VCD

FONT = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
FONTB = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'


def fig_screens(results, out):
    """3 x 2 grid: independent model beside the reconstructed RTL frame."""
    names = ['bars', 'must', 'end']
    titles = ['BARS', 'MUST', 'END']
    scale = 0.70
    cw, ch = int(640 * scale), int(480 * scale)
    left, top, gap = 76, 44, 30
    W = left + 2 * cw + gap + 20
    H = top + 3 * (ch + gap) + 8
    canvas = Image.new('RGB', (W, H), (255, 255, 255))
    d = ImageDraw.Draw(canvas)
    f = ImageFont.truetype(FONT, 14)
    fb = ImageFont.truetype(FONTB, 15)

    total = 0
    report = []
    for i, (name, title) in enumerate(zip(names, titles)):
        meas = model.load_hex(os.path.join(results, 'screen_%d_%s.hex' % (i, name)))
        ref = model.model(i)
        diff = int((meas != ref).sum())
        total += diff
        report.append('%s: %d / 307200 pixels differ from the model' % (name, diff))
        y = top + i * (ch + gap)
        d.text((6, y + ch // 2 - 8), title, font=fb, fill=(36, 37, 33))
        d.text((6, y + ch // 2 + 6), 'screen %d' % i, font=f, fill=(102, 103, 95))
        for j, (img, lab) in enumerate(((ref, 'independent model'),
                                        (meas, 'RTL simulation'))):
            x = left + j * (cw + gap)
            im = Image.fromarray(model.to_rgb(img)).resize((cw, ch), Image.NEAREST)
            canvas.paste(im, (x, y))
            d.rectangle([x, y, x + cw - 1, y + ch - 1], outline=(185, 185, 180))
            d.text((x, y - 17), lab, font=f, fill=(102, 103, 95))
    canvas.save(os.path.join(out, 'screen_compare.png'))
    with open(os.path.join(results, 'screen_check.txt'), 'w') as fh:
        fh.write('\n'.join(report) + '\n')
        fh.write('total mismatches: %d\n' % total)
    print('\n'.join(report))
    print('total mismatches:', total)
    return total


def fig_click(results, out):
    vcd = VCD(os.path.join(results, 'tb_key_debounce.vcd'))
    # Panel (a): the whole bouncing click, 31 ms wide.
    rows = [wave_tikz.Row('key_in:bit'),
            wave_tikz.Row('dut.key_sync:bit'),
            wave_tikz.Row('cnt_press_hi:analog:488.28125:500000'),
            wave_tikz.Row('dut.key_state:bit'),
            wave_tikz.Row('key_press:bit')]
    for r, lab in zip(rows, ['key_in', 'key_sync', 'cnt_press', 'key_state',
                             'key_press']):
        r.label = lab
    wave_tikz.render(vcd, rows, 195.8e6, 227.2e6,
                     os.path.join(out, 'wave_click_a.tex'),
                     width=16.6, spans=[(196.00022e6, 224.00034e6,
                                         r'debounce 20.000 ms')])
    # Panel (b): the last 0.2 ms before the pulse.
    rows = [wave_tikz.Row('dut.key_sync:bit'),
            wave_tikz.Row('cnt_press_hi:analog:488.28125:500000'),
            wave_tikz.Row('dut.key_state:bit'),
            wave_tikz.Row('key_press:bit')]
    for r, lab in zip(rows, ['key_sync', 'cnt_press', 'key_state', 'key_press']):
        r.label = lab
    wave_tikz.render(vcd, rows, 223.96e6, 224.16e6,
                     os.path.join(out, 'wave_click_b.tex'), width=16.6)


def fig_cycle(results, out):
    vcd = VCD(os.path.join(results, 'tb_vga_sm_top.vcd'))
    rows = [wave_tikz.Row('key_in:bit'),
            wave_tikz.Row('key_press:bit'),
            wave_tikz.Row('screen_sel:bus:dec'),
            wave_tikz.Row('st_cur:bus:bin'),
            wave_tikz.Row('vsync:bit')]
    for r, lab in zip(rows, ['key_in', 'key_press', 'screen_sel', 'st_cur',
                             'vsync']):
        r.label = lab
    spans = [(66.87953e6, 86.87961e6, ''),
             (150.87953e6, 170.87961e6, ''),
             (251.67953e6, 271.67961e6, '')]
    wave_tikz.render(vcd, rows, 55e6, 300e6,
                     os.path.join(out, 'wave_cycle.tex'),
                     width=16.6, spans=spans, ticks=25e6)


def fig_reset(results, out):
    vcd = VCD(os.path.join(results, 'tb_vga_reset.vcd'))
    rows = [wave_tikz.Row('sys_rst_n:bit'),
            wave_tikz.Row('hsync:bit'),
            wave_tikz.Row('vsync:bit'),
            wave_tikz.Row('screen_sel:bus:dec'),
            wave_tikz.Row('st_cur:bus:bin')]
    for r, lab in zip(rows, ['sys_rst_n', 'hsync', 'vsync', 'screen_sel',
                             'st_cur']):
        r.label = lab
    wave_tikz.render(vcd, rows, 76.998e6, 77.038e6,
                     os.path.join(out, 'wave_reset_a.tex'), width=15.0)
    wave_tikz.render(vcd, rows, 206.000e6, 206.040e6,
                     os.path.join(out, 'wave_reset_b.tex'), width=15.0)


def fig_simulator(results, out):
    """The three screens as they appeared in the simulator's VGA surface."""
    names = ['bars', 'must', 'end']
    titles = ['BARS', 'MUST', 'END']
    scale = 0.52
    cw, ch = int(640 * scale), int(480 * scale)
    gap = 14
    W = 3 * cw + 2 * gap + 8
    H = ch + 26
    canvas = Image.new('RGB', (W, H), (255, 255, 255))
    d = ImageDraw.Draw(canvas)
    f = ImageFont.truetype(FONT, 13)
    for i, (name, title) in enumerate(zip(names, titles)):
        im = Image.open(os.path.join(results, 'sim_%s.png' % name)).resize((cw, ch),
                                                                          Image.NEAREST)
        x = 4 + i * (cw + gap)
        canvas.paste(im, (x, 22))
        d.rectangle([x, 22, x + cw - 1, 22 + ch - 1], outline=(185, 185, 180))
        d.text((x, 3), title, font=f, fill=(36, 37, 33))
    canvas.save(os.path.join(out, 'simulator_screens.png'))
    print('wrote simulator_screens.png')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--results', default='results')
    ap.add_argument('--out', default='../../LaTeX/figures')
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)
    fig_screens(args.results, args.out)
    fig_click(args.results, args.out)
    fig_cycle(args.results, args.out)
    fig_reset(args.results, args.out)
    fig_simulator(args.results, args.out)
    print('figures written to', args.out)


if __name__ == '__main__':
    main()
