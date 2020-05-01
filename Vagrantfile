# -*- mode: ruby -*-
# vi: set ft=ruby :

$ip = '192.168.99.13'
$provision = <<SCRIPT
/bin/bash <<EOF

# sudo echo "deb [check-valid-until=no] http://cdn-fastly.deb.debian.org/debian jessie main" | sudo tee /etc/apt/sources.list.d/jessie.list
# sudo echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" | sudo tee /etc/apt/sources.list.d/jessie-backports.list
# sudo echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports contrib non-free" | sudo tee /etc/apt/sources.list.d/backports.list
# sudo sed -i '/deb\\?(-src) http:\\/\\/\\(deb\\|httpredir\\).debian.org\\/debian jessie.* main/d' /etc/apt/sources.list
# sudo apt-get -o Acquire::Check-Valid-Until=false update

# Prereqs
sudo apt-get install -y curl git g++ imagemagick dirmngr

# Install RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
# gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
curl -sSL https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm

# Install ruby
rvm install 2.3.1
rvm use 2.3.1
gem install bundler

# Install javascript engine
sudo apt-get install -y nodejs

# Install java
echo 'deb http://httpredir.debian.org/debian stretch-backports main contrib non-free' | sudo tee /etc/apt/sources.list.d/backports.list
sudo apt-get update
sudo apt-get install -y -t stretch-backports ca-certificates-java openjdk-8-jre openjdk-8-jre-headless

# Install neo4j
sudo apt-get install -y apt-transport-https
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
  # Workaround to prevent missing linux headers making new installs fail.
  # Put into Vagrantfile directly under your `config.vm.box` definition

  class WorkaroundVbguest < VagrantVbguest::Installers::Linux
    def install(opts=nil, &block)
          puts 'Ensuring we\'ve got the correct build environment for vbguest...'
          communicate.sudo('apt-get -y --force-yes update', (opts || {}).merge(:error_check => false), &block)
          communicate.sudo('apt-get -y --force-yes install -y build-essential linux-headers-amd64 linux-image-amd64', (opts || {}).merge(:error_check => false), &block)
          puts 'Continuing with vbguest installation...'
        super
          puts 'Performing vbguest post-installation steps...'
            communicate.sudo('usermod -a -G vboxsf vagrant', (opts || {}).merge(:error_check => false), &block)
    end
    def reboot_after_install?(opts=nil, &block)
      true
    end
  end

  config.vbguest.installer = WorkaroundVbguest
  # End workaround

  if not Vagrant.has_plugin? 'vagrant-vbguest'
    fail_with_message "vagrant-vbguest plugin missing.  Please install it with this command:\nvagrant plugin install vagrant-vbguest"
  end

  if not Vagrant.has_plugin? 'vagrant-bindfs'
    fail_with_message "vagrant-bindfs plugin missing.  Please install it with this command:\nvagrant plugin install vagrant-bindfs"
  end

  config.vm.box = "generic/debian9"
  config.vm.hostname = "graphghist"
  config.vm.network "private_network", ip: $ip
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  config.vm.provision "shell", inline: $provision, privileged: false
end


def fail_with_message(msg)
  fail Vagrant::Errors::VagrantError.new, msg
end
