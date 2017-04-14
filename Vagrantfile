# -*- mode: ruby -*-
# vi: set ft=ruby :

$ip = '192.168.99.13'
$provision = <<SCRIPT
/bin/bash <<EOF
# Prereqs
sudo apt-get install -y curl git g++

# Install RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm

# Install ruby
rvm install 2.3.1
rvm use 2.3.1
gem install bundler

# Install javascript engine
sudo apt-get install -y nodejs

# Install java
echo 'deb http://httpredir.debian.org/debian jessie-backports main contrib non-free' | sudo tee /etc/apt/sources.list.d/backports.list
sudo apt-get update
sudo apt-get install -y -t jessie-backports ca-certificates-java openjdk-8-jre openjdk-8-jre-headless

# Install neo4j
sudo apt-get install apt-transport-https
wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
echo 'deb https://debian.neo4j.org/repo stable/' | sudo tee /etc/apt/sources.list.d/neo4j.list
sudo apt-get update
sudo apt-get install -y neo4j

echo 'dbms.security.auth_enabled=false' | sudo tee -a /etc/neo4j/neo4j.conf
echo 'dbms.connectors.default_listen_address=0.0.0.0' | sudo tee -a /etc/neo4j/neo4j.conf
sudo systemctl restart neo4j

# Capybara Browser Test
sudo apt-get install -y xvfb libqtwebkit-dev
cat <<EOX | sudo tee /etc/systemd/system/xvfb.service
[Unit]
Description=Virtual Frame Buffer X Server
After=network.target

[Service]
ExecStart=/usr/bin/Xvfb :10 -screen 0 1024x768x24 -ac +extension GLX +render -noreset

[Install]
WantedBy=multi-user.target
EOX

sudo systemctl daemon-reload
sudo systemctl enable xvfb
sudo service xvfb start

echo 'export DISPLAY=:10' | sudo tee /etc/profile.d/display.sh
sudo chmod +x /etc/profile.d/display.sh
EOF
SCRIPT

Vagrant.configure("2") do |config|
  if not Vagrant.has_plugin? 'vagrant-vbguest'
    fail_with_message "vagrant-vbguest plugin missing.  Please install it with this command:\nvagrant plugin install vagrant-vbguest"
  end

  if not Vagrant.has_plugin? 'vagrant-bindfs'
    fail_with_message "vagrant-bindfs plugin missing.  Please install it with this command:\nvagrant plugin install vagrant-bindfs"
  end

  config.vm.box = "debian/jessie64"
  config.vm.hostname = "graphghist"
  config.vm.network "private_network", ip: $ip
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  config.vm.provision "shell", inline: $provision, privileged: false
end


def fail_with_message(msg)
  fail Vagrant::Errors::VagrantError.new, msg
end
