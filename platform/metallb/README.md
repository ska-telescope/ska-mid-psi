# Metallb Installation Steps in the MID PSI

## Uninstall existing metallb helm install

1. List helm install in the metallb namespace using the command: `helm list -n metallb`
2. Grab the name of the helm install from the output of the previous command
3. Uninstall the helm deployment using the command: `helm uninstall <name> -n metallb`

## Install new metallb helm deployment
1. Run the following command to add the metallb helm repo: `helm repo add metallb https://metallb.github.io/metallb`
2. Update the helm repo: `helm repo update`
3. Install the metallb helm deployment to the metallb namespace with default configuration: `helm install metallb metallb/metallb -n metallb`
4. Update the configuration of the deployment by applying the 2 values files: `kubectl apply -f metallb-ip-pool.yml -n metallb` and `kubectl apply -f metallb-l2.yaml -n metallb` 
