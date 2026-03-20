#!/bin/sh
echo "Solving module called module-03" >> /tmp/progress.log

# Systemd investigation commands
systemctl status system-optimizer.service
systemd-cgls --no-pager | grep -A 5 system-optimizer
systemd-cgls --no-pager | head -50
systemctl cat system-optimizer.service
systemctl is-enabled system-optimizer.service
journalctl -u system-optimizer.service -n 20
