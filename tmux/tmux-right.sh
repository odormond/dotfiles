#!/bin/bash

echo "#[fg=colour240,bg=colour234]#[fg=colour16,bg=colour240]$(~/.dotfiles/tmux/netstat.sh)#[fg=colour244,bg=colour240]#[fg=colour16,bg=colour244]$(cut -d' ' -f-3 /proc/loadavg)#[fg=colour254,bg=colour244]#[fg=colour16,bg=colour254]$(date +%F\ %T)"
