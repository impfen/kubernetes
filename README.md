# kubernetes

All necessary files to deploy Kiebitz in Kubernetes

# Configuration

Create a [configMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) with the content of the `kiebitz/services/settings/dev` directory

```bash

cd charts/kiebitz

```

adapt the configuration files and use `helm` to install

```bash

helm install mykiebitz .

```