# Host Record — web01

| Field | Value |
|---|---|
| Purpose | Public-facing web server for the lab office |
| Zone | DMZ |
| IP / Gateway / DNS | 10.10.20.10/24 / 10.10.20.1 / 10.10.20.1 |
| OS | Ubuntu Server 24.04 LTS |
| Services | nginx (TCP 80), OpenSSH (TCP 22) |
| Admin account | admin01 (password in password manager; key-only after hardening) |
| Monitoring | Wazuh agent `web01` → 10.10.99.10 |

## Baseline: `sudo ss -tulpn` output

```
<paste real output here>
```

## Known weaknesses (intentional, for testing)

- SSH password authentication enabled until testing is complete → fixed by `configurations/ssh/99-lab-hardening.conf`.
