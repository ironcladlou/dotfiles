#!/usr/bin/env ruby

require 'yaml'
require 'optparse'

yml = YAML.load(STDIN.read)

opts = {
  :users => [],
  :verbs => [],
}
OptionParser.new do |parser|
  parser.on('--users=NAME') do |names|
    opts[:users] = names.split(",")
  end
  parser.on('--verbs=NAME') do |verbs|
    opts[:verbs] = verbs.split(",")
  end
end.parse!

records = {}
yml["items"].each do |item|
  resource = item["metadata"]["name"]
  item["status"]["last24h"].each do |last|
    next unless last.has_key?("byNode")
    last["byNode"].each do |by_node|
      next unless by_node.has_key?("byUser")
      by_node["byUser"].each do |by_user|
        by_user["byVerb"].each do |by_verb|
          username = by_user["username"]
          verb = by_verb["verb"]
          
          next unless opts[:users].empty? or opts[:users].include?(username)
          next unless opts[:verbs].empty? or opts[:verbs].include?(verb)
          
          unless records.has_key?(username)
            records[username] = {}
          end

          unless records[username].has_key?(resource)
            records[username][resource] = {}
          end

          unless records[username][resource].has_key?(verb)
            records[username][resource][verb] = 0
          end

          records[username][resource][verb] += by_verb["requestCount"]
        end
      end
    end
  end
end

puts YAML.dump(records)
