# Incident Report 01 — Network scan against DMZ web server

> ⬜ **DRAFT, not yet performed.** Fill in only with real results from your lab. Delete this line when done.

| Field | Value |
|---|---|
| Detected (date/time IST) | |
| Analyst | Abhishek Ambasta |
| Source → Destination | 10.10.10.___ (kali01, USERS) → 10.10.20.0/24, 10.10.20.10 (web01, DMZ) |
| Alerts | |
| MITRE ATT&CK | T1046 Network Service Discovery |
| Severity | Low (reconnaissance, no access gained) |

## 1. Summary
## 2. Timeline
## 3. Evidence
## 4. Investigation / Analysis
Questions to answer: Which ports did the scanner find open? Did the firewall block the other ports
(Live View)? Did Suricata/Wazuh raise an alert, and if not, why not?
## 5. Verdict
## 6. Response
- **Recommended:** expose only TCP 80/443 from USERS to the DMZ; keep block-rule logging on; enable Suricata scan rules.
