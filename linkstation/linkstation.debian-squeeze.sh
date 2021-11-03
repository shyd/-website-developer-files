#!/bin/sh
#
# Install Debian Squeeze on LS-CHLv2

# Copyright (c) 2010 Jeff Doozan
# Edited and adapted to Buffalo Linkstation LS-CHLv2 by Dennis Schuett
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


# Version 1.0   [8/8/2010] Initial Release
# Version 1.1   [02/14/2011] modded for Linkstation

#wget http://dev.shyd.de/linkstation/linkstation.debian-squeeze.sh

# Definitions

# Download locations
MIRROR="http://dev.shyd.de/linkstation"

DEB_MIRROR="http://ftp.de.debian.org/debian"

URL_DEBOOTSTRAP="$DEB_MIRROR/pool/main/d/debootstrap/debootstrap_1.0.26_all.deb"

# Default binary locations
#MKE2FS=/sbin/mke2fs
#PKGDETAILS=/usr/share/debootstrap/pkgdetails

# Where should the temporary 'debian root' be mounted
ROOT=/root/debian

# Where to store the tarball
SHARE=/root

# debootstrap configuration
RELEASE=squeeze
VARIANT=minbase

# if you want to install additional packages, add them to the end of this list
#EXTRA_PACKAGES=udev,netbase,ifupdown,iproute,openssh-server,dhcpcd,iputils-ping,wget,net-tools,ntpdate,uboot-mkimage,uboot-envtools,vim-tiny
EXTRA_PACKAGES=makedev,netbase,ifupdown,iproute,openssh-server,dhcpcd,iputils-ping,wget,net-tools,ntpdate,vim-tiny





#########################################################
#  There are no user-serviceable parts below this line
#########################################################


TIMESTAMP=$(date +"%d%m%Y%H%M%S")
touch /sbin/$TIMESTAMP
if [ ! -f /sbin/$TIMESTAMP ]; then
  RO_ROOT=1
else
  rm /sbin/$TIMESTAMP
fi


if ! which chroot >/dev/null; then
  echo ""
  echo ""
  echo ""
  echo "ERROR. CANNOT CONTINUE."
  echo ""
  echo "Cannot find chroot.  You need to update your PATH."
  echo "Run the following command and then run this script again:"
  echo ""
  echo 'export PATH=$PATH:/sbin:/usr/sbin'
  echo ""
  exit 1
fi

echo ""
echo ""
echo "This script will create a complete rootfs for your LS-CHLv2"
echo "to boot Debian Squeeze."
echo ""
echo ""
echo "By typing ok, you agree to assume all liabilities and risks"
echo "associated with running this installer."
echo ""
echo -n "If everything looks good, type 'ok' to continue: "


read IS_OK
if [ "$IS_OK" != "OK" -a "$IS_OK" != "Ok" -a "$IS_OK" != "ok" ];
then
  echo "Exiting..."
  exit
fi



# Create the mount point if it doesn't already exist
if [ ! -f $ROOT ];
then
  mkdir -p $ROOT
fi


# Get the source directory
SRC=$ROOT


##########
##########
#
# Download debootstrap
#
##########
##########

if [ ! -e /usr/sbin/debootstrap ]; then
  mkdir /tmp/debootstrap
  cd /tmp/debootstrap
  wget -O debootstrap.deb $URL_DEBOOTSTRAP
  ar xv debootstrap.deb
  tar -xzvf data.tar.gz

  mv ./usr/sbin/debootstrap /usr/sbin
  mv ./usr/share/debootstrap /usr/share

  #install "$PKGDETAILS" "$PKGDETAILS_URL" 755

fi


##########
##########
#
# Run debootstrap
#
##########
##########

echo ""
echo ""
echo "# Starting debootstrap installation"

# Squeeze
/usr/sbin/debootstrap --verbose --arch=armel --variant=$VARIANT --include=$EXTRA_PACKAGES $RELEASE $ROOT $DEB_MIRROR

if [ "$?" -ne "0" ]; then
  echo "debootstrap failed."
  echo "See $ROOT/debootstrap/debootstrap.log for more information."
  exit 1
fi



cat <<END > $ROOT/etc/apt/apt.conf
APT::Install-Recommends "0";
APT::Install-Suggests "0";
END


echo debian > $ROOT/etc/hostname
echo LANG=C > $ROOT/etc/default/locale


cat <<END > $ROOT/etc/network/interfaces
auto lo eth1
iface lo inet loopback
iface eth1 inet dhcp
END

cat <<END > $ROOT/etc/fstab
# /etc/fstab: static file system information.
#
# file system    mount point   type    options                  dump pass
/dev/sda2        /             ext3    defaults,noatime         0    1
/dev/sda1        /boot         ext3    ro,nosuid,nodev          0    2
/dev/sda5        none          swap    sw                       0    0
/dev/sda6        /home         xfs     defaults,noatime         0    3
proc             /proc         proc    defaults                 0    0
devpts           /dev/pts      devpts  gid=4,mode=620 			0    0
tmpfs            /tmp          tmpfs   defaults                 0    0
sysfs            /sys          sysfs   defaults                 0    0
END


echo "root:\$1\$XPo5vyFS\$iJPfS62vFNO09QUIUknpm.:14360:0:99999:7:::" > $ROOT/etc/shadow

#cat <<END > $ROOT/etc/mtab
#proc /proc proc rw 0 0
#sysfs /sys sysfs rw 0 0
#END

echo ""
echo ""
echo "# Getting kernelmodules"

# Get kernelmodules from original kernel
cp /boot/initrd.buffalo $ROOT/tmp/
chroot $ROOT/ dd if=/tmp/initrd.buffalo of=/tmp/initrd.gz ibs=64 skip=1
chroot $ROOT/ gunzip /tmp/initrd.gz
chroot $ROOT/ mkdir /tmp/INITRD
chroot $ROOT/ mount -t ext2 -o loop /tmp/initrd /tmp/INITRD 
chroot $ROOT/ cp -R /tmp/INITRD/lib/modules/2.6.22.18 /lib/modules/
chroot $ROOT/ umount /tmp/INITRD
chroot $ROOT/ rmdir /tmp/INITRD
chroot $ROOT/ rm /tmp/initrd*


echo ""
echo ""
echo "# Creating tarball, this WILL take a while"

cd $ROOT
#tar zcf $SHARE/squeeze-rootfs.tgz *
tar cf $SHARE/squeeze-rootfs.tar *



##### All Done


echo ""
echo ""
echo ""
echo ""
echo "Installation complete"
echo ""
echo "You can now power off your Device and prepare the drive"
echo "to boot the created rootfs."
echo ""
echo "The new root password is 'root'  Please change it immediately after"
echo "logging in."
echo ""


