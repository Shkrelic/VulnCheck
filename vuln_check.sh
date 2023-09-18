#!/bin/bash

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check if host file and CVE are provided
if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 <host_file> <cve>"
    exit 1
fi

HOST_FILE="$1"
CVE="$2"

# Temporary file to hold the pssh.sh results
TMP_RESULT=$(mktemp)

# Parse function as per your earlier details
parse_results() {
    local output="$1"
    local host="$2"
    local cve="$3"

    # Check if the output contains the relevant details
    if echo "$output" | grep -q "$cve"; then
        local update_id=$(echo "$output" | grep 'Update ID' | awk '{print $3}')
        local issued_date=$(echo "$output" | grep 'Issued' | awk '{print $3" "$4}')
        local title=$(echo "$output" | grep -E 'Important:|Moderate:|Critical:' | cut -d ":" -f 2-)
        echo -e "$host: ${RED}Vulnerable${NC} - $update_id - $issued_date - $title"
    elif echo "$output" | grep -q "No matches found"; then
        echo -e "$host: ${GREEN}Safe${NC}"
    else
        echo -e "$host: ${YELLOW}Unknown${NC} - $(echo "$output")"
    fi
}

echo "Step 1: Starting parallel SSH to gather data from all hosts..."

# Execute the parallel ssh and put the result in the temporary file
~/bin/pssh.sh -h "$HOST_FILE" -q sh -c "yum updateinfo info --cve $CVE 2>/dev/null" > "$TMP_RESULT" &

PSSH_PID=$!

echo "Gathering data in the background..."
wait $PSSH_PID

echo "Step 2: Data gathering complete. Stored in a temporary location."

echo "Step 3: Beginning to parse the data..."

# Parse the results based on the host file
while IFS= read -r host; do
    # Extracting host-specific output
    host_output=$(awk "/^$host:/,/^$/" "$TMP_RESULT")

    # Parse results for the specific host
    parse_results "$host_output" "$host" "$CVE"
done < "$HOST_FILE"

# Cleaning up the temp file
rm -f "$TMP_RESULT"





#!/bin/bash

HostOutput="Host::; Uptime:; Pending Security Updates\n"

# Get the uptime and number of pending security updates for each host
HostOutput=$HostOutput$(pssh.sh -f hosts.txt sh -c 'echo ":; $(uptime | awk -F" " "{print $2, $3}"); :$(yum -q updateinfo list security 2> /dev/null | grep RHSA | wc -l)"')

# Echo the output to the column command
echo -e "$HostOutput" | column -t -s":"

# Unset the HostOutput variable
unset HostOutput
