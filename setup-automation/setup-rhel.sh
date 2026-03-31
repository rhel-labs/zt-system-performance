#!/bin/bash
USER=rhel

echo "Adding wheel" > /root/post-run.log
usermod -aG wheel rhel

echo "Setup vm rhel" > /tmp/progress.log

chmod 666 /tmp/progress.log

# Create a "monitoring" service that Scott created - but it's actually consuming resources
# This simulates Scott trying to "improve system monitoring" but creating a resource hog instead

cat > /etc/systemd/system/system-optimizer.service << 'EOF'
[Unit]
Description=System Performance Optimizer Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/stress-ng --cpu 2 --vm 1 --vm-bytes 512M --timeout 0
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable system-optimizer.service
systemctl start system-optimizer.service

echo "Lab setup complete" >> /tmp/progress.log
