
for cluster in $(gcloud container clusters list --format='csv[no-heading](name,zone, endpoint)  --project="$1"' )
do
    clusterName=$(echo $cluster | cut -d "," -f 1)
    clusterZone=$(echo $cluster | cut -d "," -f 2)
    clusterEndpoint=$(echo $cluster | cut -d "," -f 3)

    gcloud container clusters get-credentials $clusterName --region="$clusterZone" --project="$1"
    

done