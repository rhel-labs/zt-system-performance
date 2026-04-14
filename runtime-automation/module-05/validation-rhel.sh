#!/bin/sh
echo "Validating module called module-05" >> /tmp/progress.log

# Check if the service has been stopped
if systemctl is-active --quiet system-optimizer.service; then
    echo "FAIL: The system-optimizer.service is still running" >> /tmp/progress.log
    echo "HINT: Use 'sudo systemctl stop system-optimizer.service' to stop it" >> /tmp/progress.log
    exit 1
fi

# Check if the service has been disabled
if systemctl is-enabled --quiet system-optimizer.service 2>/dev/null; then
    echo "FAIL: The system-optimizer.service is still enabled for automatic startup" >> /tmp/progress.log
    echo "HINT: Use 'sudo systemctl disable system-optimizer.service' to prevent automatic startup" >> /tmp/progress.log
    exit 1
fi

# Check if incident report was created
if [ ! -f /home/rhel/incident-report.txt ]; then
    echo "FAIL: Incident report not found at /home/rhel/incident-report.txt" >> /tmp/progress.log
    echo "HINT: Document what happened by creating the incident report" >> /tmp/progress.log
    exit 1
fi

echo "PASS: Service stopped, disabled, and incident documented successfully" >> /tmp/progress.log
exit 0
