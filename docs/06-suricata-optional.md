# 06 — Suricata IDS on OPNsense (Optional)

Only do this if the core lab works and your laptop has spare RAM. Raise fw01 to **3 GB RAM** first
(power off → Settings → System).

Suricata is built into OPNsense: **Services → Intrusion Detection → Administration**.

## Step 1 — Settings tab

- **Enabled**: ✔
- **IPS mode**: **off** (alert only; we never drop traffic in this beginner version)
- **Promiscuous mode**: ✔
- **Interfaces**: `DMZ`
- **Home networks**: `10.10.20.0/24` **only**

**Why only the DMZ as "home":** many Emerging Threats rules only fire for traffic coming *from outside*
the home network *to* it. If all of 10.10.0.0/16 counted as home, traffic from Kali (USERS) to web01
(DMZ) would look "internal" and many rules would never fire. Treating USERS as untrusted also matches
the zero-trust idea. This is a strong interview answer.

## Step 2 — Download tab

Enable these ET Open rulesets: `ET open/emerging-scan`, `ET open/emerging-web_server`,
`ET open/emerging-attack_response`. Click **Download & Update Rules**.

## Step 3 — Apply

Click **Apply** and wait about a minute for the service to start.

## Step 4 — Prove it fires (safe test)

From **web01**:

```bash
curl http://testmynids.org/uid/index.html   # a harmless test page used to check that an IDS works
```

The reply looks like `id` command output. A rule (`GPL ATTACK_RESPONSE id check returned root`)
treats this as a sign of a compromised host. Then run the Nmap service scan from
[`07-testing-procedure.md`](07-testing-procedure.md) and look for `ET SCAN` alerts.

## Verification

- OPNsense → Intrusion Detection → **Alerts** tab shows the test alert. Screenshot: `screenshots/08-suricata-alert-opnsense.png`.
- If the fw01 Wazuh agent forwards IDS events, filter in Wazuh with `rule.groups: suricata`. Screenshot: `screenshots/09-suricata-alert-wazuh.png`.

## Troubleshooting

| Symptom | Likely cause / fix |
|---|---|
| No alerts at all | Wrong interface selected; Home networks not set to 10.10.20.0/24; rules not downloaded; offloading not disabled |
| Alerts in OPNsense but not in Wazuh | Check the plugin's IDS forwarding option; on fw01 read `/var/ossec/logs/ossec.log`. Forwarding Suricata events from the plugin is a known pain point. Record what you found. |
| fw01 becomes very slow | Not enough RAM. Disable some rulesets or give fw01 3 GB. |
| DMZ traffic stops | IPS mode got switched on by mistake. Turn it off. |
