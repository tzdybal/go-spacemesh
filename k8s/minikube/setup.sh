# halt on-error
set -e

echo "Installing kubectl"
brew install kubectl
kubectl version

echo "Installing kubectx"
brew install kubectx

# Set context to `docker-desktop`
kubectl config use-context docker-desktop

# Create `spacemesh-ns` namespace
if [[ $(kubens | grep -L -w "spacemesh-ns") ]]; then
  kubectl create ns spacemesh-ns
fi

# Switch to `spacemesh-ns` namespace
kubens spacemesh-ns

echo "\n\n"
echo "git clone https://github.com/spacemeshos/poet.git"
rm -rf poet
git clone https://github.com/spacemeshos/poet.git
