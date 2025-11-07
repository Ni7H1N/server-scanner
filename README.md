# 🖥️ Server Scanner — Lightweight Server Performance Monitoring (DevOps Project)

A production-ready **Bash-based server monitoring tool** designed to run on any Linux system.  
It collects system metrics, identifies resource bottlenecks, and stores diagnostic logs — without requiring heavy monitoring stacks like Prometheus or Datadog.

This project demonstrates practical **DevOps / SRE skillsets**, including:
- ✅ Linux system administration
- ✅ Shell scripting & automation
- ✅ Server performance monitoring & analysis
- ✅ Log retention and snapshot management
- ✅ Git workflow & version control practices
- ✅ CI/CD readiness and testing discipline

---

## 🚀 Features

| Feature | Description |
|--------|-------------|
| **CPU Usage** | Measures real-time CPU utilization |
| **Memory Monitoring** | Shows total, used, free memory + percentage usage |
| **Disk Usage Summary** | Aggregated disk usage; detailed per-mount via `--details` |
| **Top Resource Processes** | Lists top CPU and memory consuming processes |
| **System Metadata** | OS version, uptime, logged-in users, load averages |
| **Security Visibility** | Identifies failed SSH login attempts (24h window) |
| **Log Rotation** | `scripts/rotate-logs.sh` stores history snapshots for auditing |
| **Smoke Testing** | `tests/smoke_test.sh` verifies operational readiness |

Useful for:
- Troubleshooting slow servers
- Lightweight VM/cloud performance insight
- Teaching & interview demonstrations
- Building fundamental DevOps monitoring habits

---

## 📂 Project Structure

```
server-scanner/
├── server-stats.sh          # Main monitoring script
├── scripts/
│   └── rotate-logs.sh       # Saves timestamped output snapshots
├── output/
│   ├── latest.txt           # Most recent scan result
│   └── runs/                # Historical log snapshots
├── tests/
│   └── smoke_test.sh        # Deployment validation test
├── system/                  # (optional) additional system tools
└── cron/                    # (optional) cron automation
```

---

## 🧰 Skills Demonstrated

| Skill Area | Demonstration in Project |
|-----------|--------------------------|
| **Linux Administration** | Process inspection, memory/CPU/disk analysis |
| **Bash Scripting** | Modular, readable automation scripts |
| **Observability & Monitoring** | Useful metrics for debugging & analysis |
| **Troubleshooting Mindset** | Locating bottlenecks and analyzing system load |
| **Automation & Logging** | Snapshot rotation & storage for auditing |
| **CI/CD Testing Approach** | Smoke test ensures safe deployment |

---

## 🛠️ Installation & Usage

### 1) Make scripts executable
```bash
chmod +x server-stats.sh
```

### 2) Run a system scan
```bash
./server-stats.sh
```

### 3) Log-friendly (no color) output
```bash
./server-stats.sh --no-color
```

### 4) Detailed per-mount disk usage
```bash
./server-stats.sh --details
```

---

## 📝 Logging Snapshots (for history / troubleshooting)

```bash
./scripts/rotate-logs.sh
```

This generates:
```
output/latest.txt
output/runs/<timestamp>.txt
```

Use for:
- Incident investigations
- Performance regression comparison
- Capacity trend analysis

---

## ✅ Smoke Test (deployment validation)

```bash
./tests/smoke_test.sh
```

Ensures the script works safely before shipping to production or servers.

---

## 🧭 Roadmap / Future Enhancements

- JSON output mode (dashboard / API integration)
- Per-core CPU utilization breakdown
- Network bandwidth / I/O throughput monitoring
- Alerting (Slack / Discord / Telegram bots)
- Dockerized deployment support
- Cron-based scheduled reporting with email alerts

---

## 👤 Author

**Nithin**  
*Linux & DevOps Engineer (Entry-Level)*  
Passionate about automation, monitoring, and building reliable infrastructure.

---

## ⭐ Support

If this project helped you, please **star the repository** — it helps visibility and growth.

---

## 📄 License

Licensed under the **MIT License** — free for personal and commercial use.

