# Set Docker env
eval $(minikube docker-env)

# Set `kubectl` context to `local-spacemesh`
kubectl config use-context local-spacemesh

# Build image
docker build --progress plain --tag spacemesh/go-spacemesh --file ../../Dockerfile ../..

# Delete pod
kubectl delete pod go-spacemesh-pod

# Create pod
kubectl create -f pod.yaml

# # Verify pod is running
kubectl get pods
