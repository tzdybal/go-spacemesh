# Set Docker env
eval $(minikube docker-env)

# Set `kubectl` context to `local-spacemesh`
kubectl config use-context local-spacemesh

# Build poet
cd poet
git pull


# Build go-spacemesh image
# docker build --progress plain --tag spacemesh/go-spacemesh --file ../../Dockerfile ../..
#
# # Delete all argo workflows
# argo delete --all
#
# # Delete all remaining pods
# kubectl delete --all pods
#
# # Create pod
# # kubectl create -f pod.yaml
#
# # Verify pod is running
# kubectl get pods
