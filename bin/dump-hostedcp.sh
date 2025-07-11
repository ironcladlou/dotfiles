#!/bin/bash
NS=$1
oc get -n $NS -o yaml awsmachines.infrastructure.cluster.x-k8s.io
oc get -n $NS -o yaml machines.cluster.x-k8s.io
oc get -n $NS -o yaml machinesets.cluster.x-k8s.io
oc get -n $NS -o yaml awsmachinetemplates.infrastructure.cluster.x-k8s.io
oc get -n $NS -o yaml externalinfraclusters.hypershift.openshift.io
oc get -n $NS -o yaml hostedcontrolplanes.hypershift.openshift.io
oc get -n $NS -o yaml clusters.cluster.x-k8s.io