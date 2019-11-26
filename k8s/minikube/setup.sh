# halt on-error
set -e

echo "Installing kubectl"
brew install kubectl
kubectl version

echo "Installing kubectx"
brew install kubectx

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

# Set docker env
eval $(minikube docker-env)

# Create profile
minikube profile local-spacemesh

# Start
minikube start -p local-spacemesh --vm-driver=hyperkit

# Set context to `local-spacemesh`
kubectx local-spacemesh

# Create argo namespace
if [[ $(kubens | grep -L -w "argo") ]]; then
  kubectl create ns argo
fi

# Switch to namespace for argo
kubens argo

# Apply argo config
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/stable/manifests/install.yaml

echo "\n\n"
echo "git clone https://github.com/spacemeshos/poet.git"
rm -rf poet
git clone https://github.com/spacemeshos/poet.git

# Config argo UI
kubectl -n argo port-forward deployment/argo-ui 8001:8001
# browser url: http://localhost:8001


