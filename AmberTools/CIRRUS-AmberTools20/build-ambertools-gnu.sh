#!/usr/bin/env bash

# AmberTools (not Amber)
# See https://ambermd.org/AmberTools.php

# Arrange a download of the package AmberTools20.tar.bz2 (480 MB) from
# https://ambermd.org/GetAmber.php#ambertools
# There's no automatic way to get at this (apparently).

# Pre-requisites
# - As the Ambertools configure stage does not want to build the
#   bundled pnetcdf, build our own. As it's not entirely clear what
#   the bundled version is, I have plummed for 1.6.1 (based on date,
#   more than anything).

# See ./build-parallel-netcdf-gnu.sh

top_level=`pwd`
pnetcdf=${top_level}/parallel-netcdf-1.6.1
amber=amber20

# Unpack Ambertools
# Note that I have not set AMBERTOOLS: it defaults to top_level/amber20_src

tar xjf AmberTools20.tar.bz2
cd ${amber}_src

module load mpt/2.22
module load gcc/6.3.0
module load anaconda/python3

# flex and bison are required for the 'configure' stage

module load spack
module load flex-2.6.4-gcc-8.2.0-zlwjqca
module load bison-3.4.2-gcc-8.2.0-saivm44

# Take any updates before the configure stage to avoid an
# interactive prompt

python ./update_amber --update

# Configure
# The configure state builds various bundled packages: netcdf, boost, fftw
# ./configure --full-help

# Kludge
# Fix mpif90 / C++ cross linking in the configure script via
# fc_cxx_link_flags="-lstdc++ -lmpi++"

sed -i 's/fc_cxx_link_flag="-lstdc++"/fc_cxx_link_flag="-lstdc++ -lmpi++"/' \
    ./AmberTools/src/configure2

./configure --with-python `which python` -nomklfftw -mpi -verbose \
	    --with-pnetcdf ${pnetcdf} -j 6 gnu

# "make install" does the compilation and install of the tools

# Kludge:
# The "-lstdc++" is to allow mpif90 to resolve fully boost classes
# required in building "sander".
# Force this into AmberTools/src/config.h produced by configure
# (as there does not appear to be an official route...)

sed -i "s/AMBERLDFLAGS=/AMBERLDFLAGS= -lstdc++ /" AmberTools/src/config.h

make -j 6 install
