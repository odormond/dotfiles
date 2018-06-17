#! /usr/bin/env python3

import pickle
import os
import time

import psutil


state_filename = '/tmp/.tmux-right-netload'


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
    net_io = psutil.net_io_counters()
    recv, sent = net_io.bytes_recv, net_io.bytes_sent
    try:
        prev_recv, prev_sent, t0 = pickle.load(open(state_filename, 'rb'))
    except (OSError, pickle.UnpicklingError):
        throughput = ''
    else:
        delta_recv = recv - prev_recv
        delta_sent = sent - prev_sent
        delta_t = t1 - t0
        throughput = "▽" + humanize(delta_recv/delta_t) + " △" + humanize(delta_sent/delta_t)

    pickle.dump((recv, sent, t1), open(state_filename, 'wb'))
    return throughput


def load():
    return '{:.2f} {:.2f} {:.2f}'.format(*os.getloadavg())


print("#[fg=colour240,bg=colour234]#[fg=colour16,bg=colour240]{}#[fg=colour244,bg=colour240]#[fg=colour16,bg=colour244]{}#[fg=colour254,bg=colour244]#[fg=colour16,bg=colour254]{}".format(net_load(), load(), time.strftime('%Y-%m-%d %H:%M:%S')))
