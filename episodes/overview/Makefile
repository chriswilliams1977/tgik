#Contains all information you need to access cluster
# This tells kubecfg to read its config from the local directory
export KUBECONFIG=./kubeconfig

# Looking at the cluster
kubectl get nodes
#core components of master (processes running to manage k8) - deployed workloads
kubectl get pods --namespace=kube-system

#this command essentially creates a manifest yaml and then uploads that desired state to etcd based on params
# Running a single pod
# pod is group of containers that run as a unit, processes that can coordinate with each other
# fundamental unit of K8 runs
# multi container example - sidecar for istio/linkerd, logging, search (serving and dataload containers)
kubectl run --generator=run-pod/v1 --image=gcr.io/kuar-demo/kuard-amd64:1 kuard
kubectl get pods
#see generated document uploaded to server
#use kuard --dry-run -o yaml to get manifest
kubectl run --generator=run-pod/v1 --image=gcr.io/kuar-demo/kuard-amd64:1 kuard --dry-run -o yaml
kubectl get pods kuard -o yaml
#only sends you to a particualar pod
kubectl port-forward kuard 8080:8080
kubectl delete pod kuard

#things pods are good for getting a single container onto a machine - singleton
#Things they dont do well is
#dealing with multiple container
#once container lands on node but that node disappears pods by themself dont handle this
# replicaset allows you to create multiple pods (running a container) instances based on a template
# Deployments are built on top of this to manage multiple instances
#states number of replicas and template to use for each
#delete deployment to get rid of pods
kubectl run --image=gcr.io/kuar-demo/kuard-amd64:1 kuard --replicas=5 --dry-run -o yaml
kubectl run --image=gcr.io/kuar-demo/kuard-amd64:1 kuard --replicas=5
kubectl get pods

# Creates a service
# names a set of pods via labels, point this service at pods a specific deployment is managing
# service and deployment dont know about each other but use labels to find each other
#it uses port = container uses
#targetport = port rest of world use to access it
# Collect IP addresses from those pods 
# then put an internal K8 LB in front of them (ClusterIP)
# Makes it easy to access pods through service abstaction
# But this only works within the cluster
# Next alternative pick a port and if you hit any node in cluster on that port it gets forwarded to service (nodePort)
# Next alternative create external LB, one per service,
#Create ELB and points that at nodes in the cluster at a particular port
#This is an ELB specific to cloud vendor so GCLB for GCP
kubectl expose deployment kuard --type=LoadBalancer --port=80 --target-port=8080 --dry-run -o yaml
#Show service
kubectl get service kuard -o wide
#get ELB details
dig [external ip]

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
#this download current deployment manifes, editing it and re uploading to etcd
#you can do this manually using kubectl edit deployment [deployment name]
kubectl scale deployment kuard --replicas=10
#kubectl edit deploy kuard lets you edit manifest directly
#or change image dynamically
kubectl set image deployment kuard kuard=gcr.io/kuar-demo/kuard-amd64:2
#allows you to rollback a deployment
kubectl rollout undo deployment kuard

---
# Clean up
kubectl delete deployment,service kuard