# Create profile
minikube profile local-spacemesh

# Start
minikube start -p local-spacemesh --vm-driver=hyperkit

# Set context to `local-spacemesh`
kubectl config use-context local-spacemesh

# Add `registry` addon
# minikube addons enable registry

# Set docker env
eval $(minikube docker-env)
