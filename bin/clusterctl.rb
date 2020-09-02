#!/usr/bin/env ruby

require 'json'
require 'yaml'
require 'securerandom'
require 'etc'
require 'optparse'
require 'fileutils'
require 'tmpdir'

$ip_families = {
  :azure => :v4,
  :azureovn => :v4,
  :azureipv6 => :v6,
  :aws => :v4,
  :gcp => :v4,
  :vsphere => :v4,
}

$templates = {}

$templates[:azure] = <<EOF
apiVersion: v1
baseDomain: catchall.azure.devcluster.openshift.com
clusterID: %{cluster_id}
metadata:
  name: %{cluster_name}
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 3
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineCIDR: 10.0.0.0/16
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
  azure:
    baseDomainResourceGroupName: os4-common
    region: centralus
pullSecret: '%{pull_secret}'
sshKey: '%{ssh_key_contents}'
EOF

$templates[:azureovn] = <<EOF
apiVersion: v1
baseDomain: networkedge.azure.devcluster.openshift.com
clusterID: %{cluster_id}
metadata:
  name: %{cluster_name}
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 3
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineCIDR: 10.0.0.0/16
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.30.0.0/16
platform:
  azure:
    baseDomainResourceGroupName: os4-common
    region: centralus
pullSecret: '%{pull_secret}'
sshKey: '%{ssh_key_contents}'
EOF

$templates[:azureipv6] = <<EOF
apiVersion: v1
baseDomain: networkedge.azure.devcluster.openshift.com
clusterID: %{cluster_id}
metadata:
  name: %{cluster_name}
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 3
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
networking:
  clusterNetwork:
  - cidr: fd01::/48
    hostPrefix: 64
  machineNetwork:
  - cidr: 10.0.0.0/16
  - cidr: fd00::/48
  networkType: OVNKubernetes
  serviceNetwork:
  - fd02::/112
platform:
  azure:
    baseDomainResourceGroupName: os4-common
    region: centralus
pullSecret: '%{pull_secret}'
sshKey: '%{ssh_key_contents}'
EOF

$templates[:aws] = <<EOF
apiVersion: v1
baseDomain: devcluster.openshift.com
clusterID: %{cluster_id}
machines:
- name: master
  replicas: 3
- name: worker
  replicas: 3
metadata:
  name: %{cluster_name}
networking:
  clusterNetworks:
  - cidr: 10.128.0.0/14
    hostSubnetLength: 9
  machineCIDR: 10.0.0.0/16
  serviceCIDR: 172.30.0.0/16
  type: OpenshiftSDN
platform:
  aws:
    region: us-east-2
pullSecret: '%{pull_secret}'
sshKey: '%{ssh_key_contents}'
EOF

$templates[:vsphere] = <<EOF
apiVersion: v1
baseDomain: devcluster.openshift.com
clusterID: %{cluster_id}
metadata:
  name: %{cluster_name}
networking:
  machineNetwork:
  - cidr: "139.178.89.192/26"
platform:
  vsphere:
    vCenter: vcsa.vmware.devcluster.openshift.com
    username: '%{vsphere_username}'
    password: '%{vsphere_password}'
    datacenter: dc1
    defaultDatastore: nvme-ds1
pullSecret: '%{pull_secret}'
sshKey: '%{ssh_key_contents}'
EOF

$templates[:gcp] = <<EOF
apiVersion: v1
baseDomain: gcp.devcluster.openshift.com
clusterID: %{cluster_id}
metadata:
  name: %{cluster_name}
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineCIDR: 10.0.0.0/16
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
  gcp:
    region: us-east1
    projectID: openshift-gce-devel
pullSecret: '%{pull_secret}'
sshKey: '%{ssh_key_contents}'
EOF

$envrc = <<EOF
export KUBECONFIG=$PWD/auth/kubeconfig
PATH_add bin
EOF

def get_clients(version_url, version, cluster_dir)
  cluster_bin = File.join(cluster_dir, "bin")
  Dir.mkdir(cluster_bin)

  if version_url
    release = `curl #{version_url}/release.txt 2>&1 | grep Version: | awk '{ print $2}'`.chomp
    clients = ["openshift-install-mac-#{release}.tar.gz", "openshift-client-mac-#{release}.tar.gz"]
    cache_dir = File.join(Dir.tmpdir, "clusterctl")
    clients.each do |client|
      archive = File.join(cache_dir, client)
      unless File.exist?(archive)
        puts `wget -P #{cache_dir} #{version_url}/#{client}`
      end
      puts `tar zxf #{archive} --directory #{cluster_bin}`
      puts "downloaded client to #{cluster_bin}"
    end
  else
    release = `curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp/candidate-#{version}/release.txt 2>&1 | grep Version: | awk '{ print $2}'`.chomp
    # Try release candidates, and then nightlies
    # TODO: try GA releases
    if release.length == 0
      stream = "latest-#{version}"
      release = `curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp-dev-preview/#{stream}/release.txt 2>&1 | grep Version: | awk '{ print $2}'`.chomp
      clients = ["openshift-install-mac-#{release}.tar.gz", "openshift-client-mac-#{release}.tar.gz"]
      cache_dir = File.join(Dir.tmpdir, "clusterctl")
      clients.each do |client|
        archive = File.join(cache_dir, client)
        unless File.exist?(archive)
          puts `wget -P #{cache_dir} https://mirror.openshift.com/pub/openshift-v4/clients/ocp-dev-preview/#{stream}/#{client}`
        end
        puts `tar zxf #{archive} --directory #{cluster_bin}`
        puts "downloaded client to #{cluster_bin}"
      end
    else
      clients = ["openshift-install-mac-#{release}.tar.gz", "openshift-client-mac-#{release}.tar.gz"]
      cache_dir = File.join(Dir.tmpdir, "clusterctl")
      clients.each do |client|
        archive = File.join(cache_dir, client)
        unless File.exist?(archive)
          puts `wget -P #{cache_dir} https://mirror.openshift.com/pub/openshift-v4/clients/ocp/candidate-#{version}/#{client}`
        end
        puts `tar zxf #{archive} --directory #{cluster_bin}`
        puts "downloaded client to #{cluster_bin}"
      end
    end
  end
end

def prepare_cluster(opts, platform_meta={})
  uuid = SecureRandom.uuid
  meta = {
    :cluster_id => uuid,
    :cluster_name => "#{ENV['USER']}-#{uuid[0..3]}",
    :platform => opts.fetch(:platform),
    :image_override => opts.fetch(:image_override, ""),
    :docker_config => opts.fetch(:docker_config, "#{ENV['HOME']}/.docker/config-installer.json"),
    :ssh_key => opts.fetch(:ssh_key, "#{ENV['HOME']}/.ssh/id_rsa.pub"),
    :version => opts.fetch(:version, "4.5"),
    :version_url => opts.fetch(:version_url, nil)
  }
  meta.merge!(platform_meta)

  cluster_dir = File.expand_path(meta[:cluster_name])
  if Dir.exist?(cluster_dir)
    puts "cluster already exists at #{cluster_dir}"
    return
  end

  Dir.mkdir(cluster_dir)
  meta_file = File.join(cluster_dir, "metadata.yaml")
  File.write(meta_file, YAML.dump(meta))

  get_clients(meta[:version_url], meta[:version], cluster_dir)

  data = {
    :pull_secret => File.read(meta[:docker_config]).gsub("\n", '').squeeze(' '),
    :ssh_key_contents => File.read(meta[:ssh_key]).gsub("\n", '').squeeze(' ')
  }

  template = $templates[meta[:platform]]
  raise "unknown platform" unless template
  
  install_config = template % meta.merge(data)
  install_config_file = File.join(cluster_dir, "install-config.yaml")
  File.write(install_config_file, install_config)

  envrc = File.join(cluster_dir, ".envrc")
  File.write(envrc, $envrc)
  puts `direnv allow #{envrc}`

  puts "created cluster directory #{cluster_dir}"
  return meta, cluster_dir
end

def create(opts, platform_meta)
  meta, cluster_dir = prepare_cluster(opts, platform_meta)

  env = []
  env.push("OPENSHIFT_INSTALL_PRESERVE_BOOTSTRAP=true") if opts[:preserve_bootstrap]
  env.push("OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=#{meta[:image_override]}") if meta[:image_override]
  env.push("OPENSHIFT_INSTALL_AZURE_EMULATE_SINGLESTACK_IPV6=true") if $ip_families[meta[:platform]] == :v6

  installer = File.join(cluster_dir, "bin", "openshift-install")

  args = [
    "#{installer}",
    "create",
    "cluster",
    "--dir=#{cluster_dir}",
    "--log-level=debug",
    "2>&1",
    "|",
    "tee #{cluster_dir}/install.log",
  ]

  command = env.push(args).join(" ")
  puts "executing: #{command}"
  system(command, out: STDOUT)
end

def manifests(opts, platform_meta)
  meta, cluster_dir = prepare_cluster(opts, platform_meta)

  env = []
  env.push("OPENSHIFT_INSTALL_PRESERVE_BOOTSTRAP=true") if opts[:preserve_bootstrap]
  env.push("OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=#{meta[:image_override]}") if meta[:image_override]
  env.push("OPENSHIFT_INSTALL_AZURE_EMULATE_SINGLESTACK_IPV6=true") if $ip_families[meta[:platform]] == :v6

  installer = File.join(cluster_dir, "bin", "openshift-install")

  args = [
    "#{installer}",
    "create",
    "manifests",
    "--dir=#{cluster_dir}",
    "--log-level=debug",
  ]

  command = env.push(args).join(" ")
  puts "executing: #{command}"
  system(command, out: STDOUT)
end

def create_ignition_configs(opts, platform_meta)
  meta, cluster_dir = prepare_cluster(opts, platform_meta)

  installer = File.join(cluster_dir, "bin", "openshift-install")
  
  command = "OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=#{meta[:image_override]} #{installer} create ignition-configs --dir=#{cluster_dir} --log-level debug 2>&1 | tee #{cluster_dir}/create-ignition-configs.log"
  puts "executing: #{command}"
  system(command, out: STDOUT)
end

def prepare(opts, platform_meta)
  meta, cluster_dir = prepare_cluster(opts, platform_meta)

  puts "prepared cluster in #{cluster_dir}"
end

def delete(opts)
  cluster_dir = File.expand_path(opts[:cluster_name])
  unless Dir.exist?(cluster_dir)
    puts "no cluster found at #{cluster_dir}"
    return
  end

  meta_file = File.join(cluster_dir, "metadata.yaml")
  meta = YAML.load(File.read(meta_file))

  installer = File.join(cluster_dir, "bin", "openshift-install")

  env = []
  env.push("OPENSHIFT_INSTALL_PRESERVE_BOOTSTRAP=true") if opts[:preserve_bootstrap]
  env.push("OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=#{meta[:image_override]}") if meta[:image_override]
  env.push("OPENSHIFT_INSTALL_AZURE_EMULATE_SINGLESTACK_IPV6=true") if $ip_families[meta[:platform]] == :v6

  installer = File.join(cluster_dir, "bin", "openshift-install")

  args = [
    "#{installer}",
    "destroy",
    "cluster",
    "--dir=#{cluster_dir}",
    "--log-level=debug",
    "2>&1",
    "|",
    "tee #{cluster_dir}/destroy.log",
  ]

  command = env.push(args).join(" ")
  puts "executing: #{command}"
  system(command, out: STDOUT)
  
  # do delete
  trash_dir = File.join(Dir.tmpdir(), File.basename(cluster_dir))
  FileUtils.mv(cluster_dir, trash_dir)
  puts "moved cluster #{meta[:cluster_name]} to trash: #{trash_dir}"
end

def get_platform_meta(opts)
  meta = {}
  case opts[:platform]
  when :vsphere
    creds = JSON.load(File.read("#{ENV['HOME']}/.vsphere-creds.json"))
    meta[:vsphere_username] = creds["username"]
    meta[:vsphere_password] = creds["password"]
  when :azure
    # sub_id = `az account show | jq -r '.id'`.chomp
    # sp = `az ad sp create-for-rbac --role="Owner" --scopes="/subscriptions/#{sub_id}" --name "${NAME}-installer"`
    # echo "created new service principal:"
    # echo "$SP"
    # jq --arg SUB_ID "$SUB_ID" '{subscriptionId:$SUB_ID,clientId:.appId, clientSecret:.password,tenantId:.tenant}' <<< $SP >$sp_file
    # echo "created new credentials at $sp_file"
  end
  return meta
end

opts = {}
OptionParser.new do |parser|
  # options for create,create-ignition-configs
  parser.on('-p', '--platform=NAME') do |platform|
    opts[:platform] = platform.to_sym
  end
  # TODO: restore this to override downloading
  # parser.on('-i', '--installer=PATH') do |installer|
  #   opts[:installer] = installer
  # end
  parser.on('-s', '--ssh-key=PATH') do |ssh_key|
    opts[:ssh_key] = ssh_key
  end
  parser.on('-o', '--override=IMAGE') do |image|
    opts[:image_override] = image
  end
  parser.on('-v', '--version=VERSION') do |version|
    opts[:version] = version
  end
  parser.on('-u', '--url=URL') do |url|
    opts[:version_url] = url
  end
  parser.on('-b', '--preserve-bootstrap') do
    opts[:preserve_bootstrap] = true
  end

  # options for delete
  parser.on('-c', '--cluster=NAME') do |name|
    opts[:cluster_name] = name
  end
end.parse!

command = ARGV.pop.gsub("-","_").to_sym

case command
when :create
  create(opts, get_platform_meta(opts))
when :manifests
  manifests(opts, get_platform_meta(opts))
when :create_ignition_configs
  create_ignition_configs(opts, get_platform_meta(opts))
when :prepare
  prepare(opts, get_platform_meta(opts))
when :delete
  delete(opts)
when :nuke
  `ls -d */ | cut -f1 -d'/'`.chomp.each_line{|name| delete({:cluster_name => name})}
else
  puts "unrecognized command"
end
