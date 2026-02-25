
#!/bin/bash
set -euo pipefail

newhostname=$1

# Rename the host with the new hostname
sudo hostnamectl set-hostname $newhostname && echo "Hostname changed succesfully" || echo "Failed to change hostname"

# Verify the change
hostname

# Ping the new hostname
ping -c 4 $(hostname)
