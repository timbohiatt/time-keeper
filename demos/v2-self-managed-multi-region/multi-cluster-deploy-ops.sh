#!/usr/bin/env bash
PROJECT=$1

for cluster in $(gcloud container clusters list --format='csv[no-heading](name,zone, endpoint)  --project="${PROJECT}"' )
do
    
    echo $cluster

    clusterName=$(echo $cluster | cut -d "," -f 1)
    clusterZone=$(echo $cluster | cut -d "," -f 2)
    clusterEndpoint=$(echo $cluster | cut -d "," -f 3)

    echo $clusterName
    echo $clusterZone
    echo $clusterEndpoint
    echo $PROJECT

    gcloud container clusters get-credentials $clusterName --region="$clusterZone" --project="$PROJECT"

    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/namespace.yaml
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/install-manifests.yaml || true
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/install-manifests.yaml || true
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/kiali.yaml || true
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/prometheus.yaml || true
    kubectl apply -f demos/v1-self-managed/time-keeper-infra/manifests/istio/jaeger.yaml || true
    kubectl apply -f demos/v1-self-managed/time-keeper-infra/manifests/istio/zipkin.yaml || true
    
done