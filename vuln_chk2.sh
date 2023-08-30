#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Step 1: Input Validation
validate_inputs() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${RED}Both arguments must be defined.${RESET}"
        exit 1
    fi
}

# Step 2: Connection Verification
# Step 2: Connection Verification
verify_connection() {
    local hosts_file="$1"
    local responsive_hosts=()

    while IFS= read -r host; do
        # Using /dev/tcp to check if port 22 (SSH) is open
        if (echo > "/dev/tcp/$host/22") 2>/dev/null; then
            responsive_hosts+=("$host")
        else
            echo -e "${host} - ${RED}CONNECTION ERROR${RESET}"
        fi
    done < "$hosts_file"

    echo "${responsive_hosts[@]}"
}

# Step 3: Gather CVE Information
gather_cve_info_from_redhat() {
    local endpoint="/cvrf.json"
    local params="package=kernel"
    local full_url="https://access.redhat.com/hydra/rest/securitydata${endpoint}?${params}"

    curl -s "$full_url" | jq -r '.[] | "\(.RHSA) - \(.severity)"'
}

main() {
    echo -e "${BLUE}==> Validating Inputs${RESET}"
    validate_inputs "$1" "$2"

    echo -e "${BLUE}==> Verifying Connection to Hosts${RESET}"
    local responsive_hosts
    responsive_hosts=$(verify_connection "$1")
    echo -e "Responsive Hosts: ${GREEN}${responsive_hosts}${RESET}"

    echo -e "${BLUE}==> Gathering CVE Information from Red Hat${RESET}"
    gather_cve_info_from_redhat
}

main "$1" "$2"
