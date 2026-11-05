# Incident Report 02 — Repeated failed SSH logins on web01

> ⬜ **DRAFT, not yet performed.** Fill in only with real results from your lab. Delete this line when done.

| Field | Value |
|---|---|
| Detected (date/time IST) | |
| Analyst | Abhishek Ambasta |
| Source → Destination | 10.10.10.___ (kali01) → 10.10.20.10:22 (web01) |
| Alerts | Wazuh 5760 (×__), 5710 (×__), 100100 (×__) |
| MITRE ATT&CK | T1110.001 Brute Force: Password Guessing |
| Severity | Medium |

## 1. Summary
## 2. Timeline
## 3. Evidence
```
<Failed password lines from /var/log/auth.log>
```
## 4. Investigation / Analysis
Key check: `sudo grep "Accepted" /var/log/auth.log`. Was there any successful login from the source IP after the failures?
## 5. Verdict
## 6. Response
- **Recommended:** key-only SSH (`configurations/ssh/99-lab-hardening.conf`); allow SSH to the DMZ only from MGMT;
  consider automatic blocking in a future version (out of scope here).
