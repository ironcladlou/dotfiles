#!/bin/bash

oc get -n openshift-ingress-operator deployments/ingress-operator

oc get -n openshift-ingress deployments

oc get -n openshift-ingress-operator ingresscontrollers -o yaml

oc get -n openshift-ingress-operator dnsrecords -o yaml


