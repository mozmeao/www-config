#!/bin/bash

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# We pin to version ^0 here to exclude ingress-nginx 1.*,
# which require a Kubernetes upgrade. 20210830 atoll

HELMOPTIONS=$(cat << EOM
  --namespace $NS \
  --version ^0 \
  -f $DEPLOYMENT/helm_configs/ingress.yml \
  bedrock-prod-ingress ingress-nginx/ingress-nginx
EOM
)

echo "Options are:"
echo "$HELMOPTIONS"

# shellcheck disable=SC2086
helm upgrade --install $HELMOPTIONS
