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

# Create a note from Scott explaining what he did
cat > /home/rhel/note-from-scott.txt << 'EOF'
Hey Team,

I installed a new "System Performance Optimizer" service on the server.
I found this great tool that's supposed to help improve system performance
by keeping the CPU and memory "warmed up" so things run faster.

The service is called system-optimizer.service and it starts automatically.

You're welcome!

- Manager Scott
EOF

chown rhel:rhel /home/rhel/note-from-scott.txt

# Create a helpful note from Nate
cat > /home/rhel/note-from-nate.txt << 'EOF'
Hey,

I saw Scott's email about his "performance optimizer." Yeah... about that.

When the system feels slow or unresponsive, start with the basics:
1. Check overall system load and resource usage
2. Identify which processes are consuming resources
3. Determine if they're supposed to be running
4. Investigate using systemd tools if they're services

I'm working on another issue right now, but you've got this.
Take a methodical approach and you'll find the problem.

Good luck,
-Nate

P.S. - When you find what's wrong, make sure to disable it so it
doesn't start again on reboot. Scott tends to "fix" things repeatedly.
EOF

chown rhel:rhel /home/rhel/note-from-nate.txt

echo "Lab setup complete" >> /tmp/progress.log
