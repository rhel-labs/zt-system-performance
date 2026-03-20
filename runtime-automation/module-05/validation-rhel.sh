#!/bin/sh
echo "Validating module called module-05" >> /tmp/progress.log

# Check if the service has been stopped
if systemctl is-active --quiet system-optimizer.service; then
    echo "FAIL: The system-optimizer.service is still running"
    echo "HINT: Use 'sudo systemctl stop system-optimizer.service' to stop it"
    exit 1
fi

# Check if the service has been disabled
if systemctl is-enabled --quiet system-optimizer.service 2>/dev/null; then
    echo "FAIL: The system-optimizer.service is still enabled for automatic startup"
    echo "HINT: Use 'sudo systemctl disable system-optimizer.service' to prevent automatic startup"
    exit 1
fi

# Check if incident report was created
if [ ! -f /home/rhel/incident-report.txt ]; then
    echo "FAIL: Incident report not found at /home/rhel/incident-report.txt"
    echo "HINT: Document what happened by creating the incident report"
    exit 1
fi

echo "PASS: Service stopped, disabled, and incident documented successfully"
exit 0
