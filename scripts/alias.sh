#!/usr/bin/env bash

alias refr='refresh'
function refresh() {
    source ~.zshrc
}

# Docker
alias dps="docker ps"
alias dlf="docker logs -f"

# Kubernetes
alias kcx="kubectx"
alias kns="kubens"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias kgd="kubectl get deployments"
alias klf="kubectl logs -f"
