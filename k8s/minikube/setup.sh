echo "Installing kubectl"
brew install kubectl
kubectl version

echo "\n\n"
echo "Installing hyperkit"
brew install hyperkit
hyperkit -v

echo "\n\n"
echo "Installing minikube"
brew install minikube
minikube version

echo "\n\n"
echo "Installing argo"
brew install argoproj/tap/argo

# Create profile
minikube profile local-spacemesh

# Start
minikube start -p local-spacemesh --vm-driver=hyperkit

# Set context to `local-spacemesh`
kubectl config use-context local-spacemesh

# Create namespace for argo
kubectl create ns argo

# Apply argo config
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/stable/manifests/install.yaml

# Set docker env
eval $(minikube docker-env)

# Config argo UI
kubectl -n argo port-forward deployment/argo-ui 8001:8001
# browser url: http://localhost:8001

