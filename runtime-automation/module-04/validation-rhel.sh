#!/bin/sh
echo "Validating module called module-04" >> /tmp/progress.log

# Check if the stress service is still running (it should be at this stage)
if systemctl is-active --quiet system-optimizer.service; then
    echo "PASS: System tools analysis completed - problem service still active for resolution"
    exit 0
else
    echo "FAIL: Service appears to have been stopped prematurely"
    echo "HINT: This module is about analysis only - save the resolution for the next module"
    exit 1
fi
