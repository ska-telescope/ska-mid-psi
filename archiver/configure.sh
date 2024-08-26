#!/bin/bash

# Function to display usage
usage() {
    echo -e "\nUsage: $0 -n <KUBE_NAMESPACE> -a <ACTION> [-f <ARCHIVE_CONFIG>]\n"
    echo "where ACTION can be 'add_update' to add/update attributes for archiving,"
    echo "                    'remove' to remove attributes from archiving, or"
    echo "                     'get' to get the list of attributes currently being archived."
    echo -e "\nIf no config file is provided, 'default.yaml' will be used by default.\n"
    exit 1
}

# Function to check if namespace is active
check_namespace() {
    status=$(kubectl get namespace $KUBE_NAMESPACE -o jsonpath='{.status.phase}')

    if [ "$status" != "Active" ]; then
        echo -e "\nAborting script: the namespace $KUBE_NAMESPACE is not active"
        exit 1
    fi
}

# Function to check if the configurator svc is running and get its IP
configurator_deployed() {
    configurator_ip=$(kubectl get svc -n $KUBE_NAMESPACE | grep configurator | awk '{print $4}')

    if [ -z "${configurator_ip}" ]; then
        false
    else
        true
    fi
}

# Function to get the attributes that have been archived, for a particular namespace $KUBE_NAMESPACE,
# which corresponds to the configurator_ip.
#
# If $OUTPUT_FILE is set, the curl command will write the output to a file with that name.
# Otherwise it will display to stdout.
get_attributes() {

    local output_file="${1:-$OUTPUT_FILE}"

    echo -e "output_file = $output_file\n"

    if configurator_deployed; then
        if [ -n "$output_file" ]; then
            curl -X "GET" "http://$configurator_ip:8003/download-configuration/?eventsubscriber=mid-eda%2Fes%2F01" \
                -H "accept: application/json" -o "$output_file"
        else
            echo "echoing to stdout"
            curl -X "GET" "http://$configurator_ip:8003/download-configuration/?eventsubscriber=mid-eda%2Fes%2F01" \
                -H "accept: application/json"
        fi
    else
        echo -e "\nThe Configurator pod is not deployed"
    fi
}

# Clean up temp file
clean_up(){
    if [ -n "$temp_config_file" ]; then
        rm $temp_config_file
        echo -e "\nDeleted $temp_config_file\n"
    fi
}

# Function to add/remove attributes to/from archiving, for a particular namespace $KUBE_NAMESPACE,
# which corresponds to the configurator_ip.
#
# If $OUTPUT_FILE is set, the get_attributes function is executed first to extract all the attributes that are 
# currently loaded in and save that to a file with that name, and then remove all those attributes.
# Otherwise it will remove only the attributes listed in the $ARCHIVE_CONFIG.
#
# In either case, need to first check that there are attributes loaded in the EDA before trying to remove them.
add_remove_attributes(){

    if configurator_deployed; then

        if [ $ACTION == "remove" ]; then

            if [ -n "$OUTPUT_FILE" ]; then
                # use the $OUTPUT_FILE as the temp filename variable
                temp_config_file=$OUTPUT_FILE
            else
                # otherwise set a temp file name so that checking can be done anyways
                temp_config_file="temp_file.yaml"
            fi

            # check what attributes are loaded
            get_attributes $temp_config_file

            # search string to look for that indicates no attributes are loaded
            no_attributes_found_str="no attributes are archived"

            # Check first to make sure there are attributes loaded in the EDA
            if grep -q "$no_attributes_found_str" $temp_config_file; then
                # if not, clean up and exit
                echo -e "\nNo attributes are archived, so there is nothing to remove.\n"
                clean_up
                exit
            else
                # otherwise, update the manager to be "mid-eda/cm/01". this will be used later to remove the loaded attributes.
                echo -e "Updating the manager in the $temp_config_file" 
                sed -i -e "s/'...'/mid-eda\/cm\/01/" $temp_config_file
            fi

        else
            # set a temp copy of the $ARCHIVE_CONFIG file as the temp filename variable
            # so that the kube namespace can be updated in the next step
            # without modifying the original that gets CM'd in Git
            temp_config_file=$ARCHIVE_CONFIG.temp

            # Using the $ARCHIVE_CONFIG FILE, replace the {{Release.Namespace}} with the actual namespace and save output to $temp_config_file
            cat $ARCHIVE_CONFIG | sed -e "s/{{Release.Namespace}}/$KUBE_NAMESPACE/" > $temp_config_file
        fi

        # Load in the temp config file to the Configurator via its external IP
        echo -e "$action_str"
        echo -e "curl -X \"POST\" \"http://$configurator_ip:8003/configure-archiver\" -F \"file=@$temp_config_file;type=application/x-yaml\" -F \"option=$ACTION\"\n"
        echo ""
        curl -X "POST" "http://$configurator_ip:8003/configure-archiver" -F "file=@$temp_config_file;type=application/x-yaml" -F "option=$ACTION"
        echo ""

        clean_up
    else
        echo -e "\nThe Configurator pod is not deployed."
    fi
}

# Parse command-line arguments
while getopts "n:a:f:o:" opt; do
    case ${opt} in
        n)
            KUBE_NAMESPACE=${OPTARG}
            ;;
        a)
            ACTION=${OPTARG}
            ;;
        f)
            ARCHIVE_CONFIG=${OPTARG}
            ;;
        o)
            OUTPUT_FILE=${OPTARG}
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
check_namespace

# If no config file is provided, use the default file
if [ -z "${ARCHIVE_CONFIG}" ]; then
    ARCHIVE_CONFIG="archiver/default.yaml"
fi

# Check if action is provided and valid
if [ -z "${ACTION}" ]; then
    usage
elif [[  "${ACTION}" != "add_update" && "${ACTION}" != "remove" && "${ACTION}" != "get" ]]; then
    echo "Aborting due to invalid action: ${ACTION}"
    usage
fi

# Display namespace, config files
echo -e "\nUsing Kubernetes Namespace: $KUBE_NAMESPACE"

# Add/Remove/Get attributes
if [  "${ACTION}" == "add_update" ]; then
    action_str="\nLoading attributes into the Configurator:\n"
    add_remove_attributes
elif [  "${ACTION}" == "remove" ]; then
    action_str="\nRemoving the attributes from the Configurator:\n"
    add_remove_attributes
else
    echo -e "\nRetrieving the list of attributes being archived:\n"
    get_attributes
fi
