#!/bin/sh
echo "Validating module called module-02" >> /tmp/progress.log

# Check if the stress service is still running (it should be at this stage)
if systemctl is-active --quiet system-optimizer.service; then
    echo "PASS: Initial assessment completed - problem service is still active" >> /tmp/progress.log
    exit 0
else
    echo "FAIL: Service appears to have been stopped prematurely" >> /tmp/progress.log
    echo "HINT: This module is about assessment only - don't stop the service yet" >> /tmp/progress.log
    exit 1
fi
