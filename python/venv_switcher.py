#! /usr/bin/env python
# coding: UTF-8

import os
import os.path


VENV_ROOT = os.path.expanduser('~/.envs')


def subpathes(path):
    for e in range(len(path), 0, -1):
        for s in range(len(path[:e])):
            yield path[s:e]


cwd = os.getcwd().split('/')
for candidate in sorted(subpathes(cwd), key=len, reverse=True):
    candidate = [VENV_ROOT] + candidate + ['bin', 'activate']
    candidate = os.path.join(*candidate)
    if os.path.isfile(candidate):
        print('. ' + candidate)
        break
