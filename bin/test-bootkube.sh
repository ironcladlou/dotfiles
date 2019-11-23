#!/usr/bin/env bash

BOOTSTRAP_HOST="ec2-18-218-204-189.us-east-2.compute.amazonaws.com"

GOOS=linux GOARCH=amd64 go build -mod=vendor -o cluster-etcd-operator-linux ./cmd/cluster-etcd-operator
scp ./cluster-etcd-operator-linux "core@${BOOTSTRAP_HOST}":/tmp/cluster-etcd-operator
ssh "core@${BOOTSTRAP_HOST}" mkdir -p /tmp/bootkube
scp -r ./bindata/bootkube/bootstrap-manifests "core@${BOOTSTRAP_HOST}":/tmp/bootkube
scp -r ./bindata/bootkube/config "core@${BOOTSTRAP_HOST}":/tmp/bootkube
scp -r ./bindata/bootkube/manifests "core@${BOOTSTRAP_HOST}":/tmp/bootkube
