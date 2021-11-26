# kubernetes

All necessary files to deploy Kiebitz in Kubernetes

# Configuration

Create a [configMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) with the content of the `kiebitz/services/settings/dev` directory

```bash

kubectl create configmap kiebitz-dev --from-file=001_default.yml --from-file=002_admin.json --from-file=003_appt.json --from-file=004_notification.json

```