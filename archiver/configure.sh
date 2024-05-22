#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -n <KUBE_NAMESPACE> -f <ARCHIVE_CONFIG_FILE> [-f <ARCHIVE_CONFIG_FILE> ...] -a <ACTION>"
    echo "ACTION can be either 'add_update' or 'remove'"
    exit 1
}

# Function to check if namespace is active
check_namespace() {
    local namespace=$1
    status=$(kubectl get namespace $namespace -o jsonpath='{.status.phase}')

    if [ "$status" != "Active" ]; then
        echo -e "\nAborting script: the namespace $namespace is not active"
        exit 1
    fi
}

ARCHIVE_CONFIG_FILES=()

# Parse command-line arguments
while getopts "n:f:a:" opt; do
    case ${opt} in
        n)
            KUBE_NAMESPACE=${OPTARG}
            ;;
        f)
            ARCHIVE_CONFIG_FILES+=("${OPTARG}")
            ;;
        a)
            ACTION=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

# Check if namespace is provided
if [ -z "${KUBE_NAMESPACE}" ]; then
    usage
fi

# Check that the namespace is active
check_namespace $KUBE_NAMESPACE

# Check if at least one archive config file is provided
if [ ${#ARCHIVE_CONFIG_FILES[@]} -eq 0 ]; then
    usage
fi

# Check if action is provided and valid
if [ -z "${ACTION}" ]; then
    usage
elif [[  "${ACTION}" != "add_update" && "${ACTION}" != "remove" ]]; then
    echo "Aborting due to invalid action: ${ACTION}"
    usage
fi


# Define variables
headers=""
#headers="-H 'accept: application/json' -H 'Content-Type: multipart/form-data'"
configurator_ip=$(kubectl get svc -n $KUBE_NAMESPACE | grep configurator | awk '{print $4}')
if [  "${ACTION}" == "add_update" ]; then
    action_str="\nLoading the following configuration into the Configurator:\n"
else
    action_str="\nRemoving the following configuration from the Configurator:\n"
fi

# Display namespace and config filename
echo -e "\nUsing Kubernetes Namespace: $KUBE_NAMESPACE"
echo "Using Archive Configuration Files: ${ARCHIVE_CONFIG_FILES[*]}"

for file in "${ARCHIVE_CONFIG_FILES[@]}"; do 
    temp_config_file=temp_$file

    # Copy config file to a temp file and replace the {{Release.Namespace}} with the actual namespace
    cat $file | sed -e "s/{{Release.Namespace}}/$KUBE_NAMESPACE/" > $temp_config_file
    echo -e $action_str
    cat $temp_config_file

    # Load in the config file to the Configurator via its external IP
    echo -e "\nExecuting:"
    echo "curl -X \"POST\" \"http://$configurator_ip:8003/configure-archiver\" $headers -F \"file=@$temp_config_file;type=application/x-yaml\" -F \"option=$ACTION\""
    curl -X "POST" "http://$configurator_ip:8003/configure-archiver" $headers -F "file=@$temp_config_file;type=application/x-yaml" -F "option=$ACTION"

    # Clean up temp file
    # echo -e "\nDeleting $temp_config_file..."
    # rm $temp_config_file
    echo ""
done

# if [ $? -ne 0 ]; then
#     echo -e "Action \"$ACTION\" failed.\n"
#     exit 1
# else
#     echo -e "Action \"$ACTION\" succeeded.\n"
# fi