#shows you local kubevctl config
kubectl config view

#when connection comes into API server
#multiple ways it can assing user id to connection
#depends how you are authenticating to it could be via SSO or token pairs...

#K8 has a built in Certificate Authority for issues certs for control plane and users
#To test rbac in GKE create SA as aliases
#LOOK AT USING KUBECONFIG!!!!!! Manages clusters and certs for access

#Authentication  - Who
#Authorization - What

#rbac
#Port from Openshift - Started with K8 1.6

#Four parts of RBAC
#Role, ClusterRole, RoleBinding and ClusterRoleBindings

#When we create objects in K8 there is a decision = are these created under a namespace?
#Every pod lives in a namespace

#IMPORTANT
#not all object get a ns - clusterwide resource 
#get certificate signing request - no namespace
kubectl get csr [name] -o yaml
#get nodes - no namespace
kubectl get nodes [name] -o yaml | less

#IMPORTANT
#roles are namespaced resources - ns specific
kubectl get roles --all-namespaces
#ClusterRoles are cluster wide resources - custs across entire cluster
#see controllers that manage k8 e.g deployments
#
kubectl get clusterroles
kubectl get clusterrole system:basic-user -o yaml - see detail

#Roles state what API object acting on and the verbs (actions) I can do (create)

#IMPORTANT
#ClusterRole is cluster specific
#ClusterRoleBinding - allows this role to do this action across whole cluster
#RBAC means you can restrict what users can see which resources in whch namespace
#create ns per env and then restrict users by that ns

#DEMO COMMANDS
#When you use rbac work out what resources are needed for that sa and then craft rabc to cover that 
#role + rolebinding (cluster only), clusterrole and clusterrolebinding (cross cluster permissions)

#Quick get started before setting up rbac
#to get started you can run below which gives default SA admin role in that ns
#root inside ns
kubectl create rolebinding varMyRoleBinding \
  --clusterrole=admin \
  --serviceaccount=varMyNamespace:default \
  --namespace=varMyNamespace
#across cluster you can run
kubectl create clusterrolebinding varMyClusterRoleBinding \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:default

#every ns comes with a sa 
#create team ns and give access to resources in specific env
kubectl get sa - default only
kubectl create ns foo
kubectl get sa -n foo -o yaml - default sa in na foo




