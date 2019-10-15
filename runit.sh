#!/usr/bin/env bash
trap "set +x; sleep 5; set -x" DEBUG

git config --global user.name “mchalep”
git config --global user.email patrick.mchale.mail@gmail.com
git config --global push.default simple
git config --global core.editor "vim"

minikube config set memory 8192
minikube config set cpus 4

#helm init --wait --debug; kubectl rollout status deploy/tiller-deploy -n kube-system

helm install stable/etcd-operator --version 0.9.0 --name etcd-operator --debug --wait

kubectl create -f manifests/etcd-cluster.yaml

kubectl create -f manifests/etcd-service.yaml

kubectl apply -f manifests/all-services.yaml

docker build -t 127.0.0.1:30400/monitor-scale:`git rev-parse --short HEAD` -f applications/monitor-scale/Dockerfile applications/monitor-scale

#docker build -t socat-registry -f applications/socat/Dockerfile applications/socat

docker stop socat-registry; docker rm socat-registry; docker run -d -e "REG_IP=`minikube ip`" -e "REG_PORT=30400" --name socat-registry -p 30400:5000 socat-registry

#lsof -i :30400

docker push 127.0.0.1:30400/monitor-scale:`git rev-parse --short HEAD`

docker stop socat-registry

#minikube service registry-ui

kubectl apply -f manifests/monitor-scale-serviceaccount.yaml

sed 's#127.0.0.1:30400/monitor-scale:$BUILD_TAG#127.0.0.1:30400/monitor-scale:'`git rev-parse --short HEAD`'#' applications/monitor-scale/k8s/deployment.yaml | kubectl apply -f -

kubectl rollout status deployment/monitor-scale

#kubectl get pod monitor-scale-6d8744f69f-fmtx5 --output=yaml

kubectl get pods
kubectl get services
kubectl get ingress
kubectl get deployments

scripts/puzzle.sh

kubectl rollout status deployment/puzzle
kubectl rollout status deployment/mongo

scripts/kr8sswordz-pages.sh

kubectl rollout status deployment/kr8sswordz

kubectl get pods

#minikube service kr8sswordz
