#! /bin/bash

# Script to find, package, and download measurement data from a namespace. Should be run after endscan command has completed, but before end command sent.

cat << "EOF"
   _____ ____  ____     ____        __           ______     __                  __            
  / ___// __ \/ __ \   / __ \____ _/ /_____ _   / ____/  __/ /__________ ______/ /_____  _____
  \__ \/ / / / /_/ /  / / / / __ `/ __/ __ `/  / __/ | |/_/ __/ ___/ __ `/ ___/ __/ __ \/ ___/
 ___/ / /_/ / ____/  / /_/ / /_/ / /_/ /_/ /  / /____>  </ /_/ /  / /_/ / /__/ /_/ /_/ / /    
/____/_____/_/      /_____/\__,_/\__/\__,_/  /_____/_/|_|\__/_/   \__,_/\___/\__/\____/_/     
                                                                                              
EOF
printf "\n\nCurrently deployed namespaces:"
printf "\n...\n"
kubectl get ns | grep "sdp"
printf "...\n"
read -p "Enter SDP namespace:" ns 

printf "* getting container..."

pod="$(kubectl get pods -n $ns | grep "vis-receive" | grep -o '^\S*')"

printf "$pod"

container="mswriter-processor"
printf "☑\n"
printf "* getting directory...\n"
printf "Execution blocks:\n...\n"
kubectl exec -it -n $ns $pod --container mswriter-processor -- ls /data/product
printf "...\n"
read -p "enter exec block:" eb

printf "Processing blocks:\n...\n"
kubectl exec -it -n $ns $pod --container mswriter-processor -- ls /data/product/$eb/ska-sdp
printf "...\n"
read -p "enter processing block:" pb

kubectl exec -it -n $ns $pod --container mswriter-processor -- tar -czvf output-archive.tgz /data/product/$eb/ska-sdp/$pb/output.scan-1.ms
printf "Done getting directory, compressing and copying to local machine\n"
kubectl cp $ns/$pod:/output-archive.tgz -c mswriter-processor measurement-data-output-$eb-$pb.tgz
printf "Done!/n"