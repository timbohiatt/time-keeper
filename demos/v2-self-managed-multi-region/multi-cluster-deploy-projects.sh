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

    # Deploy Ops Manifests
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-ops/manifests/namespaces --recursive
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-ops/manifests/ --recursive
    # Deploy Dev Team Deployments
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-projects/project-google/app-pasta/deployment --recursive
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-projects/project-google/app-hello-world/deployment --recursive
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-projects/project-google/app-bank-of-anthos/deployment --recursive
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-projects/project-google/app-bookinfo/deployment --recursive -n app-bookinfo
    
done