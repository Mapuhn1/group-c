#!/bin/bash
#
# Usage: rsync-to-backup.sh job 
#

# --- Arguments ---
job="$1"
shift
sources="$@"

if [ -z "$job" ] || [ -z "$sources" ]; then
    echo "Usage: $0 <job-name> <source-path>..."
    exit 1
fi

# --- Timestamp ---
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# --- Destination path ---
host=$(hostname)
dest="/home/backup/${host}/${job}/${timestamp}"

# --- Create destination directory ---
ssh -i /root/.ssh/id_ed25519_backup backup@backup-c "mkdir -p ${dest}"

# --- Rsync ---
rsync -avz --delete --numeric-ids \
    --link-dest="/home/backup/${host}/${job}/current" \
    -e "ssh -i /root/.ssh/id_ed25519_backup" \
    $sources "backup@backup-c:${dest}/"

exitcode=$?

if [ $exitcode -eq 0 ]; then
    ssh -i /root/.ssh/id_ed25519_backup backup@backup-c "
        cd /home/backup/${host}/${job} &&
        rm -f current &&
        ln -s ${timestamp} current
    "
else
    logger -t backup "${job} FAILED with exit code ${exitcode}, current symlink not updated"
fi

exit $exitcode
