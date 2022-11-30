
for cluster in $(gcloud container clusters list --format='csv[no-heading](name,zone, endpoint)  --project="$1"' )
do
    clusterName=$(echo $cluster | cut -d "," -f 1)
    clusterZone=$(echo $cluster | cut -d "," -f 2)
    clusterEndpoint=$(echo $cluster | cut -d "," -f 3)

    gcloud container clusters get-credentials $clusterName --region="$clusterZone" --project="$1"

    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/namespace.yaml
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/install-manifests.yaml || true
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/install-manifests.yaml || true
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/kiali.yaml || true
    kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/prometheus.yaml || true
    kubectl apply -f demos/v1-self-managed/time-keeper-infra/manifests/istio/jaeger.yaml || true
    kubectl apply -f demos/v1-self-managed/time-keeper-infra/manifests/istio/zipkin.yaml || true
    
done