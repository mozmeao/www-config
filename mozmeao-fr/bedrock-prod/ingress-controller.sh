#!/bin/bash

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# We pin to helm chart version 3.36.0, which provides appVersion 0.49.0,
# which is the latest release as of today that doesn't contain app 1.0+
# with a breaking change to require kubeVersion 1.19+. -- 20210830 atoll

HELMOPTIONS=$(cat << EOM
  --namespace $NS \
  --version 3.36.0 \
  -f $DEPLOYMENT/helm_configs/ingress.yml \
  bedrock-prod-ingress ingress-nginx/ingress-nginx
EOM
)

echo "Options are:"
echo "$HELMOPTIONS"

# shellcheck disable=SC2086
helm upgrade --install $HELMOPTIONS
