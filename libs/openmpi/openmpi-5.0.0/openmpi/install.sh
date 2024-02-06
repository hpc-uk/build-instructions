#!/usr/bin/bash

set -e

source ../setup.sh




CFLAGS="-I${HWLOC_ROOT}/include -I${PMIX_ROOT}/include"
LDFLAGS="-L${PMIX_ROOT}/lib -L${HWLOC_ROOT}/lib"


CONF="CC=${CC} CXX=${CXX} FC=${FC} "\
'--enable-mpi1-compatibility '\
'--enable-mpi-fortran '\
'--enable-mpi-interface-warning '\
'--enable-mpirun-prefix-by-default --with-slurm '\
'--with-ucx=/mnt/lustre/indy2lfs/sw/ucx/1.15.0 '\
"--with-pmix=${PMIX_ROOT} "\
"--with-pmix-libdir=${PMIX_ROOT}/lib "\
'--with-libevent=/mnt/lustre/indy2lfs/sw/libevent/2.1.12 '\
"--with-hwloc=${HWLOC_ROOT} "\
"--without-cuda --without-hcoll"

OMPI="openmpi-${OPENMPI_VERSION}"


wget https://download.open-mpi.org/release/open-mpi/v`echo $OPENMPI_VERSION | cut -c1-3`/${OMPI}.tar.gz
tar -xvf ${OMPI}.tar.gz
cd ${OMPI}
mkdir build
cd build
../configure CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" $CONF --prefix=${OPENMPI_ROOT}
make 2>&1 | tee make.log
make install
