# 🖥️ Server Scanner — Lightweight Server Performance Monitoring (DevOps Project)

A production-ready **Bash-based server performance monitoring tool** designed to run on any Linux environment.  
This script collects real-time system metrics, logs snapshots, and helps engineers **quickly diagnose system health** — without needing heavy monitoring tools like Prometheus or Datadog.

This project demonstrates practical skills required for **DevOps / SRE roles**, including:
✅ Linux system administration  
✅ Shell scripting & automation  
✅ Resource monitoring & troubleshooting  
✅ Log management  
✅ Git workflow & version control  
✅ CI/CD workflow fundamentals  

---

## 🚀 Features

| Capability | Description |
|-----------|-------------|
| **CPU Usage** | Measures real-time total CPU utilization |
| **Memory Stats** | Shows total, used, free memory + usage percentage |
| **Disk Monitoring** | Displays total disk usage + optional per-mount breakdown |
| **Top Resource Processes** | Lists top 5 CPU-heavy & memory-heavy processes |
| **System Health Meta** | OS version, uptime, logged-in users, load averages |
| **Failed SSH Attempts** | Useful for intrusion detection & audit logs |
| **Logging Automation** | `rotate-logs.sh` saves snapshots for later analysis |
| **Smoke Test** | `smoke_test.sh` verifies script functionality in deployments |

This tool is particularly useful for:
- Debugging slow servers
- Performance tuning
- Lightweight VM/cloud monitoring
- Teaching & interview demonstration

---

## 📂 Project Structure

server-scanner/
├── server-stats.sh # Main monitoring script
├── scripts/
│ └── rotate-logs.sh # Saves timestamped output snapshots
├── output/
│ ├── latest.txt # Most recent scan result
│ └── runs/ # Historical logs
├── tests/
│ └── smoke_test.sh # Basic validation test
├── system/ # (optional future system modules)
└── cron/ # (optional cron scheduling examples)

yaml
Copy code

---

## 🧰 Technology & Skills Demonstrated

| Skill | Demonstration |
|------|---------------|
| **Linux Administration** | Resource usage analysis, log inspection |
| **Shell Scripting (Bash)** | Writing maintainable automation scripts |
| **Monitoring & Observability** | Health metrics, load averages, process tracing |
| **CI/CD Concepts** | Automated smoke testing pipeline ready |
| **Version Control (Git)** | Clean repository & commit practices |
| **Server Troubleshooting** | Identifying high usage processes & disk pressure |

---

## 🛠️ Installation & Usage

### 1) Make script executable:
```bash
chmod +x server-stats.sh
2) Run a scan:
bash
Copy code
./server-stats.sh
3) Plain text mode:
bash
Copy code
./server-stats.sh --no-color
4) Detailed per-mount disk usage:
bash
Copy code
./server-stats.sh --details
📝 Logging Snapshots
Generate stored log output for audits or trend analysis:

bash
Copy code
./scripts/rotate-logs.sh
This produces:

bash
Copy code
output/latest.txt
output/runs/<timestamp>.txt
Useful for:

Incident post-mortems

Debug record comparison

Historical CPU/memory usage trends

✅ Smoke Test (quick functionality check)
bash
Copy code
./tests/smoke_test.sh
This ensures the script runs cleanly — useful when deploying into servers.

🧭 Roadmap (Next Enhancements)
Add JSON output mode → integrate with dashboards

Add per-core CPU utilization

Add network throughput metrics

Optional Telegram/Discord alert notifications

Docker container support

👤 Author
Nithin
Linux & DevOps Engineer (Entry-Level)
Focused on automation, monitoring, and production reliability.
