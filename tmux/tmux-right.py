#! /usr/bin/env python3

import pickle
import os
import re
import sys
import time

import psutil


IFACE_RE = re.compile(r'^(en|eth|wl)')
STATE_FILENAME = '/tmp/.tmux-right-netload'


def humanize(v):
    orig_v = v
    multiplier = 'kMG'
    while multiplier:
        v /= 1024
        if v < 10:
            v = '%4.2f' % v
            break
        elif v < 100:
            v = '%4.1f' % v
            break
        elif v < 1000:
            v = '%4.0f' % v
            break
        multiplier = multiplier[1:]
    else:
        v = '%.0g' % orig_v
    return v + multiplier[:1] + 'B/s'


def net_load():
    t1 = time.time()
    net_ios = psutil.net_io_counters(pernic=True)
    recv = sent = 0
    for iface, net_io in net_ios.items():
        if IFACE_RE.search(iface) is None:
            continue
        recv += net_io.bytes_recv
        sent += net_io.bytes_sent
    try:
        prev_recv, prev_sent, t0 = pickle.load(open(STATE_FILENAME, 'rb'))
    except Exception as e:
        throughput = str(e) 
    else:
        delta_recv = recv - prev_recv
        delta_sent = sent - prev_sent
        delta_t = t1 - t0
        throughput = "▽" + humanize(delta_recv/delta_t) + " △" + humanize(delta_sent/delta_t)

    pickle.dump((recv, sent, t1), open(STATE_FILENAME, 'wb'))
    return throughput


def load():
    return '{:.2f} {:.2f} {:.2f}'.format(*os.getloadavg())


if len(sys.argv) != 1:
    bg = sys.argv[1]
else:
    bg = 'colour234'

print(f"#[fg=colour240,bg={bg}]#[fg=colour16,bg=colour240]{net_load()}#[fg=colour244,bg=colour240]#[fg=colour16,bg=colour244]{load()}#[fg=colour254,bg=colour244]#[fg=colour16,bg=colour254]{time.strftime('%Y-%m-%d %H:%M:%S')}")
