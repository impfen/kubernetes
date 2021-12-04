
# __Moved to [Impfterm-In](https://github.com/impfterm-in/kubernetes)__

# Kubernetes deployment of kiebitz

## Content

- in charts/kiebitz you find an working Helm chart. It is has been created by `helm init`. Some of the templates may be not functional
- in container/kiebitz there is a Dockerfile creating a Kiebitz image from scratch
- EXAMPLE.md contains an example session how to install Kiebitz with a Redis database
- LICENSE contains the text of the AGPL license
- MINIKUBE.md is a description to setup Minikube for running Kiebitz locally
- settings/dev contains a setup suitable for local testing

## Directory tree

```
.
├── charts
│   └── kiebitz
│       ├── charts
│       ├── Chart.yaml
│       ├── templates
│       │   ├── deployment.yaml
│       │   ├── _helpers.tpl
│       │   ├── hpa.yaml
│       │   ├── ingress.yaml
│       │   ├── NOTES.txt
│       │   ├── serviceaccount.yaml
│       │   ├── service.yaml
│       │   └── tests
│       │       └── test-connection.yaml
│       └── values.yaml
├── container
│   └── kiebitz
│       └── Dockerfile
├── EXAMPLE.md
├── LICENSE
├── MINIKUBE.md
├── README.md
└── settings
    └── dev
        ├── 001_default.yml
        ├── 002_admin.json
        ├── 003_appt.json
        └── 004_notification.json
```
