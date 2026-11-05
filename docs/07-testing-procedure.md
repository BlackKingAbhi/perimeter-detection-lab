# 07 — Testing Procedure (Attack → Detect → Investigate)

## Rules of engagement (read before every test)

- Only test **your own VMs inside this lab**: `10.10.20.10` (web01) and the lab subnets.
- Never point these commands at your college network, Wi-Fi, or any public address. Scanning
  systems you do not own or are not authorised to test is illegal in most countries.
- The USERS and DMZ networks are VirtualBox **internal** networks, so test traffic cannot leave your laptop.

## Before each test

1. Check the clocks: run `date` on Kali, web01 and wazuh01. They should agree to within a few seconds.
2. Open the Wazuh dashboard → **Threat Hunting** (or **Security events** in older versions), with the time range set to "Last 15 minutes".
3. Open OPNsense → **Firewall → Log Files → Live View**.
4. Write the **start time** into `reports/attack-log.md`. This log is your *ground truth*. Comparing
   it with what the SIEM caught is what makes this a detection exercise, not just a tool demo.

---

## Test A — Network discovery and service scan (Nmap)

**What it simulates:** an attacker on a staff laptop mapping which hosts and services exist.
MITRE ATT&CK **T1046 Network Service Discovery**.

From **kali01**:

```bash
date                              # record the start time
sudo nmap -sn 10.10.20.0/24       # -sn = "ping scan": which hosts are alive? No port scanning.
sudo nmap -sV 10.10.20.10         # check common ports on web01 and identify the service versions
date                              # record the end time
```

**What each part means**

- `sudo` gives Nmap raw-socket permission, which it needs for its default scan types.
- `-sn` only checks whether hosts respond.
- `-sV` connects to open ports and asks each service what it is (for example, nginx 1.24, OpenSSH 9.6).

**Where to look**

| Source | Expected evidence |
|---|---|
| Nmap output | With the final rules: only port 80 (and 443 if used) is open. With the "as-found" rule: 22 and 80. |
| OPNsense Live View | Many **blocked** entries from Kali's IP to other ports on 10.10.20.10 (because the USERS block rule logs) |
| Suricata (optional) | `ET SCAN` signatures in the Alerts tab |
| Wazuh | Nginx access-log entries from Kali's IP. Firewall/Suricata alerts appear only if the fw01 agent is installed. |

> Honest note: a host-based agent on web01 alone often does **not** raise a clear "port scan" alert.
> Scans are mainly visible at the **network** level (firewall logs or IDS). If Wazuh shows nothing for
> this test, record that as a detection gap and explain why. That is a good interview answer.

---

## Test B — Failed SSH login attempts (manual)

**What it simulates:** someone trying to guess the password of a server account.
MITRE ATT&CK **T1110 Brute Force**. We do it **by hand**, a few times, to generate log evidence.

**Which machine to run it from**

- With the final least-privilege rules, SSH from USERS → DMZ is blocked, which is the correct design.
  So either:
  - **Option 1 (recommended):** run this test while the temporary "as-found" `pass any` rule is still on USERS, then tighten the rules afterwards; or
  - **Option 2:** run it from your laptop (MGMT), which is allowed to SSH to web01.

From **kali01** (option 1), repeat this **6 times within 1 minute**, typing a wrong password each time:

```bash
ssh testuser@10.10.20.10      # 'testuser' does not exist; type any wrong password, then Ctrl+C
ssh admin01@10.10.20.10       # a real user with a wrong password
```

Each wrong password writes a line like this to web01's `/var/log/auth.log`:

```
Failed password for admin01 from 10.10.10.1xx port 5xxxx ssh2
```

**Where to look**

| Source | Expected evidence |
|---|---|
| web01: `sudo grep "Failed password" /var/log/auth.log \| tail` | one line per attempt, showing Kali's IP |
| web01: `sudo grep "Accepted" /var/log/auth.log \| tail` | **no** new successful login from Kali (proves the attempts failed) |
| Wazuh | rule **5760** (sshd: authentication failed) or **5710** (non-existent user) per attempt |
| Wazuh | our custom rule **100100** once there are 5+ failures from the same IP within 60 s |

Useful Wazuh search filters:

```
agent.name: web01 and rule.id: (5710 or 5760 or 100100)
```

---

## Test C (optional) — IDS test page

See [`06-suricata-optional.md`](06-suricata-optional.md), step 4.

---

## After each test

1. Record the end time and what you observed in `reports/attack-log.md`.
2. Fill in one row of `reports/detection-coverage.md`.
3. Write an incident report from `reports/incident-report-template.md`.
4. Export the relevant Wazuh alert as JSON (open the alert → JSON tab → copy) and save it under
   `reports/evidence/`. Remove anything sensitive first.
5. Take the screenshots listed in `screenshots/README.md`.

**Golden rule:** only document what actually happened. If something did not fire, say so and explain why.
