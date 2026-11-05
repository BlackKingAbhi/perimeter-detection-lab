#!/usr/bin/env bash
# wazuh-health-check.sh — quick health check of the Wazuh server.
# Run on wazuh01:  bash wazuh-health-check.sh
# Read-only.

set -u

echo "== Services =="
for svc in wazuh-manager wazuh-indexer wazuh-dashboard; do
  printf '%-16s %s\n' "$svc" "$(systemctl is-active "$svc")"
done

echo; echo "== Agents (should be Active) =="
sudo /var/ossec/bin/agent_control -l

echo; echo "== Listening ports (expect 1514, 1515, 443, 9200) =="
sudo ss -tlnp | grep -E ":(1514|1515|443|9200)\b"

echo; echo "== Custom rules loaded? =="
sudo grep -c "rule id=\"1001" /var/ossec/etc/rules/local_rules.xml 2>/dev/null \
  | xargs -I{} echo "{} custom rule(s) found in local_rules.xml"

echo; echo "== Last 5 alerts mentioning sshd =="
sudo grep -h '"sshd"' /var/ossec/logs/alerts/alerts.json 2>/dev/null | tail -n 5 \
  | cut -c1-300 || echo "none yet"

echo; echo "== Memory =="
free -h
