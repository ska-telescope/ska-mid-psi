# Updating the EDA charts in the MID PSI

The EDA (ska-tango-archiver) resides in a separate chart within the ska-mid-psi repository, in the `charts/ska-mid-psi-archiver` folder.

To deploy a new EDA, execute the following steps manually in the Mid PSI environment.

## 1. Update the version in the Charts

Navigate to `charts/ska-mid-psi-archiver` and update the version in `Chart.yaml` as well as any values that might need to be changed in `values.yaml`. The rest of the steps are executed within this folder.


## 2. Update Helm dependencies

Run the following commands to first delete the Chart.lock file and then update the helm dependencies.

```
rm Chart.lock
helm dependency build
```

## 3. Deploy new EDA version 

```
helm upgrade --install test . --namespace ska-tango-archiver
```
where `test` is the name of the release

Monitor via `k9s` the `ska-tango-archiver` namespace to check that the pods have been updated.

## 4. Update the Ingresses

Each of the GUIs have ingresses, however these ingresses don't currently support TLS. They need to first be deleted and then create new ones that do support TLS.

First examine what ingresses are existing. The expected output is shown below:
```
kubectl get ingress -n ska-tango-archiver

NAME                                           CLASS   HOSTS   ADDRESS         PORTS     AGE
archviewer-ingress-ska-tango-archiver-test     nginx   *       10.103.140.27   80        5m
archwizard-ingress-ska-tango-archiver-test     nginx   *       10.103.140.27   80        5m
configurator-ingress-ska-tango-archiver-test   nginx   *       10.103.140.27   80        5m
```

Then delete each ingress:
```
kubectl delete ingress <ingress name> -n ska-tango-archiver 
```

Then create the new ingresses:
```
kubectl apply -n ska-tango-archiver -f data/archviewer-ingress.yaml
kubectl apply -n ska-tango-archiver -f data/archwizard-ingress.yaml
kubectl apply -n ska-tango-archiver -f data/configurator-ingress.yaml
```

Verify that the ingresses have been updated. The expected output is shown below as well.

```
kubectl get ingress -n ska-tango-archiver

NAME                                           CLASS   HOSTS                    ADDRESS         PORTS     AGE
archviewer-ingress-ska-tango-archiver-test     nginx   rmdskadevdu011.mda.ca    10.103.140.27   80        10s
archwizard-ingress-ska-tango-archiver-test     nginx   rmdskadevdu011.mda.ca    10.103.140.27   80        10s
configurator-ingress-ska-tango-archiver-test   nginx   rmdskadevdu011.mda.ca    10.103.140.27   80        10s
```

## 5. Verify that the Secret and VaultStaticSecret is Setup

Expected output is shown below:
```
kubectl get secret,vaultstaticsecret -n ska-tango-archiver

NAME                                TYPE                 DATA   AGE
secret/archiver-cm-production-eda   Opaque               5      5m
secret/archiver-es-production-eda   Opaque               5      5m
secret/db-secret                    Opaque               5      5m
secret/sh.helm.release.v1.test.v1   helm.sh/release.v1   1      5m
secret/ssl-cert                     kubernetes.io/tls    3      5m

NAME                                                                 AGE
vaultstaticsecret.secrets.hashicorp.com/archiver-cm-production-eda   5m
vaultstaticsecret.secrets.hashicorp.com/archiver-es-production-eda   5m
vaultstaticsecret.secrets.hashicorp.com/db-secret                    5m
vaultstaticsecret.secrets.hashicorp.com/ssl-cert-holder              5m
```