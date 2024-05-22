#!/bin/bash

# Function to display usage
usage() {
    echo -e "\nUsage: $0 -n <KUBE_NAMESPACE> [-f <CONFIG_FILE> ...] -a <ACTION>"
    echo "  where ACTION can be either 'add_update' or 'remove'"
    echo -e "\nIf no template files are provided, 'default.yaml' will be used by default.\n"
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

CONFIG_FILES=()

# Parse command-line arguments
while getopts "n:f:a:" opt; do
    case ${opt} in
        n)
            KUBE_NAMESPACE=${OPTARG}
            ;;
        f)
            CONFIG_FILES+=("${OPTARG}")
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

# If no template files are provided, use the default template file
if [ ${#CONFIG_FILES[@]} -eq 0 ]; then
    CONFIG_FILES=("archiver/default.yaml")
fi

# Check if action is provided and valid
if [ -z "${ACTION}" ]; then
    usage
elif [[  "${ACTION}" != "add_update" && "${ACTION}" != "remove" ]]; then
    echo "Aborting due to invalid action: ${ACTION}"
    usage
fi

# Define variables
configurator_ip=$(kubectl get svc -n $KUBE_NAMESPACE | grep configurator | awk '{print $4}')
if [  "${ACTION}" == "add_update" ]; then
    action_str="\nLoading the following configuration into the Configurator:\n"
else
    action_str="\nRemoving the following configuration from the Configurator:\n"
fi

# Display namespace, config files
echo -e "\nUsing Kubernetes Namespace: $KUBE_NAMESPACE"
echo "Using Archive Configuration Files: ${CONFIG_FILES[*]}"

temp_config_file="archiver/temp_config.yaml"
for file in "${CONFIG_FILES[@]}"; do 

    # Copy config file to a temp file and replace the {{Release.Namespace}} with the actual namespace
    cat $file | sed -e "s/{{Release.Namespace}}/$KUBE_NAMESPACE/" > $temp_config_file
    echo -e $action_str
    cat $temp_config_file

    # Load in the config file to the Configurator via its external IP
    echo -e "\nExecuting:"
    echo -e "curl -X \"POST\" \"http://$configurator_ip:8003/configure-archiver\" $headers -F \"file=@$temp_config_file;type=application/x-yaml\" -F \"option=$ACTION\"\n"
    curl -X "POST" "http://$configurator_ip:8003/configure-archiver" $headers -F "file=@$temp_config_file;type=application/x-yaml" -F "option=$ACTION"
    echo ""
done

# Clean up temp file
rm $temp_config_file
echo -e "\nDeleted $temp_config_file\n"
