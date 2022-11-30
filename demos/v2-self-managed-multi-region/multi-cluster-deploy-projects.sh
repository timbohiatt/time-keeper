
for cluster in $(gcloud container clusters list --format='csv[no-heading](name,zone, endpoint)  --project="$1"' )
do
    clusterName=$(echo $cluster | cut -d "," -f 1)
    clusterZone=$(echo $cluster | cut -d "," -f 2)
    clusterEndpoint=$(echo $cluster | cut -d "," -f 3)

    gcloud container clusters get-credentials $clusterName --region="$clusterZone" --project="$1"

    # Deploy Ops Manifests
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-ops/manifests/namespaces --recursive
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-ops/manifests/ --recursive
    # Deploy Dev Team Deployments
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-projects/project-google/app-pasta/deployment --recursive
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-projects/project-google/app-hello-world/deployment --recursive
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-projects/project-google/app-bank-of-anthos/deployment --recursive
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-projects/project-google/app-bookinfo/deployment --recursive -n app-bookinfo
    
done