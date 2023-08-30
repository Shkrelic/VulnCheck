#!/usr/bin/env python

import sys
import socket
import requests

# Define constants
API_HOST = 'https://access.redhat.com/hydra/rest/securitydata'

# Terminal color codes for clear messaging
class Colors:
    RED = "\033[1;31m"
    GREEN = "\033[1;32m"
    BLUE = "\033[1;34m"
    RESET = "\033[0m"

def print_step(message):
    print(f"{Colors.BLUE}==>{Colors.RESET} {message}")

def print_error(message):
    print(f"{Colors.RED}[ERROR]{Colors.RESET} {message}")

# Step 1: Input Validation
def validate_inputs():
    if len(sys.argv) != 3:
        print_error("Both $1 and $2 must be defined.")
        sys.exit(1)

# Step 2: Connection Verification
def verify_connection(hosts_file):
    responsive_hosts = []
    with open(hosts_file, 'r') as file:
        hosts = file.readlines()

    for host in hosts:
        host = host.strip()
        try:
            # Try connecting to port 22 for SSH
            socket.create_connection((host, 22), timeout=5)
            responsive_hosts.append(host)
        except Exception as e:
            print(f"{host} - CONNECTION ERROR - [{str(e)}]")

    return responsive_hosts

# Step 3: Gather CVE Information
# In this example, we're mimicking the process by just fetching RHSA advisories related to the kernel.
def gather_cve_info_from_redhat():
    endpoint = '/cvrf.json'
    params = 'package=kernel'
    response = requests.get(API_HOST + endpoint, params=params)
    
    if response.status_code != 200:
        print_error(f"Failed to fetch CVE data. Server responded with {response.status_code}")
        sys.exit(1)
    
    cve_data = response.json()
    return cve_data

def main():
    print_step("Validating Inputs")
    validate_inputs()

    print_step("Verifying Connection to Hosts")
    responsive_hosts = verify_connection(sys.argv[1])
    print(f"Responsive Hosts: {', '.join(responsive_hosts)}")

    print_step("Gathering CVE Information from Red Hat")
    cve_data = gather_cve_info_from_redhat()
    # Just a basic print to verify the data; this will be processed further in upcoming steps
    for entry in cve_data:
        print(f"{entry['RHSA']} - {entry['severity']}")

if __name__ == "__main__":
    main()
