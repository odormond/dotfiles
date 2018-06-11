#! /usr/bin/env python3

from os import chdir
from pathlib import Path


SYMLINKS = {
    '.bashrc': 'bash/rc',
    '.bash_aliases': 'bash/aliases',
    '.bash_aliases_completion': 'bash/aliases_completion',
    '.profile': 'bash/profile',
    '.inputrc': 'readline/rc',
    '.gitconfig': 'git/config',
    '.pythonrc.py': 'python/rc.py',
    '.tmux.conf': 'tmux/tmux.conf',
    '.vim': 'vim',
}

DOTFILES = Path(__file__).absolute().parent


def place(symlink, target):
    symlink.symlink_to(target)


def should_replace(symlink, target):
    if symlink.is_symlink():
        answer = input('{} point to {}. Replace it (y/N)? '.format(symlink, symlink.resolve()))
    else:
        answer = input('{} already exists. Replace it (y/N)? '.format(symlink))
        if answer.lower()[0] == 'y':
            symlink.replace(symlink.with_suffix('.bak'))
    if answer.lower()[0] == 'y':
        place(symlink, target)


chdir(str(Path.home()))
for symlink, target in SYMLINKS.items():
    symlink = Path(symlink)
    target = DOTFILES / target
    if symlink.is_symlink():
        if symlink.resolve() == target:
            continue
    elif symlink.exists():
        should_replace(symlink, target)
    else:
        place(symlink, target)
