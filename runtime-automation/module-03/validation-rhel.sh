#!/bin/sh
echo "Validating module called module-03" >> /tmp/progress.log

# Check if the stress service is still running (it should be at this stage)
if systemctl is-active --quiet system-optimizer.service; then
    echo "PASS: Systemd investigation completed - problem service identified and still active"
    exit 0
else
    echo "FAIL: Service appears to have been stopped prematurely"
    echo "HINT: This module is about investigation only - don't stop the service yet"
    exit 1
fi
