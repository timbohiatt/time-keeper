#!/bin/sh -x

PAYLOAD=$(cat <<EOF
{
"audience": "//iam.googleapis.com/projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/${GCP_POOL_ID}/providers/${GCP_PROVIDER_ID}",
"grantType": "urn:ietf:params:oauth:grant-type:token-exchange",
"requestedTokenType": "urn:ietf:params:oauth:token-type:access_token",
"scope": "https://www.googleapis.com/auth/cloud-platform",
"subjectTokenType": "urn:ietf:params:oauth:token-type:jwt",
"subjectToken": "${CI_JOB_JWT_V2}"
}
EOF
)

FEDERATED_TOKEN=$(curl -X POST "https://sts.googleapis.com/v1/token" \
 --header "Accept: application/json" \
 --header "Content-Type: application/json" \
 --data "${PAYLOAD}" \
 | jq -r '.access_token'
 )

ACCESS_TOKEN=$(curl -X POST "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${GCP_SERVICE_ACCOUNT}:generateAccessToken" \
--header "Accept: application/json" \
--header "Content-Type: application/json" \
--header "Authorization: Bearer ${FEDERATED_TOKEN}" \
--data '{"scope": ["https://www.googleapis.com/auth/cloud-platform"]}' \
| jq -r '.accessToken'
)
echo "${ACCESS_TOKEN}"

echo "CLOUDSDK_AUTH_ACCESS_TOKEN=${ACCESS_TOKEN}" >> CLOUDSDK_AUTH_ACCESS_TOKEN.env