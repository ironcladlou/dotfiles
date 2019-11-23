#/bin/bash
set -eou pipefail

function find_events {
  local load_balancers_json=$(aws elb describe-load-balancers | jq $'[.LoadBalancerDescriptions[] | select(.BackendServerDescriptions == []) | .LoadBalancerName]')
  local where_names_in=$(jq -r $'map("\'" + . + "\'") | join(",")' <<< $load_balancers_json)
  local query="
    SELECT
      eventtime,
      eventname,
      useridentity.username,
      useragent,
      requestparameters,
      requestid,
      eventid,
      errorcode,
      errormessage
    FROM default.cloudtrail_logs_cloud_trail_test_clayton
    WHERE
      eventname = 'SetLoadBalancerPoliciesForBackendServer'
      AND json_extract_scalar(requestparameters, '\$.loadBalancerName')
          IN (${where_names_in})
    ORDER BY eventtime desc;
  "
  echo $query
  local query_id=$(aws athena start-query-execution --result-configuration OutputLocation=s3://aws-athena-query-results-460538899914-us-east-1 --query-string "${query}" | jq -r '.QueryExecutionId')
  echo "created query $query_id"
  RESULTS=/tmp/athena-$query_id.json
  for i in {1..6}; do
    aws athena get-query-results --query-execution-id $query_id >$RESULTS && break
    sleep 10
  done
  echo "downloaded results to $RESULTS"
  LOAD_BALANCERS=/tmp/athena-$query_id-lbs.json
  echo $load_balancers_json > $LOAD_BALANCERS
  echo "stored load balancers in $LOAD_BALANCERS"
  cat $LOAD_BALANCERS
}

function reconcile {
  local load_balancers_json=$(cat $LOAD_BALANCERS)
  local load_balancers=$(cat $RESULTS | jq -r '.ResultSet.Rows[] | select(.Data[].VarCharValue == "SetLoadBalancerPoliciesForBackendServer") | .Data[3].VarCharValue | fromjson | .loadBalancerName' | sort | uniq)
  local load_balancer_count=$(wc -l <<< $load_balancers)
  local i=1
  while read load_balancer_id; do
    set +e
    local backends=$(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[].BackendServerDescriptions' --output json --load-balancer-names $load_balancer_id 2>/dev/null)
    local backends_retval="$?"
    set -e
    if [ "$backends_retval" -eq 0 ]; then
      local backend_count=$(jq length <<< "$backends")
      local label="($i/$load_balancer_count)"
      if [ "$backend_count" -eq 1 ]; then
        echo "$label $load_balancer_id good"
      else
        echo "$label $load_balancer_id suspicious"
      fi
    else
      echo "$label $load_balancer_id missing"
    fi
    sleep 2
    i=$((i+1))
  done <<< "$load_balancers"
}

function reconcile_old {
  local load_balancers=$(cat /tmp/athena-$ID.json | jq -r '.ResultSet.Rows[] | select(.Data[].VarCharValue == "SetLoadBalancerPoliciesForBackendServer") | .Data[3].VarCharValue | fromjson | .loadBalancerName' | sort | uniq)
  local i=1
  local load_balancer_count=$(wc -l <<< "$load_balancers" | xargs)
  while read load_balancer_id; do
    set +e
    local backends=$(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[].BackendServerDescriptions' --output json --load-balancer-names $load_balancer_id 2>/dev/null)
    local backends_retval="$?"
    set -e
    if [ "$backends_retval" -eq 0 ]; then
      local backend_count=$(jq length <<< "$JSON")
      local label="($i/$load_balancer_count)"
      if [ "$backend_count" -eq 1 ]; then
        echo "$label $load_balancer_id good"
      else
        echo "$label $load_balancer_id suspicious"
      fi
    else
      echo "$label $load_balancer_id missing"
    fi
    sleep 2
    i=$((i+1))
  done <<< "$load_balancers"
}

ID="${1:-}"

if [ -z "$ID" ]; then
  find_events
else
  LOAD_BALANCERS=/tmp/athena-$ID-lbs.json
  RESULTS=/tmp/athena-$ID-results.json
  echo "using LB file $LOAD_BALANCERS"
  echo "using result file $RESULTS"
fi
