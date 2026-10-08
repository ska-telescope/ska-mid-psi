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

Monitor via `k9s` the `ska-tango-archiver` namespace to check that the following pods have been deployed/updated:

```
kubectl get pods -n ska-tango-archiver

NAME                                                   READY   STATUS    RESTARTS   AGE
archviewer-ska-tango-archiver-test-56dbf6bcbf-q549d    1/1     Running   0          17d
archwizard-ska-tango-archiver-test-77bf86fd-nkjqm      1/1     Running   0          17d
configurator-ska-tango-archiver-test-85554b8b6-kfd4m   1/1     Running   0          17d
databaseds-ds-databaseds-tango-base-0                  1/1     Running   0          32m
databaseds-tangodb-databaseds-tango-base-0             1/1     Running   0          32m
ds-archiver-cm-01-0                                    1/1     Running   0          32m
ds-archiver-cm-02-0                                    1/1     Running   0          32m
ds-archiver-es-01-0                                    1/1     Running   0          32m
ds-archiver-es-02-0                                    1/1     Running   0          32m
ds-tangotest-test-0                                    1/1     Running   0          32m

kubectl get svc -n ska-tango-archiver

NAME                                       TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                                           AGE
archviewer                                 LoadBalancer   10.99.223.0      192.168.128.18   8082:31794/TCP                                    121d
archwizard                                 LoadBalancer   10.104.206.47    192.168.128.20   8000:32513/TCP                                    121d
configurator                               LoadBalancer   10.100.2.82      192.168.128.11   8003:31688/TCP                                    121d
databaseds-tango-base                      LoadBalancer   10.107.226.189   192.168.128.94   10000:30960/TCP                                   32m
databaseds-tangodb-databaseds-tango-base   ClusterIP      10.108.45.67     <none>           3306/TCP                                          33m
ds-archiver-cm-01                          LoadBalancer   10.99.112.105    192.168.128.95   45450:31933/TCP,45460:30664/TCP,45470:32666/TCP   32m
ds-archiver-cm-02                          LoadBalancer   10.100.152.160   192.168.128.97   45450:31806/TCP,45460:31859/TCP,45470:30362/TCP   32m
ds-archiver-es-01                          LoadBalancer   10.97.176.111    192.168.128.96   45450:32562/TCP,45460:31938/TCP,45470:32499/TCP   32m
ds-archiver-es-02                          LoadBalancer   10.107.10.68     192.168.128.98   45450:30689/TCP,45460:30200/TCP,45470:31882/TCP   32m
ds-tangotest-test                          LoadBalancer   10.110.220.243   192.168.128.99   45450:32510/TCP,45460:30728/TCP,45470:31333/TCP   32m

```


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

NAME                                           CLASS   HOSTS                   ADDRESS         PORTS     AGE
archviewer-ingress-ska-tango-archiver-test     nginx   rmdskadevdu011.mda.ca   10.103.140.27   80, 443   28m
archwizard-ingress-ska-tango-archiver-test     nginx   rmdskadevdu011.mda.ca   10.103.140.27   80, 443   28m
configurator-ingress-ska-tango-archiver-test   nginx   rmdskadevdu011.mda.ca   10.103.140.27   80, 443   28m

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