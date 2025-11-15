# Vault Installation Steps in the MID PSI

## Create the Vault namespace

`kubectl create namespace vault` 

## Set up Vault

These instructions were taken from the Vault Tutorial: https://developer.skao.int/en/latest/tutorial/vault.html#deploy-the-vault-secrets-operator

1. Clone the CICD Deploy Minikube repository: `git clone https://gitlab.com/ska-telescope/sdi/ska-cicd-deploy-minikube.git`
2. Navigate to the cloned repo
3. Deploy Vault: `make vault-deploy`
4. Set up port forwarding: `make vault-port-forward`
5. Get the External-IP of Vault UI: `kubectl get svc vault-ui -n vault`
6. Set the VAULT_ADDRESS: `export VAULT_ADDRESS="http://<Vault-UI External-IP>:8200"`
7. Create kv-v2 engine: 
   ```
   eval $(make vault-cli-config)
   vault secrets enable -path=kv-v2 kv-v2 VAULT_ADDRESS=$VAULT_ADDRESS
   ```
8. Check that the new kv-v2 engine is listed: `vault secrets list`
9. Insert some Secrets into Vault and verify they exist:
   ```
   vault kv put -mount=kv-v2 secret/oda ADMIN_POSTGRES_PASSWORD="localpassword"
   vault kv get kv-v2/secret/oda
   vault kv put -mount=kv-v2 secret/sdp/qa REACT_APP_MSENTRA_TENANT_ID="1111" REACT_APP_MSENTRA_CLIENT_ID="1234"
   vault kv get kv-v2/secret/sdp/qa
   ```

### Integrate Vault with Kubernetes Cluster

The command used in the CICD Deploy Minikube repository that integrates Vault with the Kubernetes Cluster uses whatever is set as the $PROFILE as the Kube Context. By default this is minikube. To get this command to work with the Kubernetes Cluster, either update $PROFILE to point to the cluster's context or remove all the references to `--context $(PROFILE)` inside the `make vault-k8s-integration` command first.

Then run the command:
`make vault-k8s-integration VAULT_ADDRESS=$VAULT_ADDRESS`

### Verify the K8sPolicy

```
eval $(make vault-cli-config)
vault policy read k8spolicy
```

### Deploy the VaultSecretsOperator (VSO)

```
make vault-deploy-secrets-operator VAULT_ADDRESS=$VAULT_ADDRESS
kubectl get vaultconnection default -n vault -o jsonpath='{.status}'
kubectl get vaultauth default -n vault -o jsonpath='{.status}'
```

### Check the ska-sdp-qa-secret in a deployed namespace

`kubectl get vaultstaticsecret ska-sdp-qa-secret -n <namespace> -o yaml`
   

