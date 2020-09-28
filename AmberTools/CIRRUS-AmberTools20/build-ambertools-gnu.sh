#!/usr/bin/env bash

set -e

# AmberTools (not Amber)
# See https://ambermd.org/AmberTools.php

# Arrange a download of the package AmberTools20.tar.bz2 (480 MB) from
# https://ambermd.org/GetAmber.php#ambertools
# There's no automatic way to get at this (apparently).

# 1. Unpack the the source code
# 2. build serial version
# 3. build mpi version

top_level=`pwd`
amber=amber20

# 1. Unpack Ambertools
# Note that I have not set AMBERTOOLS: it defaults to top_level/amber20_src

tar xjf AmberTools20.tar.bz2
cd ${amber}_src

module load gcc/6.3.0
module load anaconda/python3

# flex and bison are required for the 'configure' stage

module load spack
module load flex-2.6.4-gcc-8.2.0-zlwjqca
module load bison-3.4.2-gcc-8.2.0-saivm44

# Take any updates before the configure stage to avoid an
# interactive prompt

python ./update_amber --update

# 2. Build Serial version first.

# Configure
# The configure state builds various bundled packages: netcdf, boost, fftw
# ./configure --full-help

./configure --with-python `which python` -nomklfftw -verbose -j 6 gnu

# "make install" does the compilation and install of the tools

make -j 8 install


# 3. MPI version

module load mpt/2.22

# See ./build-parallel-netcdf-gnu.sh

pnetcdf=${top_level}/parallel-netcdf-1.6.1

# Kludge:
# Fix mpif90 / C++ cross linking before configure by adding -lmpi++ here

sed -i 's/fc_cxx_link_flag="-lstdc++"/fc_cxx_link_flag="-lstdc++ -lmpi++"/' \
    ./AmberTools/src/configure2

./configure --with-python `which python` -nomklfftw -mpi -verbose \
	    --with-pnetcdf ${pnetcdf} -j 6 gnu

# Kludge:
# The "-lstdc++" is to allow mpif90 to resolve fully boost classes
# required in building "sander".
# Force these into AmberTools/src/config.h produced by configure
# (as there does not appear to be an official route...)

sed -i "s/AMBERLDFLAGS=/AMBERLDFLAGS= -lstdc++ /" AmberTools/src/config.h

# "make install" does the compilation and install of the tools

make -j 8 install


