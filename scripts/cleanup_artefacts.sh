#!/bin/bash

# Script to clean up the system-tests artifacts PVC of folders older than N days
#
# Usage:
# ./cleanup_artifacts.sh N
#
# where N is a postive integer number of days greater than 7

# Default number of days old, if not provided otherwise
DEFAULT_DAYS_OLD=14

NAMESPACE="system-tests-artifacts"
POD_NAME="artifacts-sts-0"
ARTIFACTS_FOLDER="/app/artifacts"

FORMAT='+%Y-%m-%d %H:%M:%S'

# Check if number of days old is provided as a command line argument
if [ -z "$1" ]; then
    DAYS_OLD=$DEFAULT_DAYS_OLD
else
    DAYS_OLD=$1
fi

# Ensure DAYS_OLD is postive number and greater than 7 (to prevent accidental deletion of everything)
if [ "$DAYS_OLD" -le 7 ]; then
    echo "Error: Number of days must be greater than 7 (to prevent accidentaly delection of everything)."
    exit 1
fi

FIND_CMD="find $ARTIFACTS_FOLDER -type d -mtime +$DAYS_OLD"

echo "========================================================================================="
echo "$(date "$FORMAT") - Executing cleanup command on folders older than $DAYS_OLD days old..."

OLD_DIRECTORIES=$(kubectl exec -n "$NAMESPACE" "$POD_NAME" -- bash -c "$FIND_CMD")

# Check if any directories older than $DAYS_OLD are found
if [ -z "$OLD_DIRECTORIES" ]; then  
    echo "$(date "$FORMAT") - Nothing to delete"
else
    echo -e "$(date "$FORMAT") - Deleting...\n"
    kubectl exec -n "$NAMESPACE" "$POD_NAME" -- bash -c "$FIND_CMD"
    # kubectl exec -n "$NAMESPACE" "$POD_NAME" -- bash -c "$FIND_CMD -exec rm -rf {} +"
    echo ""

    # Check if the deletion was successful
    if [ $? -eq 0 ]; then
        echo "$(date "$FORMAT") - Cleanup completed successfully"
    else
        echo "$(date "$FORMAT") - An error occurred during the cleanup process."
    fi
fi