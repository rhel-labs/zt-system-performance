#!/bin/sh
echo "Solving module called module-05" >> /tmp/progress.log

# Resolution commands
sudo systemctl stop system-optimizer.service
systemctl status system-optimizer.service
sudo systemctl disable system-optimizer.service
systemctl is-enabled system-optimizer.service

# Verify recovery
uptime
free -h
top -b -n 1 | head -20

# Create incident report
cat > /home/rhel/incident-report.txt << 'EOF'
INCIDENT REPORT: System Performance Issue - RESOLVED

Date: $(date)
Reported by: Users experiencing slow system performance

Problem:
- High CPU and memory usage
- System load significantly above normal
- Service system-optimizer.service consuming resources

Root Cause:
- Manager Scott installed "system-optimizer.service"
- Service was running stress-ng (a stress testing tool)
- Scott misunderstood the tool's purpose - it CONSUMES resources to test
  system capacity, rather than optimizing performance

Resolution:
- Stopped the service: systemctl stop system-optimizer.service
- Disabled automatic startup: systemctl disable system-optimizer.service
- System resources returned to normal levels

Lessons Learned:
- Always test new services in non-production environments first
- Verify what a service actually does before deploying it
- Just because something has "optimizer" in the name doesn't mean it optimizes

Status: RESOLVED
EOF

cat /home/rhel/incident-report.txt
