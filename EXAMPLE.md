# Kiebitz installation

This installation recipe is using two redis databases `meter` and `db`.

Redis images are based on Alpine, the Kiebitz image is using a standalone statically linked image  _FROM SCRATCH_ 
without any operating systems inside.

Alpine uses no glibc and no bash.


```bash
cd import/kiebitz/kubernetes
```

    /home/thomas/import/kiebitz/kubernetes



```bash
tree 
```

    .
    ├── charts
    │   └── kiebitz
    │       ├── 001_default.yml
    │       ├── 002_admin.json
    │       ├── 003_appt.json
    │       ├── 004_notification.json
    │       ├── charts
    │       ├── Chart.yaml
    │       ├── settings
    │       ├── templates
    │       │   ├── configmap.yaml
    │       │   ├── deployment.yaml
    │       │   ├── _helpers.tpl
    │       │   ├── hpa.yaml
    │       │   ├── ingress.yaml
    │       │   ├── NOTES.txt
    │       │   ├── serviceaccount.yaml
    │       │   ├── service.yaml
    │       │   └── tests
    │       │       └── test-connection.yaml
    │       └── values.yaml
    ├── container
    │   └── kiebitz
    │       └── Dockerfile
    ├── EXAMPLE.md
    ├── LICENSE
    ├── MINIKUBE.md
    └── README.md
    
    8 directories, 20 files



```bash
KIEBITZ=kiebitz
REGISTRY=localhost:5000
```


```bash
kubectl create namespace $KIEBITZ
```

    namespace/kiebitz created



```bash
kubectl config set-context --current --namespace=$KIEBITZ
```

    Context "minikube" modified.



```bash
kubectl get all
```

    No resources found in kiebitz namespace.


### Install the dandydev repo


```bash
helm repo add dandydev https://dandydeveloper.github.io/charts
```

    "dandydev" has been added to your repositories


### Install the `meter` database

Adapt the `replicas` parameter to your cluster size. With a single node `minikube` cluster 1 is a good choice. 


```bash
helm install meter --set replicas=1 dandydev/redis-ha
```

    NAME: meter
    LAST DEPLOYED: Sat Nov 27 16:29:24 2021
    NAMESPACE: kiebitz
    STATUS: deployed
    REVISION: 1
    NOTES:
    Redis can be accessed via port 6379   and Sentinel can be accessed via port 26379    on the following DNS name from within your cluster:
    meter-redis-ha.kiebitz.svc.cluster.local
    
    To connect to your Redis server:
    1. Run a Redis pod that you can use as a client:
    
       kubectl exec -it meter-redis-ha-server-0 sh -n kiebitz
    
    2. Connect using the Redis CLI:
    
      redis-cli -h meter-redis-ha.kiebitz.svc.cluster.local



```bash
helm ls
```

    NAME 	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART          	APP VERSION
    meter	kiebitz  	1       	2021-11-27 16:29:24.917863849 +0100 CET	deployed	redis-ha-4.14.7	6.2.5      


### Check if all is running, this can take a few minutes


```bash
kubectl get all
```

    NAME                          READY   STATUS        RESTARTS   AGE
    pod/meter-redis-ha-server-0   3/3     Running       0          92s
    
    NAME                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)              AGE
    service/meter-redis-ha              ClusterIP   None            <none>        6379/TCP,26379/TCP   97s
    service/meter-redis-ha-announce-0   ClusterIP   10.100.34.127   <none>        6379/TCP,26379/TCP   97s
    
    NAME                                     READY   AGE
    statefulset.apps/meter-redis-ha-server   1/1     97s


### same procedure with the `db` database


```bash
helm install db --set replicas=1 dandydev/redis-ha
```

    NAME: db
    LAST DEPLOYED: Sat Nov 27 16:31:21 2021
    NAMESPACE: kiebitz
    STATUS: deployed
    REVISION: 1
    NOTES:
    Redis can be accessed via port 6379   and Sentinel can be accessed via port 26379    on the following DNS name from within your cluster:
    db-redis-ha.kiebitz.svc.cluster.local
    
    To connect to your Redis server:
    1. Run a Redis pod that you can use as a client:
    
       kubectl exec -it db-redis-ha-server-0 sh -n kiebitz
    
    2. Connect using the Redis CLI:
    
      redis-cli -h db-redis-ha.kiebitz.svc.cluster.local



```bash
kubectl get all 
```

    NAME                          READY   STATUS    RESTARTS   AGE
    pod/db-redis-ha-server-0      3/3     Running   0          77s
    pod/meter-redis-ha-server-0   3/3     Running   0          3m29s
    
    NAME                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)              AGE
    service/db-redis-ha                 ClusterIP   None            <none>        6379/TCP,26379/TCP   97s
    service/db-redis-ha-announce-0      ClusterIP   10.102.144.45   <none>        6379/TCP,26379/TCP   97s
    service/meter-redis-ha              ClusterIP   None            <none>        6379/TCP,26379/TCP   3m34s
    service/meter-redis-ha-announce-0   ClusterIP   10.100.34.127   <none>        6379/TCP,26379/TCP   3m34s
    
    NAME                                     READY   AGE
    statefulset.apps/db-redis-ha-server      1/1     97s
    statefulset.apps/meter-redis-ha-server   1/1     3m34s


# Create  a minimal `kiebitz` image

This Dockerfile is using a multistage build. 
- it start with the development build
- it creates a staticallc linked file directly from the kiebitz git repo source code
- for a code review all dependencies need to be checked
- __all licenses also need to be checked__


```bash
cat container/kiebitz/Dockerfile
```

    FROM golang:1.16 as builder 
    
    RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go install -v github.com/kiebitz-oss/services/cmd/kiebitz@latest
    
    FROM scratch
    
    ENV KIEBITZ_SETTINGS=/settings
    
    CMD [ "/kiebitz","run","all" ]
    #CMD ["sleep","86400"]
    
    COPY --from=builder /go/bin/kiebitz kiebitz
    
    # Ports
    EXPOSE 8888
    EXPOSE 9999



```bash
docker build -t $KIEBITZ container/kiebitz 
```

    Sending build context to Docker daemon  2.048kB
    Step 1/8 : FROM golang:1.16 as builder
     ---> 5b838b7289de
    Step 2/8 : RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go install -v github.com/kiebitz-oss/services/cmd/kiebitz@latest
     ---> Running in 76419449b17e
    go: downloading github.com/kiebitz-oss/services v0.0.0-20211126211101-fe405d3f0767
    go: downloading github.com/go-redis/redis v6.15.9+incompatible
    go: downloading github.com/kiprotect/go-helpers v0.0.0-20210706144641-b74c3f0f016d
    go: downloading github.com/urfave/cli v1.22.5
    go: downloading github.com/prometheus/client_golang v1.11.0
    go: downloading github.com/sirupsen/logrus v1.8.1
    go: downloading golang.org/x/crypto v0.0.0-20200709230013-948cd5f35899
    go: downloading gopkg.in/yaml.v2 v2.3.0
    go: downloading golang.org/x/sys v0.0.0-20210603081109-ebe580a85c40
    go: downloading github.com/cpuguy83/go-md2man/v2 v2.0.0-20190314233015-f79a8a8ca69d
    go: downloading github.com/russross/blackfriday/v2 v2.0.1
    go: downloading github.com/prometheus/common v0.26.0
    go: downloading github.com/prometheus/client_model v0.2.0
    go: downloading github.com/cespare/xxhash/v2 v2.1.1
    go: downloading github.com/prometheus/procfs v0.6.0
    go: downloading github.com/golang/protobuf v1.4.3
    go: downloading github.com/beorn7/perks v1.0.1
    go: downloading github.com/shurcooL/sanitized_anchor_name v1.0.0
    go: downloading github.com/matttproud/golang_protobuf_extensions v1.0.1
    go: downloading google.golang.org/protobuf v1.26.0-rc.1
    google.golang.org/protobuf/internal/flags
    golang.org/x/sys/internal/unsafeheader
    github.com/kiprotect/go-helpers/maps
    github.com/shurcooL/sanitized_anchor_name
    google.golang.org/protobuf/internal/set
    google.golang.org/protobuf/internal/pragma
    github.com/go-redis/redis/internal/hashtag
    github.com/beorn7/perks/quantile
    github.com/prometheus/common/internal/bitbucket.org/ww/goautoneg
    github.com/cespare/xxhash/v2
    github.com/go-redis/redis/internal/util
    github.com/go-redis/redis/internal/consistenthash
    golang.org/x/sys/unix
    google.golang.org/protobuf/internal/detrand
    net
    google.golang.org/protobuf/internal/version
    github.com/prometheus/procfs/internal/fs
    github.com/prometheus/procfs/internal/util
    github.com/prometheus/common/model
    github.com/kiprotect/go-helpers/errors
    github.com/russross/blackfriday/v2
    github.com/go-redis/redis/internal/proto
    gopkg.in/yaml.v2
    google.golang.org/protobuf/internal/errors
    github.com/kiprotect/go-helpers/forms
    google.golang.org/protobuf/encoding/protowire
    google.golang.org/protobuf/reflect/protoreflect
    github.com/cpuguy83/go-md2man/v2/md2man
    github.com/urfave/cli
    google.golang.org/protobuf/internal/encoding/messageset
    google.golang.org/protobuf/internal/strs
    google.golang.org/protobuf/internal/descopts
    google.golang.org/protobuf/internal/order
    google.golang.org/protobuf/runtime/protoiface
    google.golang.org/protobuf/internal/descfmt
    google.golang.org/protobuf/internal/genid
    github.com/kiprotect/go-helpers/yaml
    google.golang.org/protobuf/reflect/protoregistry
    google.golang.org/protobuf/internal/encoding/text
    google.golang.org/protobuf/proto
    golang.org/x/crypto/ssh/terminal
    github.com/sirupsen/logrus
    google.golang.org/protobuf/internal/encoding/defval
    net/textproto
    vendor/golang.org/x/net/http/httpproxy
    crypto/x509
    github.com/go-redis/redis/internal
    github.com/prometheus/procfs
    google.golang.org/protobuf/encoding/prototext
    google.golang.org/protobuf/internal/filedesc
    github.com/go-redis/redis/internal/pool
    vendor/golang.org/x/net/http/httpguts
    mime/multipart
    github.com/kiprotect/go-helpers/settings
    github.com/kiebitz-oss/services/crypto
    crypto/tls
    google.golang.org/protobuf/internal/encoding/tag
    google.golang.org/protobuf/internal/impl
    net/http/httptrace
    net/smtp
    github.com/go-redis/redis
    net/http
    google.golang.org/protobuf/internal/filetype
    google.golang.org/protobuf/runtime/protoimpl
    google.golang.org/protobuf/types/known/anypb
    google.golang.org/protobuf/types/known/timestamppb
    google.golang.org/protobuf/types/known/durationpb
    github.com/golang/protobuf/proto
    github.com/golang/protobuf/ptypes/timestamp
    github.com/golang/protobuf/ptypes/any
    github.com/golang/protobuf/ptypes/duration
    github.com/golang/protobuf/ptypes
    github.com/prometheus/client_model/go
    github.com/matttproud/golang_protobuf_extensions/pbutil
    github.com/prometheus/client_golang/prometheus/internal
    expvar
    github.com/prometheus/common/expfmt
    github.com/prometheus/client_golang/prometheus
    github.com/prometheus/client_golang/prometheus/promhttp
    github.com/kiebitz-oss/services/metrics
    github.com/kiebitz-oss/services
    github.com/kiebitz-oss/services/tls
    github.com/kiebitz-oss/services/databases
    github.com/kiebitz-oss/services/http
    github.com/kiebitz-oss/services/meters
    github.com/kiebitz-oss/services/forms
    github.com/kiebitz-oss/services/jsonrpc
    github.com/kiebitz-oss/services/servers
    github.com/kiebitz-oss/services/helpers
    github.com/kiebitz-oss/services/cmd/helpers
    github.com/kiebitz-oss/services/cmd
    github.com/kiebitz-oss/services/definitions
    github.com/kiebitz-oss/services/cmd/kiebitz
    Removing intermediate container 76419449b17e
     ---> b68b6fac8ae6
    Step 3/8 : FROM scratch
     ---> 
    Step 4/8 : ENV KIEBITZ_SETTINGS=/settings
     ---> Running in fcd5583c55c3
    Removing intermediate container fcd5583c55c3
     ---> 4e287417f897
    Step 5/8 : CMD [ "/kiebitz","run","all" ]
     ---> Running in eaea43723618
    Removing intermediate container eaea43723618
     ---> 7726237c4b91
    Step 6/8 : COPY --from=builder /go/bin/kiebitz kiebitz
     ---> d54a9889ee90
    Step 7/8 : EXPOSE 8888
     ---> Running in 6e94920c4a06
    Removing intermediate container 6e94920c4a06
     ---> 46ee7ce44154
    Step 8/8 : EXPOSE 9999
     ---> Running in 7a619ac883f0
    Removing intermediate container 7a619ac883f0
     ---> ca8b0099f760
    Successfully built ca8b0099f760
    Successfully tagged kiebitz:latest


### adapt the `REGISTRY` variable to your registry

- the image is tagged to the new registry
- the image is pushed


```bash
docker tag $KIEBITZ $REGISTRY/$KIEBITZ
```


```bash
docker push  $REGISTRY/$KIEBITZ
```

    Using default tag: latest
    The push refers to repository [localhost:5000/kiebitz]
    
    latest: digest: sha256:ba36557d2f897cf5169aaab7b3be1f5c99c4e835adcc84f66cab1307e18a65a8 size: 528


# Install the application using Helm


```bash
pwd
```

    /home/thomas/import/kiebitz/kubernetes



```bash
helm install mykiebitz charts/kiebitz
```

    NAME: mykiebitz
    LAST DEPLOYED: Sat Nov 27 16:33:16 2021
    NAMESPACE: kiebitz
    STATUS: deployed
    REVISION: 1
    NOTES:
    1. Get the application URL by running these commands:
      export POD_NAME=$(kubectl get pods --namespace kiebitz -l "app.kubernetes.io/name=kiebitz,app.kubernetes.io/instance=mykiebitz" -o jsonpath="{.items[0].metadata.name}")
      export CONTAINER_PORT=$(kubectl get pod --namespace kiebitz $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
      echo "Visit http://127.0.0.1:8080 to use your application"
      kubectl --namespace kiebitz port-forward $POD_NAME 8080:$CONTAINER_PORT



```bash
kubectl get all
```

    NAME                             READY   STATUS    RESTARTS   AGE
    pod/db-redis-ha-server-0         3/3     Running   0          96s
    pod/meter-redis-ha-server-0      3/3     Running   0          3m48s
    pod/mykiebitz-6f66475864-xkrrq   1/1     Running   0          2s
    
    NAME                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)              AGE
    service/db-redis-ha                 ClusterIP   None            <none>        6379/TCP,26379/TCP   116s
    service/db-redis-ha-announce-0      ClusterIP   10.102.144.45   <none>        6379/TCP,26379/TCP   116s
    service/meter-redis-ha              ClusterIP   None            <none>        6379/TCP,26379/TCP   3m53s
    service/meter-redis-ha-announce-0   ClusterIP   10.100.34.127   <none>        6379/TCP,26379/TCP   3m53s
    service/mykiebitz                   ClusterIP   10.100.79.171   <none>        80/TCP               2s
    
    NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/mykiebitz   1/1     1            1           2s
    
    NAME                                   DESIRED   CURRENT   READY   AGE
    replicaset.apps/mykiebitz-6f66475864   1         1         1       2s
    
    NAME                                     READY   AGE
    statefulset.apps/db-redis-ha-server      1/1     116s
    statefulset.apps/meter-redis-ha-server   1/1     3m53s



```bash
kubectl logs -l app.kubernetes.io/name=kiebitz
```

    time="2021-11-27T15:33:17Z" level=info msg="Ping to Redis succeeded!"
    time="2021-11-27T15:33:17Z" level=info msg="Ping to Redis meter succeeded!"
    time="2021-11-27T15:33:18Z" level=info msg="Waiting for CTRL-C..."



```bash
kubectl get pods -o jsonpath='{range .items[*]}{range .spec.initContainers[*]}{.image}{"\n"}{end}{range .spec.containers[*]}{.image}{"\n"}{end}{end} ' 
```

    redis:6.2.5-alpine
    redis:6.2.5-alpine
    redis:6.2.5-alpine
    redis:6.2.5-alpine
    redis:6.2.5-alpine
    redis:6.2.5-alpine
    redis:6.2.5-alpine
    redis:6.2.5-alpine
    localhost:5000/kiebitz:latest
     

# Uninstall


```bash
helm uninstall meter db mykiebitz
```

    release "meter" uninstalled
    release "db" uninstalled
    release "mykiebitz" uninstalled



```bash
helm ls
```

    NAME	NAMESPACE	REVISION	UPDATED	STATUS	CHART	APP VERSION



```bash

```
