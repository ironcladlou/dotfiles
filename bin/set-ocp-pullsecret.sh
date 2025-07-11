#!/bin/bash

cat ~/.docker/config.json | tr -d ' ' | tr -d '\n' > /tmp/pull-secret
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=/tmp/pull-secret
