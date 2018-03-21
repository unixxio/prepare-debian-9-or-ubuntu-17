# Prepare Debian 9 Stretch

This script will help you setup your freshly installed Debian server. It will:

* Set a hostname
* Set a static IP (or leave DHCP on)
* Set Google DNS resolvers (or enter your own nameservers)
* Add SSH key (optional)
* Install basic tools like `openssh-server`, `sudo`, `net-tools`, `rsync`, `curl` and `htop`
* Remove 127.0.1.1 from `/etc/hosts`
* Allow root login from SSH (make sure only you can access port 22)
* Update apt-repo
* Update debian

#### Step 1 - Download and install script

```
wget -q https://raw.githubusercontent.com/unixxio/prepare-debian-9-stretch/master/prepare_debian_9.sh
```

#### Step 2 - Execute install script

```
sudo chmod +x prepare_debian_9.sh && sudo ./prepare_debian_9.sh
```
