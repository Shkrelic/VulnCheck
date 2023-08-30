#!/bin/bash

# Color codes
RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

API_HOST="https://access.redhat.com/hydra/rest/securitydata"
API_SERVER="YOUR_API_SERVER_HOSTNAME"  # Set this to your server's hostname

# Check inputs
if [[ -z "$1" || -z "$2" ]]; then
    echo -e "${RED}Usage: $0 <hosts_file> <CVE_number>${RESET}"
    exit 1
fi

host_file="$1"
cve_number="$2"

# Connection Verification
echo "Testing connections to hosts..."

# Using pssh.sh with the -f flag to check connections in parallel
pssh.sh -f $host_file "echo 1" | while read -r line; do
    host=$(echo "$line" | cut -d ':' -f 1)
    result=$(echo "$line" | cut -d ':' -f 2)

    if [[ $result =~ "1" ]]; then
        echo -e "${GREEN}${host} is reachable.${RESET}"
    else
        echo -e "${RED}${host} - CONNECTION ERROR${RESET}"
    fi
done

# Fetch CVE Information from API via the API_SERVER
API_RESPONSE=$(pssh.sh -h $API_SERVER "curl -s '${API_HOST}/cve.json?cve=${cve_number}'")

# Use Python to parse API response
python3 - <<END
import json

data = json.loads('''$API_RESPONSE''')

for cve in data:
    print(f"{cve['CVE']} - CVE Severity: {cve['severity']} - Title: {cve['document_title']}")

END

# Continue with the rest of the script...
