#!/bin/bash
# author: https://www.unixx.io
# version: 22/03/2018 - v1.1 - First release

# requirements
rm dhcp.tmp.txt > /dev/null 2>&1 && rm google.dns.txt > /dev/null 2>&1 && rm sshkey.tmp.txt > /dev/null 2>&1

echo -e "\n[ \e[92mWaiting for the installation to start. First installing some requirements. Please wait ... \e[39m]"

# prepare sources.list
cat << EOF > /etc/apt/sources.list
deb http://ftp.nl.debian.org/debian/ stretch main
deb-src http://ftp.nl.debian.org/debian/ stretch main

deb http://security.debian.org/debian-security stretch/updates main
deb-src http://security.debian.org/debian-security stretch/updates main

# stretch-updates, previously known as 'volatile'
deb http://ftp.nl.debian.org/debian/ stretch-updates main
deb-src http://ftp.nl.debian.org/debian/ stretch-updates main
EOF

# update debian and packages
apt-get update -y > /dev/null 2>&1 && apt-get upgrade -y > /dev/null 2>&1

# install packages
apt-get install sudo openssh-server net-tools rsync unzip curl htop -y > /dev/null 2>&1

# set variables
dhcp_ip=`ifconfig | awk {'print $2'} | head -2 | tail -1`
dhcp_netmask=`ifconfig | awk {'print $4'} | head -2 | tail -1`
dhcp_gateway=`route -nee | awk {'print $2'} | head -3 | tail -1`
google_dns1="8.8.8.8"
google_dns2="8.8.4.4"

# questions
echo -e -n "\n[ \e[92mPlease enter a hostname (example: debian.domain.local) \e[39m]: "
read hostname

dhcp_question="[ \e[92mDo you want to use DHCP? \e[39m]: "
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

ssh_question="[ \e[92mDo you want to add a SSH key? \e[39m]: "
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

# empty line
echo ""

# summery of above questions
echo -e "[ \e[92mInstallation overview \e[39m]"
echo ""
echo "--"
echo ""
echo -e "[ \e[92mHostname \e[39m]           : [ \e[92m${hostname} \e[39m]"
echo ""
if [ `cat dhcp.tmp.txt` == "false"  ] ;then
 echo -e "[ \e[92mIP adres \e[39m]           : [ \e[92m${static_ip} \e[39m]"
 echo -e "[ \e[92mSubnet \e[39m]             : [ \e[92m${netmask} \e[39m]"
 echo -e "[ \e[92mGateway \e[39m]            : [ \e[92m${gateway} \e[39m]"
else
 echo -e "[ \e[92mIP adres \e[39m]           : [ \e[92m${dhcp_ip} \e[39m]"
 echo -e "[ \e[92mSubnet \e[39m]             : [ \e[92m${dhcp_netmask} \e[39m]"
 echo -e "[ \e[92mGateway \e[39m]            : [ \e[92m${dhcp_gateway} \e[39m]"
fi
echo ""
if [ `cat google.dns.txt` == "true"  ] ;then
 echo -e "[ \e[92mNameserver 1 \e[39m]       : [ \e[92m${google_dns1} \e[39m]"
 echo -e "[ \e[92mNameserver 2 \e[39m]       : [ \e[92m${google_dns2} \e[39m]"
else
 echo -e "[ \e[92mNameserver 1 \e[39m]       : [ \e[92m${nameserver_1} \e[39m]"
 echo -e "[ \e[92mNameserver 2 \e[39m]       : [ \e[92m${nameserver_2} \e[39m]"
fi
if [ `cat sshkey.tmp.txt` == "true"  ] ;then
 echo ""
 echo -e "[ \e[92mSSH key \e[39m]            : [ \e[92m${ssh_key} \e[39m]"
fi
echo ""
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

echo ""
# waiting for installations
echo -e "[ \e[92mWaiting while installation is being completed ... \e[39m]"
echo ""

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

# set hostname for debian
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
  echo -e "[ \e[92mWarning \e[39m]: [ \e[92mServer will be rebooted \e[39m]"
  echo -e "[ \e[92mIP after boot \e[39m]: [ \e[92m${static_ip} \e[39m]"
else
  echo -e "[ \e[92mWarning \e[39m]: [ \e[92mServer will be rebooted \e[39m]"
  echo -e "[ \e[92mIP after boot \e[39m]: [ \e[92m${dhcp_ip} \e[39m]"
fi

# cleanup installation
rm dhcp.tmp.txt > /dev/null 2>&1 && rm google.dns.txt > /dev/null 2>&1 && rm sshkey.tmp.txt > /dev/null 2>&1

# start check
summary_question="\n[ \e[92mDo you want to continue? \e[39m]:"
ask_summary_question=`echo -e $summary_question`

read -r -p "${ask_summary_question} [y/N] " question_response
case "${question_response}" in
    [yY][eE][sS]|[yY])
        # restart networking
        #service ssh restart
        #ifdown ${network_interface} > /dev/null 2>&1
        #ifup ${network_interface} > /dev/null 2>&1
        reboot
        ;;
    *)
        exit
        ;;
    *)
esac
# end check

exit
