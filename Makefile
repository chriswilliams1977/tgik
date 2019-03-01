#TGIK Tips
---------------------
GENERAL
----------------------------
#Imperative commands = objects created/managed via CLI. Executed against live objects
#Example
kubectl create ns [name]
kubectl create quota [name] --hard=pods=1 -n [namespace]
kubectl run [deploymentname] --image=[image] -n [namespace]
kubectl expose deployments [name] --port 2368 --type LoadBalancer -n [namespace]
#you can then modify these these using kubectl edit or other wrapper like scale
kubectl scale deployment ghost --replicas 2 -n ghost

#Use --dry-run with kubectl run or create cmd

#Can use export when using kubectl get to get yaml. You can then do declarative commands
kubectl get deployments [name] --export -n [namespace] -o yaml

#Declarative 
#the creation, deletion and modification of objects is done via a single command
#Kubernetes will check the state of the live object, the configuration stored in the annotation and the manifest being provided. 
#It will then perform some advanced patching to modify only the fields that need to be modified.
kubectl apply -f <object>.<yaml,json>
#Kubectl alias
alias k=kubectl

#IMPORTANT
#Get kubectl manifest to be executed
Kubectl create namespace mynamespace -o yaml —dry-run

#Get kubectl version
Kubectl version

#Port forward for container 
Kubectl port-forward [pod id] 8080:8080

#Get more info
Attach -o wide

---------------------
NETWORKING
---------------------
#IMPORTANT
#Look inside pod
Kubectl exec -it [pod id] ash
#Then
#hostname - set to cluster 
ifconfig - get network info (every pod get own IP separate from node)

#IMPORTANT
#Analogy for IP, DNS and ports
#IP = phone number (route packets)
#DNS = phone book
#Port = extension (fixed to a department you want to reach, 80 is web team, 25 is email) (once packet received OS needs to map to running program)

#Query container from other container
Kubectl exec -it [pod ip] ash
Wget -O - IP:port
wget -O - 10.28.3.3:8080/env/api - shows api on container
#Out of cluster to into cluster not possible (other way round is)
#CNI - standard interface for networking
#Calico is plugin type that uses CNI
#When operation with  container needs to happen it calls out to plugin (can have multi plugin for a container)

#CNI takes network set up from docker first e.g
#IPAM - allocation of IP addresses (who has what IP, when and where)
#Network namespaces for container
#Then docker creates container inside that network namespace
#Pluggable system
#CNI is an API

#Find file
Find . -name cni

#Service
Kubectl expose deployment [name] —type=LoadBalancer —target-port=8080 —port=80

#IMPORTANT
#Service points at pods being managed by a deployment 
#Coordinate by label selector in deployment
#Services have types:
#On Cluster
#None - Create service with selector thats all. Named label query

#ClusterIP - Virtual IP (static) different to pod IP. 
#Uses Kube proxy (daemon set on each node) to:
#- Monitors service to get ClusterIP’s 
#- Gets buddy endpoints and looks for changes
#- Then configures IP tables so traffic going to ClusterIP gets load balanced across endpoints (backed service NAT to pod)
iptables -L to see IPTables
Iptables-save | less - to save output
#DNS not given to pods as they are ephemeral. But DNS can be  given to ClusterIP VIP as it is static - DNS is service name.default.svc.cluster.local

#Off Cluster
#NodePort - bridge outside cluster to inside cluster. 
#Anyone talking to specific port maps to service same as ClusterIP maps VIP to endpoints

#LoadBalancer - Create a ILB - points to random node on cluster then forwards to node port  then gets mapped to node with to pod

#Get endpoints
Kubectl get endpoints [service] -o yaml - show endpoints for a service (service discovery) - how service collect info and maps

#Debugging
#Do pods exist
kubectl get pods
#Does service exists
kubectl get svc
#if pod is consuming service - try a hit service
wget -O- gocore-service
#From a Pod in the same Namespace if DNS enabled
nslookup hostnames
#if no DNS try ip
curl [ip address]
#check service json
kubectl get service [name] -o json

---------------------
ISTIO
---------------------
#service mesh brings complexity
#Istio helps eleviate problems areound service overloading, discovery, decoupling, security	
#security and identity of who is calling a service
#Twitter finnagle library led to linkerd (own binary)
#Google had a library per lang python using swig
#sidecar runs next to app and implements magic (Envoy)
#Istio provides a control plane to manage app these proxies 

#namespace in K8 are used to isolate resource by teams also manage quota and security policy

#Cluster roles are scoped cluster wide thus not scoped to specific namespace

#Install
gcloud container clusters create istio-tutorial \
    --machine-type=n1-standard-2 \
    --num-nodes=4 \

#if existing version = >1.6 with RBAC enabled
#Check is RBAC is enabled on cluster
#kubectl api-versions | grep rbac
#To install
#Kubectl apply -f install/kubernetes/istio-rbac-beta.yaml

#Istio installed under istio-system namespace and can access services on all other namespaces

#download tar ball, extract 
#cd to root of istio
#add to path
export PATH=$PWD/bin:$PATH

#grant cluster admin role to current user
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user="$(gcloud config get-value core/account)"

#install istio
kubectl apply -f install/kubernetes/istio-demo-auth.yaml

#check installed services: istio-citadel, istio-pilot, istio-ingressgateway, istio-policy, and istio-telemetry
kubectl get service -n istio-system

#check deployed pods: istio-pilot-*, istio-policy-*, istio-telemetry-*, istio-ingressgateway-*, and istio-citadel-*.
kubectl get pods -n istio-system 

#deploy bookinfo sample
kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)

#get logs
kubectl logs [pod] -n [namespace]

#Debugging
#Shows status of each proxy
istioctl proxy-status
#Shows envoy proxy configuration for each sidecar
istioctl proxy-config clusters -n istio-system [pod id]
#Follow an envoy request 
#If you query the listener summary on a pod you will notice Istio generates the following listeners
#A listener on 0.0.0.0:15001 that receives all traffic into and out of the pod, then hands the request over to a virtual listener.
#A virtual listener per service IP, per each non-HTTP for outbound TCP/HTTPS traffic.
#A virtual listener on the pod IP for each exposed port for inbound traffic.
#A virtual listener on 0.0.0.0 per each HTTP port for outbound HTTP traffic.
#every sidecar has a listener bound to 0.0.0.0:15001, where IP tables routes all inbound and outbound pod traffic to
#this This listener has useOriginalDst set to true = it hands the request over to the listener that best matches the original destination of the request
#No match = BlackHoleCluster which returns a 404
istioctl proxy-config listeners [pod]
istioctl proxy-config listeners [pod] --port 15001 -o json
