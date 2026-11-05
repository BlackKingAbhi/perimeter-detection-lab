# Scripts

Small, **read-only** helper scripts. None of them change configuration or attack anything.

| Script | Run on | Purpose |
|---|---|---|
| `web01-baseline.sh` | web01 | Records host info, listening ports, services and SSH login history |
| `lab-connectivity-check.sh` | kali01 | Checks that the firewall allows or denies each path as designed |
| `wazuh-health-check.sh` | wazuh01 | Checks Wazuh services, agents, ports and custom rules |

How to copy a script to a VM (from your laptop, which is on MGMT):

```bash
scp scripts/web01-baseline.sh admin01@10.10.20.10:~/
```

Then on the VM: `bash web01-baseline.sh`. (Kali is not reachable from MGMT by SSH unless you enable
it; you can paste the script into a file with `nano` instead.)

Status: syntax-checked with `bash -n` only. They have **not** yet been run inside the lab. Update this line after you run them.
