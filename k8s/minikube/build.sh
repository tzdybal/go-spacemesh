# Set context to `docker-for-desktop`
kubectx docker-for-desktop

# Switch to namespace `spacemesh-ns`
kubens spacemesh-ns

# Get latest poet source
cd poet
git pull
cd ..

# Build poet image
docker build --tag spacemesh/poet --file ./poet/Dockerfile ./poet

# Build go-spacemesh image
docker build --tag spacemesh/go-spacemesh --file ../../Dockerfile ../..

# Delete all `spacemesh-ns` pods
kubectl delete --all pods --namespace=spacemesh-ns
