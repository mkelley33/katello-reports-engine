# -*- mode: ruby -*-
# vi: set ft=ruby :

KATELLO_GIT_CHECKOUT="../katello"
SST_GIT_CHECKOUT="../spacewalk-splice-tool"
KATELLOCLI_GIT_CHECKOUT="../katello-cli"
CLOUDE_GIT_CHECKOUT="../cloude"

$setup_script = <<EOF
cd /vagrant/devel_env/el6
./clear_prior_splice_install.sh | tee log_clear_prior_splice_install
./setup_katello_devel_env.sh | tee log_setup_katello_devel_env
./setup_splice_rails_engine.sh | tee log_setup_splice_rails_engine
./run_rails.sh
EOF


Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.
  config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", "2048"]
  end
  #config.vm.box = "rhel64_x86_64"
  #config.vm.box_url = "http://file.rdu.redhat.com/~jmatthew/vagrant/VirtualBox/rhel64_x86_64.box"
  config.vm.box = "CentOS-6.4-x86_64-v20130427"
  config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box"

  config.vm.hostname = "splice.example.com"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network :private_network, ip: "172.31.2.12"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network

  config.vm.synced_folder KATELLO_GIT_CHECKOUT, "/katello"
  config.vm.synced_folder SST_GIT_CHECKOUT, "/spacewalk-splice-tool"
  config.vm.synced_folder KATELLOCLI_GIT_CHECKOUT, "/katello-cli"
  config.vm.synced_folder CLOUDE_GIT_CHECKOUT, "/cloude"
  config.vm.provision :shell, :inline => $setup_script
      #:inline => "cd /vagrant/devel_env/el6 && ./clear_prior_splice_install.sh && ./setup_katello_devel_env.sh && ./setup_splice_rails_engine.sh"
end
