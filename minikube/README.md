#### Docker buid app image

$ cd docker

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

$ cd app

$ kubectl apply -f deployment.yaml 
```
deployment.apps/app-hello created
```

$ kubectl get deployment
```
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
app-hello   0/1     1            0           14s
```

$ kubectl get pod
```
NAME                         READY   STATUS             RESTARTS   AGE
app-hello-6d4b64c5cc-kzwc7   0/1     ImagePullBackOff   0          19s
```

$ kubectl apply -f service.yaml

$ kubectl get service
```
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
app-service   NodePort    10.102.110.253   <none>        5000:30643/TCP   14m
```

$ minikube ssh

minikube$ curl 10.102.110.253:5000
```
Pod name is app-deployment-59fcc954f5-g7npj
```

$ kubectl get ingress
```
NAME          CLASS    HOSTS   ADDRESS   PORTS   AGE
app-ingress   <none>   *                 80      9s
```

$ minikube service app-service --url
```
http://192.168.49.2:30643
```

$ curl http://192.168.49.2:30643
```
Pod name is app-deployment-59fcc954f5-g7npj
```

$ kubectl scale deployment --replicas=4 app-deployment

$ kubectl get pods
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