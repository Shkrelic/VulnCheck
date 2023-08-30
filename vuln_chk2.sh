#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Input validation
if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${RED}Error: Please provide both arguments.${NC}"
    echo "Usage: $0 <hosts_file> <advisory>"
    exit 1
fi

host_file=$1
advisory=$2

# Connection verification

output_file="/tmp/pssh_output_$(date +%s)"
pssh.sh -h $host_file "echo connected" > $output_file

while IFS= read -r line; do
    host=$(echo "$line" | cut -d' ' -f1)
    message=$(echo "$line" | cut -d' ' -f2-)

    if echo "$message" | grep -q "connected"; then
        echo -e "${GREEN}${host} is reachable.${NC}"
    else
        echo -e "${RED}${host} - CONNECTION ERROR${NC}"
    fi
done < $output_file

rm -f $output_file

# API interaction via another server
SERVER_TO_MAKE_API_CALL="your.server.name"
data=$(pssh.sh -h "$SERVER_TO_MAKE_API_CALL" "curl -s 'https://access.redhat.com/hydra/rest/securitydata/cve.json?advisory=$advisory'")
cve_data=$(echo "$data" | jq '.[] | "\(.CVE) - \(.severity)"')

echo -e "${GREEN}CVE Details from Server:${NC} $cve_data"

# Continue with other tasks...
