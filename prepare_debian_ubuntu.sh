#!/bin/bash
# author: https://www.unixx.io

# set script version
script_version="1.2"
script_date="22/03/2018"

# requirements
rm dhcp.tmp.txt > /dev/null 2>&1 && rm google.dns.txt > /dev/null 2>&1 && rm sshkey.tmp.txt > /dev/null 2>&1

# get linux version
ubuntu=`cat /etc/os-release | grep ID | head -1 | cut -d= -f2-`
debian=`cat /etc/os-release | grep ID | tail -1 | cut -d= -f2-`

echo -e "\n[ \e[92mScript version \e[39m]  : [ ${script_version} ]"
echo -e "[ \e[92mScript date \e[39m]     : [ ${script_date} ]"

if [[ ${ubuntu} == ubuntu ]]; then
  echo -e "[ \e[92mDetected linux \e[39m]  : [ Ubuntu ]"
  echo -e "\n[ \e[92mPlease wait while we update Ubuntu and packages \e[39m]"
fi
if [[ ${debian} == debian ]]; then
  echo -e "[ \e[92mDetected linux \e[39m]  : [ Debian ]"
  echo -e "\n[ \e[92mPlease wait while we update Debian and packages \e[39m]"
fi

# prepare sources.list
if [[ ${ubuntu} == ubuntu ]]; then
# clear existing sources.list
> /etc/apt/sources.list
cat <<EOF>> /etc/apt/sources.list
# default
deb http://nl.archive.ubuntu.com/ubuntu/ artful main restricted
deb http://nl.archive.ubuntu.com/ubuntu/ artful-updates main restricted

# universe
deb http://nl.archive.ubuntu.com/ubuntu/ artful universe
deb http://nl.archive.ubuntu.com/ubuntu/ artful-updates universe

# multiverse
deb http://nl.archive.ubuntu.com/ubuntu/ artful multiverse
deb http://nl.archive.ubuntu.com/ubuntu/ artful-updates multiverse

# backports
deb http://nl.archive.ubuntu.com/ubuntu/ artful-backports main restricted universe multiverse

# security
deb http://security.ubuntu.com/ubuntu artful-security main restricted
deb http://security.ubuntu.com/ubuntu artful-security universe
deb http://security.ubuntu.com/ubuntu artful-security multiverse
EOF
fi
if [[ ${debian} == debian ]]; then
# clear existing sources.list
> /etc/apt/sources.list
cat << EOF > /etc/apt/sources.list
deb http://ftp.nl.debian.org/debian/ stretch main
deb-src http://ftp.nl.debian.org/debian/ stretch main

deb http://security.debian.org/debian-security stretch/updates main
deb-src http://security.debian.org/debian-security stretch/updates main

# stretch-updates, previously known as 'volatile'
deb http://ftp.nl.debian.org/debian/ stretch-updates main
deb-src http://ftp.nl.debian.org/debian/ stretch-updates main
EOF
fi

# update linux and packages
apt-get update -y > /dev/null 2>&1 && apt-get upgrade -y > /dev/null 2>&1

# install packages
apt-get install openssh-server net-tools sudo bash-completion rsync unzip curl htop pwgen -y > /dev/null 2>&1

echo -e "[ \e[92mok \e[39m] - [ Updating finished ]"

# set variables
dhcp_ip=`ifconfig | awk {'print $2'} | head -2 | tail -1`
dhcp_netmask=`ifconfig | awk {'print $4'} | head -2 | tail -1`
dhcp_gateway=`route -nee | awk {'print $2'} | head -3 | tail -1`
google_dns1="8.8.8.8"
google_dns2="8.8.4.4"

# questions
echo -e "\n[ \e[92mPlease enter a hostname \e[39m]"
echo -e -n "[ \e[92mexample:\e[39m host.domain.local ]: "
read hostname

dhcp_question="\n[ \e[92mDo you want to use DHCP? \e[39m]: "
ask_dhcp_question=`echo -e $dhcp_question`

read -r -p "${ask_dhcp_question} [y/N] " question_response
case "${question_response}" in
    [yY][eE][sS]|[yY])
        # do nothing
        echo "true" > dhcp.tmp.txt
        ;;
    *)
        echo -e -n "[ \e[92mPlease enter a static IP \e[39m]: "
        read static_ip
        echo "false" > dhcp.tmp.txt

        echo -e -n "[ \e[92mPlease enter a subnet mask \e[39m]: "
        read netmask

        echo -e -n "[ \e[92mPlease enter a gateway \e[39m]: "
        read gateway
        ;;
    *)
esac

google_question="[ \e[92mDo you want to use Google's DNS resolvers? \e[39m]: "
ask_google_question=`echo -e $google_question`

read -r -p "${ask_google_question} [y/N] " question_response
case "${question_response}" in
    [yY][eE][sS]|[yY])
        echo "true" > google.dns.txt
        ;;
    *)
        echo "false" > google.dns.txt
        echo -e -n "[ \e[92mPlease enter first nameserver \e[39m]: "
        read nameserver_1

        echo -e -n "[ \e[92mPlease enter second nameserver \e[39m]: "
        read nameserver_2
        ;;
    *)
esac

ssh_question="\n[ \e[92mDo you want to add a SSH key? \e[39m]: "
ask_ssh_question=`echo -e $ssh_question`

read -r -p "${ask_ssh_question} [y/N] " question_response
case "${question_response}" in
    [yY][eE][sS]|[yY])
        echo -e -n "[ \e[92mPlease enter your SSH key \e[39m]: "
        read ssh_key
        echo "true" > sshkey.tmp.txt
        ;;
    *)
        echo "false" > sshkey.tmp.txt
        ;;
    *)
esac

# summery of above questions
echo -e "\n--"
echo -e "[ \e[92mHostname \e[39m]        : [ ${hostname} ]"
echo ""
if [ `cat dhcp.tmp.txt` == "false"  ] ;then
 echo -e "[ \e[92mIP adres \e[39m]        : [ ${static_ip} ]"
 echo -e "[ \e[92mSubnet \e[39m]          : [ ${netmask} ]"
 echo -e "[ \e[92mGateway \e[39m]         : [ ${gateway} ]"
else
 echo -e "[ \e[92mIP adres \e[39m]        : [ ${dhcp_ip} ]"
 echo -e "[ \e[92mSubnet \e[39m]          : [ ${dhcp_netmask} ]"
 echo -e "[ \e[92mGateway \e[39m]         : [ ${dhcp_gateway} ]"
fi
echo ""
if [ `cat google.dns.txt` == "true"  ] ;then
 echo -e "[ \e[92mNameserver 1 \e[39m]    : [ ${google_dns1} ]"
 echo -e "[ \e[92mNameserver 2 \e[39m]    : [ ${google_dns2} ]"
else
 echo -e "[ \e[92mNameserver 1 \e[39m]    : [ ${nameserver_1} ]"
 echo -e "[ \e[92mNameserver 2 \e[39m]    : [ ${nameserver_2} ]"
fi
if [ `cat sshkey.tmp.txt` == "true"  ] ;then
 echo ""
 echo -e "[ \e[92mSSH key \e[39m]         : [ ${ssh_key} ]"
fi
echo "--"

# start check
summary_question="\n[ \e[92mIs the above information correct? \e[39m]:"
ask_summary_question=`echo -e $summary_question`

read -r -p "${ask_summary_question} [y/N] " question_response
case "${question_response}" in
    [yY][eE][sS]|[yY])
        # do nothing
        ;;
    *)
        exit
        ;;
    *)
esac
# end check

# get network interface (needed for setting static ip below)
network_interface=`ifconfig | awk {'print $1'} | head -1 | tr -d ':'`

# set static ip
if [ `cat dhcp.tmp.txt` == "false"  ] ;then
cat << EOF > /etc/network/interfaces
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto ${network_interface}
iface ${network_interface} inet static
        address ${static_ip}
        netmask ${netmask}
        gateway ${gateway}
EOF
else
cat << EOF > /etc/network/interfaces
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug ${network_interface}
iface ${network_interface} inet dhcp
EOF
fi

# set nameservers
if [ `cat google.dns.txt` == "true"  ] ;then
cat << EOF > /etc/resolv.conf
nameserver ${google_dns1}
nameserver ${google_dns2}
EOF
else
cat << EOF > /etc/resolv.conf
nameserver ${nameserver_1}
nameserver ${nameserver_2}
EOF
fi

# remove 127.0.1.1 from hosts file
sed -i '/127.0.1.1/d' /etc/hosts

# set hostname for server
echo "${hostname}" > /etc/hostname
echo "${hostname}" > /etc/mailname

# allow root ssh login
sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# install ssh key
if [ `cat sshkey.tmp.txt`  == "true"  ] ;then
  mkdir /root/.ssh > /dev/null 2>&1 && chmod 700 /root/.ssh
  echo "${ssh_key}" > /root/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys
fi

# ask question and give warning before restarten network
if [ `cat dhcp.tmp.txt` == "false"  ] ;then
  echo -e "\n[ \e[92ok \e[39m] - [ Installation finished ]"
  echo -e "[ \e[92mIP adres \e[39m]        : [ ${static_ip} ]"
else
  echo -e "\n[ \e[92mok \e[39m] - [ Installation finished ]"
  echo -e "[ \e[92mIP adres \e[39m]        : [ ${dhcp_ip} ]"
fi

# cleanup installation
rm dhcp.tmp.txt > /dev/null 2>&1 && rm google.dns.txt > /dev/null 2>&1 && rm sshkey.tmp.txt > /dev/null 2>&1

echo -e "\n[ The server will be rebooted ]"

# start check
summary_question="[ \e[92mDo you want to continue? \e[39m]:"
ask_summary_question=`echo -e $summary_question`

read -r -p "${ask_summary_question} [y/N] " question_response
case "${question_response}" in
    [yY][eE][sS]|[yY])
        # reboot linux
        reboot
        ;;
    *)
        exit
        ;;
    *)
esac
# end check

exit
