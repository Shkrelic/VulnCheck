#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'

# Step 1: Input Validation
if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${RED}Both arguments \$1 and \$2 must be defined.${RESET}"
    exit 1
fi

# Step 2: Connection Verification
verify_connection() {
    local hosts_file="$1"
    local responsive_hosts=()

    # Using pssh.sh to check connection by simply echoing "test"
    # We're assuming that any non-responding host will throw an error containing the phrase "Could not resolve" (this may need adjustment based on actual error messages you see)
    results=$(/bin/pssh.sh -f "$hosts_file" -o '|grep "Could not resolve"' echo "test")

    # Process the results to filter out non-responsive hosts
    while IFS= read -r line; do
        if [[ $line == *"Could not resolve"* ]]; then
            host=$(echo $line | cut -d':' -f1)  # Extracting the hostname from the error message
            echo -e "${RED}${host} - CONNECTION ERROR${RESET}"
        else
            responsive_hosts+=("$host")
        fi
    done <<< "$results"

    echo "${responsive_hosts[@]}"
}

# Later, when calling this function
responsive_hosts=( $(verify_connection "$1") )

# You can then use $responsive_hosts for subsequent steps in the script.
