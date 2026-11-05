# 05 — Wazuh SIEM (wazuh01) and Agents

Wazuh has three parts. The **manager** analyses logs and applies rules. The **indexer** stores the
alerts. The **dashboard** is the web interface. We install all three on one VM ("all-in-one").
**Agents** run on the monitored machines and send logs to the manager over TCP 1514 (registration
uses TCP 1515).

## Step 1 — Create the VM

| Setting | Value |
|---|---|
| Name | `wazuh01` |
| OS | Ubuntu Server 24.04 LTS |
| CPU / RAM | 2–4 vCPU / 5–6 GB (official recommendation is 4 vCPU / 8 GB) |
| Disk | 50 GB, dynamically allocated |
| Network | Adapter 1: Host-only adapter (MGMT) |

Installer network settings: Manual, subnet `10.10.99.0/24`, address `10.10.99.10`, gateway
`10.10.99.1`, DNS `10.10.99.1`. Tick **Install OpenSSH server**. User `admin01`.

After the first boot, SSH in from your laptop (`ssh admin01@10.10.99.10`) and run:

```bash
sudo apt update && sudo apt full-upgrade -y
sudo timedatectl set-timezone Asia/Kolkata
```

## Step 2 — Install Wazuh (all-in-one)

Open the official quickstart, <https://documentation.wazuh.com/current/quickstart.html>, and copy the
install command **for the current version** shown there. At the time of writing it looks like this
(the `4.x` part changes between releases):

```bash
curl -sO https://packages.wazuh.com/4.x/wazuh-install.sh   # download the official installer (check the version on the quickstart page)
sudo bash ./wazuh-install.sh -a                            # -a = install manager + indexer + dashboard on this machine
```

This takes 10–20 minutes. At the end it prints the **admin** password. Save it in a password manager,
**never** in the repo.

Stop accidental upgrades from breaking the lab later (as the Wazuh docs recommend):

```bash
sudo sed -i "s/^deb /#deb /" /etc/apt/sources.list.d/wazuh.list   # comment out the Wazuh repo line
sudo apt update
```

## Step 3 — Open the dashboard

Browse to `https://10.10.99.10` from your laptop. The certificate warning is expected because the
certificate is self-signed. Log in as `admin`.

## Step 4 — Install the agent on web01

Dashboard → **Agents** → **Deploy new agent**:

- Package: **DEB amd64**, Server address: `10.10.99.10`, Agent name: `web01`.
- The dashboard generates the install commands. Run them on web01, then run:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now wazuh-agent   # start the agent now and at every boot
```

**Firewall dependency:** web01 (DMZ) must be able to reach 10.10.99.10 on TCP 1514–1515. That is DMZ
rule 3 in the firewall rules. Without it, the agent stays "Never connected".

On Debian/Ubuntu, the agent installer normally adds `/var/log/auth.log` (SSH logins) to its config,
and it adds the Nginx logs if Nginx is already installed. **Do not assume this. Verify it:** check the
`<localfile>` blocks in `/var/ossec/etc/ossec.conf` on web01. If Nginx logs are missing, add the
snippet from [`../configurations/wazuh/web01-agent-localfile.xml`](../configurations/wazuh/web01-agent-localfile.xml).

## Step 5 (optional) — Agent on the firewall

OPNsense → **System → Firmware → Plugins** → install **os-wazuh-agent**. Then **Services → Wazuh
Agent**: manager `10.10.99.10`, enable it, and tick the firewall log and intrusion detection
event options. The agent version must **not be newer** than the manager version. If registration
fails, check the versions first.

## Step 6 — Add the custom detection rule

Copy [`../detection-rules/local_rules.xml`](../detection-rules/local_rules.xml) into
`/var/ossec/etc/rules/local_rules.xml` on wazuh01 (merge it if the file already has rules). Then test
it **before** going live:

```bash
sudo /var/ossec/bin/wazuh-logtest   # interactive: paste a log line, see which rule it matches
```

Paste a real `Failed password` line from web01's `/var/log/auth.log`. It should match rule 5760, and
after enough repeats, rule 100100. Save the output as `detection-rules/logtest-output.txt`. Then:

```bash
sudo systemctl restart wazuh-manager
sudo systemctl status wazuh-manager --no-pager   # must say active (running)
```

## Verification

| Check | Expected |
|---|---|
| Dashboard → Agents | `web01` (and `fw01` if installed) are **Active** |
| On wazuh01: `sudo /var/ossec/bin/agent_control -l` | lists the agents as Active |
| Smoke test: from the laptop, `ssh wronguser@10.10.20.10` and enter a wrong password once | an alert (rule 5710 or 5760) for agent web01 appears within about a minute |

Screenshots: `screenshots/06-wazuh-agents-active.png`, `screenshots/07-wazuh-first-ssh-alert.png`.

## If an agent shows "Disconnected" or "Never connected"

1. On wazuh01: `sudo /var/ossec/bin/agent_control -l`
2. On the agent: `sudo tail -n 50 /var/ossec/logs/ossec.log`. Look for connection errors.
3. From the agent: `nc -zv 10.10.99.10 1514` — if this fails, it is a firewall rule or routing problem.
4. Version mismatch: the agent must be the same version as the manager or older.
