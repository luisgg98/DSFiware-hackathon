#!/bin/bash
# https://ubuntu.com/kubernetes/install
sudo apt install snapd
sudo snap install microk8s --classic

sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
newgrp microk8s
su - $USER
microk8s enable dashboard dns ingress

microk8s kubectl get all --all-namespaces


# https://discuss.kubernetes.io/t/use-kubectl-with-microk8s/5313/2
microk8s.kubectl config view --raw > $HOME/.kube/microk8s.config
# Add next two lines to your ~/.bashrc
export  KUBECONFIG=$HOME/.kube/config
export  KUBECONFIG=$KUBECONFIG:$HOME/.kube/microk8s.config

# Adds storage classic. https://stackoverflow.com/questions/74741993/0-1-nodes-are-available-1-pod-has-unbound-immediate-persistentvolumeclaims
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Open a new terminal and leave the other just with the dashboard running
microk8s dashboard-proxy