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
    # I'm going to redirect errors to a temporary file for processing.
    temp_file=$(mktemp)
    /bin/pssh.sh -f "$hosts_file" echo "test" 2> $temp_file

    # Process the results to filter out non-responsive hosts
    while IFS= read -r line; do
        if [[ $line == *"Could not resolve"* ]]; then
            host=$(echo $line | cut -d' ' -f1)  # Extracting the hostname from the error message
            echo -e "${RED}${host} - CONNECTION ERROR${RESET}"
        else
            responsive_hosts+=("$host")
        fi
    done < $temp_file

    rm $temp_file

    echo "${responsive_hosts[@]}"
}

# Later, when calling this function
responsive_hosts=( $(verify_connection "$1") )

# You can then use $responsive_hosts for subsequent steps in the script.
