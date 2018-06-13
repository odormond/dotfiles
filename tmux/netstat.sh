#!/bin/bash

fields=`tail -n2 /proc/net/netstat | head -n1 | sed -e's/://'`

read $fields < /tmp/.tmux-right-net
prev_in=$(($InOctets + $InMcastOctets + $InBcastOctets))
prev_out=$(($OutOctets + $OutMcastOctets + $OutBcastOctets))
prev_time=`stat -c%Y /tmp/.tmux-right-net`

tail -n1 /proc/net/netstat > /tmp/.tmux-right-net
read $fields < /tmp/.tmux-right-net
cur_in=$(($InOctets + $InMcastOctets + $InBcastOctets))
cur_out=$(($OutOctets + $OutMcastOctets + $OutBcastOctets))
cur_time=`stat -c%Y /tmp/.tmux-right-net`

dc <<EOF | awk '{ printf "▽%4dkB/s △%4dkB/s", $1, $2 }'
$cur_time $prev_time - st
$cur_in $prev_in - lt / 1024 / n
[ ] n
$cur_out $prev_out - lt / 1024 / n
EOF
