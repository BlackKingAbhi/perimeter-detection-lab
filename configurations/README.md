# Configurations

Sanitised configuration files and hand-copied settings. **No secrets, no raw exports.**

| Path | What it is | Where it goes |
|---|---|---|
| `opnsense/firewall-rules.md` | Aliases and rules per interface (hand-copied) | OPNsense GUI |
| `opnsense/interfaces.md` | Interface assignment table | OPNsense GUI |
| `nginx/index.html` | Lab web page | web01 `/var/www/html/index.html` |
| `nginx/security-headers.conf` | Basic Nginx hardening | web01 `/etc/nginx/conf.d/` |
| `ssh/99-lab-hardening.conf` | Key-only SSH (apply after testing) | web01 `/etc/ssh/sshd_config.d/` |
| `wazuh/web01-agent-localfile.xml` | Log files the web01 agent should read | web01 `/var/ossec/etc/ossec.conf` |

**Never commit** the OPNsense `config-*.xml` backup. It contains password hashes and private keys.
