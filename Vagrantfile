# -*- mode: ruby -*-
# vi: set ft=ruby :

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
    provider.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000 ]
  end

  config.vm.provider :vmware_fusion do |provider, override|
    provider.vmx["memsize"] = "4096"
    provider.vmx["numvcpus"] = "2"
    provider.vmx["ethernet1.pcislotnumber"] = "33"
  end
end
