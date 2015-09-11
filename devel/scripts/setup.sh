#!/bin/sh -eux

# Update apk packages

apk update
apk upgrade


# Install open vmware tools

apk add open-vm-tools
rc-update add vmware-modules-grsec sysinit
rc-update add open-vm-tools default
rc-update -u

rm /sbin/mount.vmhgfs
ln -s /usr/sbin/mount.vmhgfs /sbin/

mkdir /mnt/hgfs

echo '.host:/ /mnt/hgfs vmhgfs  defaults  0 0' >> /etc/fstab


# Configure sshd

echo "UseDNS no" >> /etc/ssh/sshd_config


# Add and configure vagrant user

apk add curl
adduser -D vagrant
echo "vagrant:vagrant" | chpasswd
mkdir /home/vagrant/.ssh
curl -o /home/vagrant/.ssh/authorized_keys \
	    'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub'
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# Add vagrant user to readproc so lsmod will work when looking for 
adduser vagrant readproc

# Configure sudo

apk add sudo
adduser vagrant wheel

echo "Defaults exempt_group=wheel" > /etc/sudoers
echo "%wheel ALL=NOPASSWD:ALL" >> /etc/sudoers
