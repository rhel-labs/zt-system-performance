# Troubleshooting Tools - zt-system-performance Lab

## Lab Overview
This lab teaches how to diagnose and resolve system performance problems caused by runaway systemd services consuming excessive CPU and memory resources.

## Key Concept
Using systemd tools and traditional Unix monitoring utilities to identify, analyze, and stop resource-hogging processes.

---

## Tools Used & Their Application

### 1. **uptime** - System Load Average
**Purpose:** Quick assessment of system load (CPU utilization over time)

**Usage in Lab:**
- Module 02: Initial performance assessment
  ```bash
  uptime
  ```

**Slide Points:**
- Shows three load averages: 1, 5, and 15 minutes
- Load average interpretation:
  - 1.0 on single-core = fully utilized
  - Higher than core count = processes waiting for CPU
  - Trend matters: increasing load = worsening problem
- Quick "is there a problem?" check
- First command to run when users report slowness

---

### 2. **free** - Memory Usage
**Purpose:** Display memory and swap usage

**Usage in Lab:**
- Module 02: Check memory consumption
  ```bash
  free -h
  ```

**Slide Points:**
- `-h` = human-readable (GB, MB)
- Key columns:
  - **total** - installed RAM
  - **used** - allocated memory
  - **free** - completely unused
  - **available** - usable for new apps (includes cache that can be freed)
- **Available** is the important number, not "free"
- Shows swap usage (disk-based memory - slow!)

---

### 3. **systemctl** - Systemd Service Control
**Purpose:** Investigate and manage systemd services (THE KEY TOOL for this lab)

**Usage in Lab:**
- Module 03: Check service status
  ```bash
  systemctl status system-optimizer.service
  ```
- Module 03: View service unit file
  ```bash
  systemctl cat system-optimizer.service
  ```
- Module 03: Check if service auto-starts at boot
  ```bash
  systemctl is-enabled system-optimizer.service
  ```
- Module 05: Stop the runaway service
  ```bash
  systemctl stop system-optimizer.service
  ```
- Module 05: Prevent service from auto-starting
  ```bash
  systemctl disable system-optimizer.service
  ```

**Slide Points:**
- **status** - current state, PID, recent logs, what it's running
  - Shows if service is active/inactive
  - Displays main process PID
  - Shows ExecStart= line (the actual command)
  - Includes recent log entries
- **cat** - shows complete unit file definition
  - [Unit], [Service], [Install] sections
  - ExecStart= reveals what command actually runs
  - Service name can be misleading - always check ExecStart!
- **is-enabled** - checks if service starts at boot
  - "enabled" = starts automatically
  - "disabled" = must be started manually
  - Important for preventing recurrence
- **stop** - immediately stops running service
- **disable** - prevents auto-start at boot
  - Stop affects current session
  - Disable affects future boots
  - Usually do BOTH

---

### 4. **systemd-cgls** - Control Group Hierarchy
**Purpose:** Visualize systemd's control group tree and process organization

**Usage in Lab:**
- Module 03: Find processes belonging to system-optimizer
  ```bash
  systemd-cgls --no-pager | grep -A 5 system-optimizer
  ```
- Module 03: View full system hierarchy
  ```bash
  systemd-cgls --no-pager | head -50
  ```

**Slide Points:**
- Shows **hierarchical tree** of systemd control groups
- Each service runs in its own cgroup
- Can see all processes spawned by a service
- **Useful when:** service spawns multiple worker processes
  - stress-ng creates CPU workers + memory workers
  - All shown grouped under the service
- `--no-pager` prevents interactive paging (good for grep)
- Alternative to `ps` when you want service-centric view

---

### 5. **journalctl** - Systemd Journal Logs
**Purpose:** View systemd service logs and system messages

**Usage in Lab:**
- Module 03: View service-specific logs
  ```bash
  journalctl -u system-optimizer.service -n 20
  ```

**Slide Points:**
- `-u` = unit (service name)
- `-n 20` = last 20 entries
- Shows service startup, errors, warnings, output
- Integrated logging for all systemd services
- Better than grepping /var/log/* for systemd services
- Can reveal what service is actually doing
- Persistent across reboots (on most systems)

---

### 6. **top** - Interactive Process Monitor
**Purpose:** Real-time view of processes sorted by resource usage

**Usage in Lab:**
- Module 04: Identify top CPU consumers
  ```bash
  top
  ```
- Press '1' to show per-CPU breakdown
- Press 'M' to sort by memory instead of CPU

**Slide Points:**
- **Interactive** - updates in real-time
- Default: sorted by CPU usage (highest first)
- Shows:
  - PID, USER, CPU%, MEM%, TIME+, COMMAND
  - System summary at top (load, CPU, memory)
- **Keyboard commands:**
  - '1' = toggle per-CPU display
  - 'M' = sort by memory
  - 'P' = sort by CPU (default)
  - 'q' = quit
  - 'k' = kill process (can do this from top!)
- Visual way to see resource hogs
- Good for dynamic situations (load changing)

---

### 7. **ps** - Process Status
**Purpose:** Static snapshot of current processes

**Usage in Lab:**
- Module 04: Detailed process list
  ```bash
  ps aux
  ```
- Module 04: Sort by CPU usage
  ```bash
  ps aux --sort=-%cpu | head -20
  ```
- Module 04: Sort by memory usage
  ```bash
  ps aux --sort=-%mem | head -20
  ```

**Slide Points:**
- `aux` = all users, user-oriented format, include processes without TTY
- Shows: USER, PID, %CPU, %MEM, VSZ, RSS, TTY, STAT, START, TIME, COMMAND
- **--sort** for custom sorting
  - `-%cpu` = descending CPU (- means reverse)
  - `-%mem` = descending memory
- Non-interactive (snapshot in time)
- Better than top for scripting/documentation
- Can be grepped, awk'd, etc.

---

### 8. **cat** - Display File Contents
**Purpose:** Read systemd unit files and documentation

**Usage in Lab:**
- Used indirectly through systemctl cat
- Reading notes/documentation

**Slide Points:**
- Simple file display
- systemctl cat wraps this for unit files
- Also useful for reading /proc/* entries
- No-frills text output

---

## Performance Troubleshooting Flow

### Initial Assessment
1. **uptime** → Check load average (is CPU overloaded?)
   - Load > number of cores = problem
2. **free -h** → Check memory usage (is RAM exhausted?)
   - Low "available" = problem

### Service Investigation (Systemd Approach)
3. **systemctl status system-optimizer.service** → Identify the service
   - Is it running?
   - What PID?
   - What command (ExecStart=)?
4. **systemd-cgls** → See service process hierarchy
   - Multiple worker processes under one service
5. **systemctl cat system-optimizer.service** → Read unit file
   - Understand what it's configured to do
   - See full command with arguments
6. **systemctl is-enabled system-optimizer.service** → Check auto-start
   - Will it come back after reboot?
7. **journalctl -u system-optimizer.service** → Review service logs
   - What has it been doing?
   - Any errors or warnings?

### Process Investigation (Traditional Approach)
8. **top** → Interactive view of resource consumption
   - See stress-ng processes consuming CPU/memory in real-time
9. **ps aux --sort=-%cpu** → Static snapshot sorted by CPU
   - Document the offenders
10. **ps aux --sort=-%mem** → Static snapshot sorted by memory
    - Identify memory hogs

### Resolution
11. **systemctl stop system-optimizer.service** → Stop the runaway service
12. **systemctl disable system-optimizer.service** → Prevent auto-start
13. **uptime** → Verify load decreased
14. **free -h** → Verify memory freed
15. **systemctl status system-optimizer.service** → Confirm service stopped

---

## Key Teaching Points

### Systemd-First Troubleshooting
- Modern RHEL systems = systemd
- Services = the unit of organization
- Start with systemctl, not ps
- Systemd provides:
  - Service status
  - Process grouping (cgroups)
  - Logging (journal)
  - Lifecycle management (start/stop/enable/disable)

### The Service Was Named Misleadingly
- **Name:** "system-optimizer.service"
- **Reality:** Running stress-ng to hammer CPU/memory
- **Lesson:** Never trust service names
  - Always check ExecStart= to see actual command
  - Malicious or misguided actors use misleading names
  - systemctl cat reveals the truth

### Stop vs Disable
- **stop** = halt right now (current session)
- **disable** = don't start at next boot
- **Must do BOTH** for complete remediation:
  - Stop to fix current problem
  - Disable to prevent recurrence

### Load Average Interpretation
```
load average: 0.50, 0.45, 0.40  ← Healthy (on 2-core system)
load average: 4.50, 4.23, 3.98  ← Problem! (on 2-core system)
load average: 0.80, 1.20, 1.80  ← Worsening trend!
```

### Memory: Available vs Free
- **free** = completely unused memory
- **available** = can be used for new apps
  - Includes cache that can be reclaimed
  - **This is the number that matters!**
- Linux uses "free" memory for caching (good!)
- Don't panic if "free" is low - check "available"

---

## Slide Deck Suggestions

### Slide 1: The Symptoms
- Users report slow system
- Manager Scott claims he "optimized" it
- Show uptime with high load average

### Slide 2: Initial Assessment Tools
```
uptime    → Load average high (4.5 on 1-core system)
free -h   → Memory heavily used
```
"Something is consuming resources!"

### Slide 3: Systemd Investigation Flow
```
systemctl status system-optimizer.service
  → Active (running), PID 1234
  → ExecStart=/usr/bin/stress-ng --cpu 1 --vm 1 ...

systemctl cat system-optimizer.service
  → Shows full unit file
  → "stress-ng" - This isn't an optimizer!
```

### Slide 4: systemd-cgls Visualization
```
Control group /:
├─system.slice
│ ├─system-optimizer.service
│ │ ├─1234 /usr/bin/stress-ng --cpu 1 --vm 1
│ │ ├─1235 stress-ng-cpu [worker]
│ │ └─1236 stress-ng-vm [worker]
```
- Hierarchical view
- All service processes grouped together

### Slide 5: Traditional Tools (top/ps)
```
top
  PID  USER  %CPU  %MEM  COMMAND
  1235 root   99.9  10.5  stress-ng-cpu
  1236 root   45.2  25.8  stress-ng-vm

ps aux --sort=-%cpu | head -5
  (same data, static snapshot)
```

### Slide 6: The Culprit Revealed
**Service name:** "system-optimizer" (sounds helpful!)
**Actual command:** `stress-ng --cpu 1 --vm 1 --vm-bytes 512M`

stress-ng = stress test tool that deliberately consumes resources

**Scott's mistake:** Thought "warming up" CPU/memory would help performance

### Slide 7: Stop vs Disable
```
systemctl stop system-optimizer
  → Halts service immediately
  → Fixes current problem
  
systemctl disable system-optimizer  
  → Removes from auto-start
  → Prevents recurrence after reboot

systemctl is-enabled system-optimizer
  → disabled
```
**Both needed for complete fix!**

### Slide 8: Verification
```
BEFORE:
uptime → load average: 4.50, 4.23, 3.98
free -h → available: 512M

AFTER:
uptime → load average: 0.15, 0.45, 1.20  (dropping)
free -h → available: 3.2G  (recovered)
```

### Slide 9: Tool Comparison
| Tool | Type | Best For |
|------|------|----------|
| uptime | Quick check | First assessment |
| free | Quick check | Memory at a glance |
| systemctl | Service-centric | Modern systemd systems |
| systemd-cgls | Service-centric | Process hierarchies |
| journalctl | Logs | Service history |
| top | Process-centric | Real-time monitoring |
| ps | Process-centric | Snapshots, scripting |

### Slide 10: Systemd Commands Summary
| Command | Purpose |
|---------|---------|
| systemctl status | Check service state |
| systemctl cat | View unit file |
| systemctl is-enabled | Check auto-start |
| systemctl stop | Halt service now |
| systemctl disable | Prevent auto-start |
| systemd-cgls | View cgroup tree |
| journalctl -u | Read service logs |

### Slide 11: Best Practices
✓ Start with high-level tools (uptime, free)
✓ Use systemd tools first on modern systems
✓ Verify what commands actually do (ExecStart=)
✓ Check auto-start status (is-enabled)
✓ Stop AND disable problematic services
✓ Document findings before making changes
✓ Verify resolution after changes

### Slide 12: Common Runaway Scenarios
- **Runaway logging:** Service writing massive logs
- **Memory leak:** Application slowly consuming all RAM
- **Fork bomb:** Process spawning too many children
- **Infinite loop:** Application stuck in computation
- **Misconfiguration:** Like this lab - wrong tool for the job!

---

## Demo Script Notes

1. Show uptime - high load
2. Show free - low available memory
3. Explain Scott's email about "optimizer"
4. systemctl status system-optimizer.service
5. Point out it's running, show PID
6. **systemctl cat** - reveal ExecStart=stress-ng!
7. Explain stress-ng is a TESTING tool, not optimization
8. systemd-cgls - show multiple worker processes
9. journalctl - show service logs
10. top - watch live resource consumption
11. ps aux --sort - static view
12. systemctl stop - halt the service
13. Watch top - load drops immediately
14. systemctl disable - prevent restart
15. systemctl is-enabled - verify disabled
16. uptime - load decreasing
17. free - memory recovering
18. Lesson: Always verify what services actually do!
