#!/bin/bash

# v0.1    22.04.2011
#         initial version
#
# v0.2    01.08.2011
#         adapt to bitbucked changes
#

# set this to the path of your pyload installation
# e.g. /usr/share/pyload
PYLOAD_DIR=/usr/share/pyload

# name of the file to get
TIP=tip.tar.gz

# temp path
TMP_TIP=/tmp/pyloadTip



/etc/init.d/pyload stop

wget https://bitbucket.org/spoob/pyload/get/$TIP -O /tmp/$TIP
mkdir $TMP_TIP
tar xzf /tmp/$TIP -C $TMP_TIP
cp -r -f $TMP_TIP/spoob-pyload-*/* $PYLOAD_DIR
rm /tmp/$TIP
rm -r $TMP_TIP

/etc/init.d/pyload start
