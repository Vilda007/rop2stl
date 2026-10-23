#!/bin/bash
# rop2stl push — managed PAT z hosts.yml, URL sanitizace po pushi
set -e
cd /home/vildadmin/.openclaw/workspace/projects/rop-katalog
TOKEN=$(grep -oP 'oauth_token:\s*\K\S+' ~/.openclaw/credentials/github/agents/0d6e4079e36703ebd37c00722f5891d28b0e2811dc114b129215123adcce3605/*/hosts.yml | head -1 | tr -d '\r')
if [ -z "$TOKEN" ]; then echo "FAIL: token not found"; exit 1; fi
git push "https://Vilda007:${TOKEN}@github.com/Vilda007/rop2stl.git" main 2>&1 | tail -2
git remote set-url origin "https://github.com/Vilda007/rop2stl.git" 2>/dev/null || true
echo "---"
git log --oneline -1