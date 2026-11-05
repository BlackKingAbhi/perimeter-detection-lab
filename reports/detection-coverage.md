# Detection Coverage

For each test: what did we expect to detect it, and did it actually fire? **Gaps are fine. Document and explain them.**

| Test | Expected detection | Fired? (Y/N) | Rule ID / signature | Time to alert | Notes / gap explanation |
|---|---|---|---|---|---|
| A1 Host discovery | OPNsense firewall log; Suricata (optional) | | | | |
| A2 Service scan | Firewall block logs; Suricata `ET SCAN` (optional); nginx access log in Wazuh | | | | |
| B1 Failed SSH ×6 | Wazuh 5760 / 5710 per attempt; custom 100100 after 5 in 60 s | | | | |
| C1 IDS test page | Suricata `GPL ATTACK_RESPONSE id check returned root` | | | | |
