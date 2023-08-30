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

    # Unique string for connection test
    unique_string="CONNECTION_SUCCESS_12345"

    # Using pssh.sh to check connection by echoing the unique string
    results=$(~/bin/pssh.sh -f "$hosts_file" echo "$unique_string")

    # Process results and categorize hosts as responsive or unresponsive
    while IFS= read -r line; do
        host=$(echo $line | cut -d' ' -f1)  # Extracting the hostname
        if [[ $line == *"$unique_string"* ]]; then
            responsive_hosts+=("$host")
        else
            echo -e "${RED}${host} - CONNECTION ERROR${RESET}"
        fi
    done <<< "$results"

    echo "${responsive_hosts[@]}"
}

# Later, when calling this function
responsive_hosts=( $(verify_connection "$1") )

# You can then use $responsive_hosts for subsequent steps in the script.
