# Falco Sidekick PubSub Demo

## Provision Infra

### Crossplane

Crosplane Helm

```
kubectl create namespace crossplane-system

helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update

helm install crossplane --namespace crossplane-system crossplane-stable/crossplane --version 1.0.0
```

Crossplane CLI

```
curl -sL https://raw.githubusercontent.com/crossplane/crossplane/release-1.0/install.sh | sh

kubectl crossplane install provider crossplane/provider-gcp:v0.14.0
```

Create GCP SA Key

```
PROJECT_ID=my-project
NEW_SA_NAME=test-service-account-name

# create service account
SA="${NEW_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
gcloud iam service-accounts create $NEW_SA_NAME --project $PROJECT_ID

# enable cloud API
SERVICE="sqladmin.googleapis.com"
gcloud services enable $SERVICE --project $PROJECT_ID

# grant access to cloud API
ROLE="roles/cloudsql.admin"
gcloud projects add-iam-policy-binding --role="$ROLE" $PROJECT_ID --member "serviceAccount:$SA"

# create service account keyfile
gcloud iam service-accounts keys create creds.json --project $PROJECT_ID --iam-account $SA
```

Create the Key

```
kubectl create secret generic gcp-creds -n crossplane-system --from-file=key=./creds.json
```

Configure the Provider

```
# replace this with your own gcp project id
PROJECT_ID=my-project
echo "apiVersion: gcp.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  projectID: ${PROJECT_ID}
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: gcp-creds
      key: key" | kubectl apply -f -
```

### Kubernetes Config Connector

#### GKE

Create a new GKE cluster with the configconnector addon and workload identity enabled.

```
export PROJECT_NAME=<yourproject>

gcloud container clusters create kcc-infra \
--no-enable-basic-auth \
--enable-shielded-nodes \
--no-issue-client-certificate \
--num-nodes 1 \
--release-channel regular \
--enable-stackdriver-kubernetes \
--enable-ip-alias \
--enable-network-policy \
--no-enable-legacy-authorization \
--machine-type n2-standard-2 \
--zone northamerica-northeast1-a \
--image-type cos_containerd \
--workload-pool=${PROJECT_NAME}.svc.id.goog \
--addons ConfigConnector
```

#### Kind or other K8s conformant cluster

```
gcloud iam service-accounts create $SA_ACCOUNT

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:${SA_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
--role="roles/owner"

gcloud iam service-accounts keys create --iam-account \
${SA_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com key.json

kubectl create namespace cnrm-system

kubectl create secret generic kcc-key \
--from-file key.json \
--namespace cnrm-system

rm key.json

# Install Config Connector

gsutil cp gs://configconnector-operator/latest/release-bundle.tar.gz release-bundle.tar.gz

tar zxvf release-bundle.tar.gz

kubectl apply -f operator-system/configconnector-operator.yaml
```