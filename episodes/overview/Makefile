# This tells kubecfg to read its config from the local directory
export KUBECONFIG=./kubeconfig

# Looking at the cluster
kubectl get nodes
kubectl get pods --namespace=kube-system

# Running a single pod
# pod is group of containers that run as a unit, processes that can coordinate with each other
# fundamental unit of K8 runs
# multi container example - sidecar for istio/linkerd, logging, search (serving and dataload containers)
# command essentially create a manifest and uploads to server
kubectl run --generator=run-pod/v1 --image=gcr.io/kuar-demo/kuard-amd64:1 kuard
kubectl get pods
#see generated document uploaded to server
kubectl run --generator=run-pod/v1 --image=gcr.io/kuar-demo/kuard-amd64:1 kuard --dry-run -o yaml
kubectl get pods kuard -o yaml
#only sends you to a particualr pod
kubectl port-forward kuard 8080:8080
kubectl delete pod kuard

# replicaset allows you to create multiple container instances based on a template
# Running a deployment
kubectl run --image=gcr.io/kuar-demo/kuard-amd64:1 kuard --replicas=5 --dry-run -o yaml
kubectl run --image=gcr.io/kuar-demo/kuard-amd64:1 kuard --replicas=5
kubectl get pods

# Running a service
# names a set of pods via labels, point this service at pods a specific deployment is managing
# service and deployment dont know about each other but use labels to find each other
# Collect IP addresses from those pods 
# then put an internal K8 LB in front of them (ClusterIP)
# Only works within the cluster
# Next alternative pick a port and if you hit any node in cluster on that port it gets forwarded to service (nodePort)
# Next alternative create external LB, one per service, 
kubectl expose deployment kuard --type=LoadBalancer --port=80 --target-port=8080 --dry-run -o yaml
kubectl get service kuard -o wide

# Wait a while for the ELB to be ready
KUARD_LB=$(kubectl get service kuard -o jsonpath='{.status.loadBalancer.ingress[*].hostname}')

---
# Doing a deployment
## Window 1
## On the mac, install with `brew install watch`
watch -n 0.1 kubectl get pods

## Window 2
## On the mac, install with `brew install jq`
while true ; do curl -s http://${KUARD_LB}/env/api | jq '.env.HOSTNAME'; done

## Window 3
kubectl scale deployment kuard --replicas=10
#kubectl edit deploy kuard lets you edit manifest directly
kubectl set image deployment kuard kuard=gcr.io/kuar-demo/kuard-amd64:2
kubectl rollout undo deployment kuard

---
# Clean up
kubectl delete deployment,service kuard