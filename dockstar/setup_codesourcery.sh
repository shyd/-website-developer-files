#!/bin/bash

#
# Script name: install_codesourcery
# Version: 2.0 - 2010-03-21
#
# Copyright (C) 2009-2010  Matthias "Maddes" Buecher
#

#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# http://www.gnu.org/licenses/gpl-2.0.txt
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#


##
## Script Functions
##
function install_toolchain()
{
  echo "Installing ${VERSION}:"

  # Download toolchain
  wget -N -P ~ "${DLBASEPATH}/${DLFILE}"

  # Install toolchain (by extracting)
  echo "Extracting..."
  [ -d "${INSTALLPATH}" ] || mkdir -p "${INSTALLPATH}"
  tar -x --bzip2 -f ~/"${DLFILE}" -C "${INSTALLPATH}"

  # Create toolchain environment script
  echo "Creating script file ${SCRIPTFILE}..."
  cat >"${SCRIPTFILE}" << '__EOF'
#!/bin/bash
echo "Type 'exit' to return to non-crosscompile environment"
[ -n "${CROSS_COMPILE}" ] && { echo "ALREADY in crosscompile environment for ${ARCH} (${CROSS_COMPILE})"; exit; }
export PATH='${BINPATH}':${PATH}
export ARCH='${ARCHCODE}'
export CROSS_COMPILE='${CCPREFIX}'
echo "NOW in crosscompile environment for ${ARCH} (${CROSS_COMPILE})"
/bin/bash
echo 'Back in non-crosscompile environment'
__EOF
  sed -i -e "s%\${BINPATH}%${BINPATH}%g" -e "s%\${ARCHCODE}%${ARCHCODE}%g" -e "s%\${CCPREFIX}%${CCPREFIX}%g" "${SCRIPTFILE}"
  [ -x "${SCRIPTFILE}" ] || chmod +x "${SCRIPTFILE}"

  echo "Done."
}


###
### Install prerequisites
###

# --> general buildtools & development packages
#     wget & bzip2 for downloading and unpacking
#     uboot's mkimage & devio for creating uImage
echo "Installing prerequisites:"
PACKAGES='build-essential linux-libc-dev ncurses-dev wget bzip2 uboot-mkimage devio'
DOINSTALL=0
for PACKAGE in ${PACKAGES}
 do
  dpkg -l | grep -F -e "${PACKAGE}" >/dev/null
  DOINSTALL=$?
  [ "${DOINSTALL}" -ne 0 ] && break
done
[ "${DOINSTALL}" -ne 0 ] && {
  aptitude update;
  aptitude install ${PACKAGES};
}


###
### Install toolchains
###

### Codesourcery's toolchains
###   http://www.codesourcery.com/sgpp/lite_edition.html
###   (navigation: Products --> Sourcery G++ --> Editions --> Lite)
### Note: the toolchains for the different targets can be installed in parallel

## Installation path for Codesourcery toolchains and scripts
INSTALLPATH='/usr/local/codesourcery'
SCRIPTPATH='/usr/local/bin'
SCRIPTPREFIX='codesourcery-'

## -> ARM GNU/Linux target
ARCHCODE='arm'
#
CCPREFIX='arm-none-linux-gnueabi-'
DLBASEPATH='http://www.codesourcery.com/public/gnu_toolchain/arm-none-linux-gnueabi'
## (arm-2009q3)
VERSION='arm-2009q3'
DLFILE='arm-2009q3-67-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2'
BINPATH="${INSTALLPATH}/${VERSION}/bin"
SCRIPTFILE="${SCRIPTPATH}/${SCRIPTPREFIX}${VERSION}.sh"
install_toolchain
## (arm-2009q1)
VERSION='arm-2009q1'
DLFILE='arm-2009q1-203-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2'
BINPATH="${INSTALLPATH}/${VERSION}/bin"
SCRIPTFILE="${SCRIPTPATH}/${SCRIPTPREFIX}${VERSION}.sh"
#install_toolchain

## -> MIPS GNU/Linux target
ARCHCODE='mips'
#
CCPREFIX='mips-linux-gnu-'
DLBASEPATH='http://www.codesourcery.com/public/gnu_toolchain/mips-linux-gnu'
## (mips-4.4)
VERSION='mips-4.4'
DLFILE='mips-4.4-57-mips-linux-gnu-i686-pc-linux-gnu.tar.bz2'
BINPATH="${INSTALLPATH}/${VERSION}/bin"
SCRIPTFILE="${SCRIPTPATH}/${SCRIPTPREFIX}${VERSION}.sh"
#install_toolchain
