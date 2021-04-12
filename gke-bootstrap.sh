#! /bin/bash

gcloud container clusters create kcc-infra \
--no-enable-basic-auth \
--enable-shielded-nodes \
--no-issue-client-certificate \
--num-nodes 1 \
--release-channel regular \
--enable-stackdriver-kubernetes \
--network default \
--create-subnetwork name=gke-dev \
--scopes cloud-platform \
--enable-ip-alias \
--enable-network-policy \
--no-enable-legacy-authorization \
--enable-binauthz \
--machine-type n2-standard-2 \
--zone northamerica-northeast1-a \
--image-type cos_containerd \
--workload-pool={$PROJECT_ID}.svc.id.goog \
--addons ConfigConnector