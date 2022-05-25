#!/usr/bin/env ruby

require 'json'

namespaces = JSON.load(`oc --context /api-hive-9xw5-p1-openshiftapps-com:6443/dmace get namespaces -o json`)["items"]

namespaces.each do |ns|
  ns = ns["metadata"]["name"]
  next unless ns.start_with?("hypershift-ocp")
  pods = JSON.load(`oc --context /api-hive-9xw5-p1-openshiftapps-com:6443/dmace get -n #{ns} pods -o json`)["items"]
  pods.each do |pod|
    name = pod["metadata"]["name"]
    puts "========= #{name} ==========="
    puts `oc --context /api-hive-9xw5-p1-openshiftapps-com:6443/dmace logs --tail 100 -n #{ns} pods/#{name} -c hive`
  end
end
