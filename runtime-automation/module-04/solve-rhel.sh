#!/bin/sh
echo "Solving module called module-04" >> /tmp/progress.log

# System tools analysis commands
top -b -n 1 | head -20
ps aux | grep stress-ng | grep -v grep
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -10
