#!/usr/bin/env bash

# From the default envoronment
# invoke as "bash ./jasper-build-yacc.sh"

set -e

VERSION='2.6.4'

MY_INSTALL=$(pwd)/flex-${VERSION}

# See https://invisible-island.net/byacc/

# Install [as required]
# Using the Berkeley FTP site for source code, but there's some
# info in the Invisible Island website too.

wget https://github.com/westes/flex/releases/download/v2.6.4/flex-${VERSION}.tar.gz
tar zxvf flex-${VERSION}.tar.gz
cd flex-${VERSION}

module -s restore PrgEnv-gnu
module swap gcc gcc/9.3.0
module list

./configure --prefix=${MY_INSTALL}
make
make check
make install

