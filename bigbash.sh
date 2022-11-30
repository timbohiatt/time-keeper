


gcloud container clusters list --project="$1" --format="csv(name,location)"
#gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --region="${GKE_CLUSTER_REGION}" --project="$1"