#!/bin/bash

HOST_FILE="$1"
CVE_FILE="$2"
TMP_RESULT=$(mktemp)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

declare -a PROCESSED_HOSTS

parse_results() {
    local output="$1"
    local host="$2"
    local cve="$3"

    # Check if the output contains the relevant details
    if echo "$output" | grep -q "$cve"; then
        echo -e "$host: ${RED}Vulnerable${NC} - $(echo "$output" | grep 'Update ID' | awk '{print $3}') - $(echo "$output" | grep 'Issued' | awk '{print $3" "$4}') - $(echo "$output" | grep -E 'Important:|Moderate:|Critical:' | cut -d ":" -f 2-)"
    elif echo "$output" | grep -q "No matches found"; then
        echo -e "$host: ${GREEN}Safe${NC}"
    else
        echo -e "$host: ${YELLOW}Unknown${NC} - $(echo "$output")"
    fi
}

while read -r host; do
    if [[ " ${PROCESSED_HOSTS[@]} " =~ " ${host} " ]]; then
        continue
    fi
    PROCESSED_HOSTS+=("$host")

    while read -r cve; do
        result=$(~/bin/pssh.sh -h $host -q sh -c "yum updateinfo info --cve $cve 2>/dev/null")
        clean_output=$(echo "$result" | sed -n '/^$/,/Loaded plugins:/p')
        parse_results "$clean_output" "$host" "$cve"
    done < "$CVE_FILE"
done < "$HOST_FILE"

rm "$TMP_RESULT"
