#!/bin/bash

CSV_FILE="/root/user_credentials.csv"
OCC="/var/www/owncloud/occ"

SUCCESS_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0

echo "========================================="
echo "Starting OwnCloud User Provisioning"
echo "========================================="

# Check CSV exists
if [ ! -f "$CSV_FILE" ]; then
    echo "ERROR: CSV file not found."
    exit 1
fi

# Check occ exists
if [ ! -f "$OCC" ]; then
    echo "ERROR: occ command not found at $OCC"
    exit 1
fi

# Read CSV file
while IFS=',' read -r username password
do
    # Skip header row
    if [ "$username" = "username" ]; then
        continue
    fi

    echo ""
    echo "Processing user: $username"

    # Check if user already exists
    sudo -u www-data php "$OCC" user:info "$username" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "WARNING: User $username already exists. Skipping."
        ((SKIPPED_COUNT++))
        continue
    fi

    # Create OwnCloud user
sudo -u www-data env OC_PASS="$password" php "$OCC" user:add \
    --password-from-env \
    "$username"

# Check command result
if [ $? -eq 0 ]; then
    echo "SUCCESS: User $username created."
    ((SUCCESS_COUNT++))
else
    echo "ERROR: Failed to create user $username"
    ((FAILED_COUNT++))
    continue
fi


    if [ $? -eq 0 ]; then
        echo "SUCCESS: Password reset enabled for $username"
    else
        echo "WARNING: Could not enable password reset for $username"
    fi

    ((SUCCESS_COUNT++))

done < "$CSV_FILE"
