#! /usr/bin/python3

import re
import sys

import psutil


VIM_RE = re.compile('^g?(view|n?vim?x?)(diff)?$')


pane_pts = sys.argv[1]

for p in psutil.process_iter():
    if VIM_RE.match(p.name()):
        for pp in [p, *p.parents()]:
            if pp.terminal() == pane_pts:
                raise SystemExit(0)

raise SystemExit(1)
