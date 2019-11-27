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

# Start minikube
minikube start -p spacemesh --vm-driver=hyperkit

# Set docker env
eval $(minikube docker-env)

# Set context to `spacemesh`
kubectl config use-context spacemesh

# Create `spacemesh-ns` namespace
if [[ $(kubens | grep -L -w "spacemesh-ns") ]]; then
  kubectl create ns spacemesh-ns
fi

# Switch to `spacemesh-ns` namespace
kubens spacemesh-ns

echo "\n\n"
echo "git clone https://github.com/spacemeshos/poet.git"
rm -rf poet
git c minikubelone https://github.com/spacemeshos/poet.git
