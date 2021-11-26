# Development setup in Minikube

##  Minikube
Install [Minikube](https://kubernetes.io/de/docs/setup/minikube/)

## Minikube Docker driver

The setup has been tested with the [Docker driver](https://minikube.sigs.k8s.io/docs/drivers/docker/)

## Minikube registry
Enable the registry and start the local internal registry

```bash

minikube enable registry

```

## Connect with Socat

Enable the `socat` container for access from outside Minikube

```bash

docker run --rm -d --name socat --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"

```

tag you container 

```bash

docker tag kiebitz localhost:5000/kiebitz
``` 

and push it into the minikube internal registry 

```bash

docker push localhost:5000/kiebitz

```
