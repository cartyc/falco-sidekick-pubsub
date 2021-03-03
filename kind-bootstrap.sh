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

kubectl apply -f operator-system/configconnector-operator.yaml