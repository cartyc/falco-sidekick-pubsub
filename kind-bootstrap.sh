#! /bin/bash

kind create cluster --name kcc

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

kubectl config use-context kind-kcc --namespace infrastructure

kubectl apply -f operator-system/configconnector-operator.yaml

kubectl wait --for=condition=Ready  --timeout=120s crd/configconnectorcontexts.core.cnrm.cloud.google.com

kubectl create ns infrastructure
kubectl annotate ns infrastructure cnrm.cloud.google.com/project-id=${PROJECT_ID}

kubectl apply -f configconnector.yaml
kubectl wait --for=condition=Ready  --timeout=120s compute.cnrm.cloud.google.com/v1beta1
kubectl wait -n cnrm-system \
      --for=condition=Ready pod --all

# Deploy Resources
kubectl apply -f ./kcc-infra