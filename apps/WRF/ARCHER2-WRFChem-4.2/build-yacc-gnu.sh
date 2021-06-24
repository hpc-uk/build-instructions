#!/usr/bin/env bash

# From the default envoronment
# invoke as "bash ./jasper-build-yacc.sh"

set -e

VERSION='20210109'

MY_INSTALL=$(pwd)/byacc-${VERSION}

# See https://invisible-island.net/byacc/

# Install [as required]
# Using the Berkeley FTP site for source code, but there's some
# info in the Invisible Island website too.

wget https://invisible-mirror.net/archives/byacc/byacc-${VERSION}.tgz
tar zxvf byacc-${VERSION}.tgz
cd byacc-${VERSION}

module -s restore PrgEnv-gnu
module swap gcc gcc/9.3.0
module list

./configure --prefix=${MY_INSTALL}
make
make check
make install

