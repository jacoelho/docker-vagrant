# -*- mode: ruby -*-
# vi: set ft=ruby :

# Settings

$vm_gui     = false
$vm_memory  = 1024
$vm_cpus    = 1
$vm_use_nfs = false
$vm_ip      = "192.168.10.10"

ROOT = File.dirname(File.absolute_path(__FILE__))
VAGRANTFILE_API_VERSION = '2'

%w(vagrant-triggers).each do |plugin|
  unless Vagrant.has_plugin? plugin
    system "vagrant plugin install #{plugin}"
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "default", autostart: false do |default|
    default.vm.define "boot2docker"
    default.vm.box = "boxcutter/ubuntu1404-docker"
    default.vm.post_up_message = <<-EOF
Congratulations! Your machine is up and running.
Make sure you have the following variable set to use docker:
  export DOCKER_HOST='tcp://localhost:2375'

All your containers are accessible using <container_name>.docker
EOF

    default.vm.network "private_network", ip: $vm_ip , nic_type: "82545EM"
    # Forward the Docker port
    default.vm.network :forwarded_port, guest: 2375, host: 2375

    if $vm_use_nfs
      default.vm.synced_folder ROOT, ROOT,
        type: "nfs",
        mount_options: ["nolock", "vers=3", "tcp"]
      default.nfs.map_uid = Process.uid
      default.nfs.map_gid = Process.gid
    else
      default.vm.synced_folder ROOT, ROOT
    end

    default.vm.provider "virtualbox" do |v|
      v.gui    = $vm_gui
      v.name   = "vagrant_boot2docker"
      v.cpus   = $vm_cpus
      v.memory = $vm_memory

      # Disable VirtualBox DNS proxy as it may cause issues.
      # See https://github.com/docker/machine/pull/1069
      v.customize ['modifyvm', :id, '--natdnshostresolver1', 'off']
      v.customize ['modifyvm', :id, '--natdnsproxy1', 'off']
    end

    default.vm.provision "shell" do |s|
      s.inline = <<-EOF
        echo 'DOCKER_OPTS="--tls=false -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 --dns 8.8.8.8 --dns 8.8.4.4"' | sudo tee /etc/default/docker
        sudo service docker restart
      EOF
    end


    default.trigger.after [:provision, :up, :reload] do
      system <<-EOF
        sudo route add -net 172.17.0.0/16 #{$vm_ip}
        sudo mkdir -p /etc/resolver
        echo "nameserver #{$vm_ip}" | sudo tee /etc/resolver/docker
      EOF
    end

    default.trigger.after [:halt, :destroy] do
      system <<-EOF
        sudo route delete -net 172.17.0.0/16 #{$vm_ip}
      EOF
    end
  end

  config.vm.define "dev" do |dev|
    dev.vm.provider "docker" do |dns|
      dns.vagrant_vagrantfile = __FILE__
      dns.image               = "mgood/resolvable"
      dns.name                = "resolvable"
      dns.volumes             = ["/var/run/docker.sock:/tmp/docker.sock"]
      dns.ports               = ["53/udp:53/udp"]
      dns.remains_running     = true
    end
  end

end
