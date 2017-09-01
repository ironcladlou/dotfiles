# -*- mode: ruby -*-
# vi: set ft=ruby :

shares = [
  {
    src: "#{ENV['HOME']}/Projects/kubernetes/src/k8s.io/kubernetes",
    dest: "/home/vagrant/code/kubernetes/src/k8s.io/kubernetes",
    excludes: [
      ".git/",
      "_*",
      ".vscode/",
      ".vagrant/",
      ".make/",
      ".artifacts/",
      "_output/",
      "127*",
      "localhost*"
    ]
  }
]

Vagrant.configure(2) do |config|
  # Use VirtualBox by default
  config.vm.provider "virtualbox"

  config.vm.define "centos" do |machine|
    machine.vm.box = "bento/centos-7.3"
    machine.vm.network :private_network, ip: "192.168.4.2"
    machine.vm.hostname = "centos.local"
  end

  config.vm.define "fedora", autostart: false do |machine|
    machine.vm.box = "bento/fedora-26"
    machine.vm.network :private_network, ip: "192.168.4.3"
    machine.vm.hostname = "fedora.local"
  end
  
  config.vm.provider :virtualbox do |provider, override|
    provider.memory = 4096
    provider.cpus = 2

    # Use faster paravirtualized networking
    provider.customize ["modifyvm", :id, "--nictype1", "virtio"]
    provider.customize ["modifyvm", :id, "--nictype2", "virtio"]
  end

  config.vm.provider :vmware_fusion do |provider, override|
    provider.vmx["memsize"] = "4096"
    provider.vmx["numvcpus"] = "2"
    provider.vmx["ethernet1.pcislotnumber"] = "33"
  end

  # config.vm.provision :ansible do |ansible|
  #   ansible.tags = ENV['ANSIBLE_TAGS']
  #   ansible.verbose = "v"
  #   ansible.playbook = "ansible/playbook.yml"
  # end

  # shares.each do |share|
  #   config.vm.synced_folder share[:src], share[:dest], type: "rsync", rsync__exclude: share[:excludes]
  # end
end
