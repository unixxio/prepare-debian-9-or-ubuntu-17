# Prepare Debian 9 Stretch or Ubuntu 17.10 Artful

This script will help you setup your freshly installed linux server. It will:

* Set a hostname
* Set a static IP (or leave DHCP on)
* Set Google DNS resolvers (or enter your own nameservers)
* Add SSH key (optional)
* Install basic tools like `openssh-server`, `sudo`, `net-tools`, `rsync`, `curl` and `htop`
* Remove 127.0.1.1 from `/etc/hosts`
* Allow root login from SSH (make sure only you can access port 22)
* Update apt-repo
* Update linux

#### Step 1 - Download and install script

```
wget -q https://raw.githubusercontent.com/unixxio/prepare-debian-9-stretch/master/prepare_debian_ubuntu.sh
```

#### Step 2 - Execute install script

```
sudo chmod +x prepare_debian_ubuntu.sh && sudo ./prepare_debian_ubuntu.sh
```

#### Tested on

* Debian 9 Stretch
* Ubuntu 17.10

#### Changelog (D/m/Y)

* 22/03/2018 - v1.2 - Add Ubuntu support
* 22/03/2018 - v1.1 - Minor updates
* 14/03/2018 - v1.0 - First release
