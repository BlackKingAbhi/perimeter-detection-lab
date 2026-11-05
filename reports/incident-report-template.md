# Incident Report <NN> — <short title>

| Field | Value |
|---|---|
| Detected (date/time IST) | |
| Analyst | Abhishek Ambasta |
| Source → Destination | 10.10.10.x → 10.10.20.10 |
| Alerts | <Wazuh rule IDs + Suricata signature names> |
| MITRE ATT&CK | <e.g. T1046 Network Service Discovery / T1110.001 Password Guessing> |
| Severity | Low / Medium / High |

## 1. Summary
<Two or three sentences: what happened, and was it successful?>

## 2. Timeline
| Time | Event |
|---|---|
| | First alert |
| | Peak activity |
| | Last alert |

## 3. Evidence
- Log lines (paste, redacted):
```
<log lines>
```
- Screenshot(s): `screenshots/...`
- Wazuh alert JSON: `reports/evidence/...`

## 4. Investigation / Analysis
<What did you check? E.g. for SSH: was there any "Accepted password" after the failures?
`sudo grep "Accepted" /var/log/auth.log`>

## 5. Verdict
True positive / False positive / Benign, and why.

## 6. Response
- **Taken:** <e.g. none needed. Lab test, attempts failed.>
- **Recommended:** <e.g. key-only SSH, restrict SSH to MGMT only, keep firewall rule tight, alert tuning>
