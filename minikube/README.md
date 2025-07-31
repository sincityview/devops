#### Docker buid app image

$ cd app-docker

$ docker build -t app-hello:v1 .

$ docker images
```
REPOSITORY                    TAG
app-hello                     v1
```

$ docker tag app-hello:v1 reistry.domain.ru/app-hello:v1

$ docker push registry.domain.ru/app-hello:v1

<br />

#### Minikube

> Install kubectl minikube

$ minikube start

$ minikube dashboard

$ kubectl version
```
Client Version: v1.33.3
Kustomize Version: v5.6.0
Server Version: v1.33.1
```

$ cd app-k8s

$ kubectl create namespace app-k8s-dev
```
namespace/app-k8s-dev created
```

> Got aliases for managment with namespaces
> alias kdev='kubectl -n app-k8s-dev'

$ kubectl get namespace
```
NAME                   STATUS   AGE
app-k8s-dev            Active   7s
```

$ kubectl apply -f deployment.yaml 
```
deployment.apps/app-hello created
```

$ kdev get deployment
```
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
app-hello   0/1     1            0           14s
```

$ kdev get pod
```
NAME                         READY   STATUS             RESTARTS   AGE
app-hello-6d4b64c5cc-kzwc7   0/1     ImagePullBackOff   0          19s
```

$ kubectl apply -f service.yaml

$ kdev get service
```
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
app-service   NodePort    10.102.110.253   <none>        5000:30643/TCP   14m
```

$ minikube ssh

minikube$ curl 10.102.110.253:5000
```
Pod name is app-deployment-59fcc954f5-g7npj
```

$ kubectl apply -f ingress.yaml
```
ingress.networking.k8s.io/app-ingress created
```

$ kdev get ingress
```
NAME          CLASS    HOSTS   ADDRESS   PORTS   AGE
app-ingress   <none>   *                 80      9s
```

$ minikube service app-service -n app-k8s-dev --url
```
http://192.168.49.2:30643
```

$ curl http://192.168.49.2:30643
```
Pod name is app-deployment-59fcc954f5-g7npj
```

$ kdev scale deployment --replicas=4 app-deployment

$ kdev get pods
```
NAME                              READY   STATUS    RESTARTS   AGE
app-deployment-59fcc954f5-g7npj   1/1     Running   0          6m6s
app-deployment-59fcc954f5-hvksp   1/1     Running   0          31s
app-deployment-59fcc954f5-jn8bs   1/1     Running   0          31s
app-deployment-59fcc954f5-pbrh7   1/1     Running   0          31s
```

$ curl http://192.168.49.2:30643 [x3]
```
Pod name is app-deployment-59fcc954f5-pbrh7
Pod name is app-deployment-59fcc954f5-jn8bs
Pod name is app-deployment-59fcc954f5-hvksp
```

> Balanced