# Installing system-tests artifacts resources in the MID PSI

# Files
- system-tests-pvc.yaml: This yaml defines the persistant volume claim for the artifacts which includes the storage size specification
- system-tests-sts.yaml: This yaml defines the statefulset in the namespace which allows for a pod to always be running which uses the PVC. This means that testers can navigate the artifacts through this pod or can use it to copy files out to their local environment.

## One time only process to create the namespace
`kubectl create namespace system-tests-artifacts`

## Create the resources
1. Create the PVC within the dedicated namespace using the command: `kubectl apply -f system-tests-pvc-yaml -n system-tests-artifacts`
2. Create the statefulset within the dedicated namespace using the command: `kubectl apply -f system-tests-sts.yaml -n system-tests-artifacts`

## Delete the resources
1. Delete the PVC within the dedicated namespace using the command: `kubectl delete pvc system-tests-pvc -n system-tests-artifacts`
2. Delete the statefulset within the dedicated namespace using the command: `kubectl delete sts artifacts-sts -n system-tests-artifacts`

## Updating the storage capacity
1. Delete statefulset using the command provided above
2. Delete the PVC using the command provided above
3. Update the value `storage` in the system-tests-pvc.yaml file
4. Create the PVC using the command provided above
5. Create the statefulset using the command provided above
