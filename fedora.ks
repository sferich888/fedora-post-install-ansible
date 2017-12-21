#platform=x86, AMD64, or Intel EM64T
#version=DEVEL
#Install OS instead of upgrade
install

# Use network installation
url --url="https://download.fedoraproject.org/pub/fedora/linux/releases/27/Everything/x86_64/os/"

# Use graphical install
graphical
#text

# Do not run the Setup Agent on first boot
firstboot --disable

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# Firewall configuration
firewall --enabled

# System language
lang en_US.UTF-8

# Network information
#network  --bootproto=dhcp --ipv6=auto --activate --hostname=HOSTNAME
%include /tmp/hostname

# Root password
#rootpw --plaintext PASSWORD
%include /tmp/rootpw


# System timezone
timezone America/New_York --isUtc --ntpservers=0.fedora.pool.ntp.org 1.fedora.pool.ntp.org

# System services
services --enabled="chronyd,oddjobd"

#System Authorization Information
#user --name=USERNAME --password=USERPASSWORD --plaintext --groups=wheel
%include /tmp/user

# X Window System configuration information
xconfig  --startxonboot

# System bootloader configuration
bootloader --location=mbr 
zerombr

#Automatically configure disks
#autopart --type=lvm --encrypted --passphrase PASSWORD
%include /tmp/autopart

# Partition clearing information
clearpart --all --initlabel

# Disable firstboot
firstboot --disabled

# Selinux
selinux --enforcing
#selinux --permissive

# Reboot after installation
reboot

%pre
exec < /dev/tty3 > /dev/tty3 2>&1
chvt 3
# Setup Username and Password
read -ep "Set username: " USERNAME
while true
  do
    echo -en "\nSet User Password: "
    read -s upw1
    echo -en "\nVerify: "
    read -s upw2
  if [[ $upw1 = $upw2 ]]; then
    USERPASSWORD=$upw2
    break 2
  else
    echo -e "\nPasswords do not match"
  fi
done
echo "$USERNAME" > /tmp/username
echo "user --name=$USERNAME --password=$USERPASSWORD --plaintext --groups=wheel" > /tmp/user

# LUKS password
while true
  do
    echo -en "\nSet LUKS Encryption Password: "
    read -s lpw1
    echo -en "\nVerify: "
    read -s lpw2
  if [[ $lpw1 = $lpw2 ]]; then
    LUKSPW=$lpw2
    break 2
  else
    echo -e "\nPasswords do not match"
  fi
done
echo "autopart --type=lvm --encrypted --passphrase=$LUKSPW" > /tmp/autopart

# root Password
while true
  do
    echo -en "\nSet root Password: "
    read -s rpw1
    echo -en "\nVerify: "
    read -s rpw2
  if [[ $rpw1 = $rpw2 ]]; then
    ROOTPW=$rpw2
    break 2
  else
    echo -e "\nPasswords do not match"
  fi
done
echo "rootpw --plaintext $ROOTPW" >/tmp/autopart

# Set Hostname
read -ep "Set hostname: " HOSTNAME
echo "network --noipv6 --activate --bootproto=dhcp --hostname=$HOSTNAME" >/tmp/hostname
chvt 6
%end

%post --interpreter=/bin/bash
PRIMARY_USERNAME=$(</tmp/username)
git clone https://github.com/sferich888/fedora-post-install-ansible.git /home/$PRIMARY_USERNAME/fedora-post-install
%end

%packages
@^workstation-product-environment
oddjob
libselinux-python
ansible
git
%end

%addon com_redhat_kdump --reserve-mb='128'

%end

%anaconda
pwpolicy root --minlen=0 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy user --minlen=0 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=0 --minquality=1 --notstrict --nochanges --emptyok
%end
