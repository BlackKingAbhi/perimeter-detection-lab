# Detection Rules

| File | Purpose | Status |
|---|---|---|
| `local_rules.xml` | Custom Wazuh rules 100100 / 100101 (repeated SSH failures from one IP) | ⬜ Not yet verified |
| `logtest-output.txt` | Output of `wazuh-logtest` proving the rules match | ⬜ To be added |
| `sample-auth-log-lines.txt` | Example log lines in the right format for testing | Reference only |

## Built-in Wazuh rules this lab relies on

| Rule ID | Meaning |
|---|---|
| 5710 | sshd: attempt to log in with a non-existent user |
| 5715 | sshd: authentication success |
| 5760 | sshd: authentication failed |
| 5763 | sshd: built-in brute-force correlation (multiple failures) |
| 31100-series | web server access-log events (Nginx/Apache) |

Rule IDs can differ slightly between Wazuh versions. Confirm them in **Dashboard → Server management → Rules**
(menu names vary by version) and update this table if needed.

## Why write a custom rule if Wazuh already has 5763?

The built-in rule is generic. Ours documents a clear, explainable threshold (5 in 60 s from one IP)
and is tagged with a specific MITRE technique. In an interview you can explain every line, which is the point.

## How to test (on wazuh01)

```bash
sudo /var/ossec/bin/wazuh-logtest
```

Paste one line from `sample-auth-log-lines.txt` (or, better, a **real** line copied from web01's
`/var/log/auth.log`) and press Enter. Repeat 5 times with the same source IP. Phase 3 of the output
should show rule **5760** each time, and rule **100100** on the 5th. Copy the full output into
`logtest-output.txt`.

> Logtest correlation across multiple pasted lines works within one logtest session. If rule 100100
> does not appear, check the line format and the timestamp. Record the result honestly.
