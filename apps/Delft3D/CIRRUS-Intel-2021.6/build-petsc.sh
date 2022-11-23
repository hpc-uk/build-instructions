#!/usr/bin/env bash

set -e

module load oneapi
module load compiler/latest
module load mpi/latest
module load mkl/latest
module load gcc

export prefix=$(pwd)/install
export hdf5=${prefix}/hdf5
export metis=${prefix}/metis

version=3.9.3
wget http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-${version}.tar.gz
tar xf petsc-lite-${version}.tar.gz
cd petsc-${version}

# ./configure script has #!/usr/bin/env
# which should become python2

sed -i 's/env python$/env python2/' ./configure

./configure \
    --debugging=1 \
    --with-cc=mpiicc \
    --with-clib-autodetect=0 \
    --with-cxx=mpiicpc \
    --with-cxxlib-autodetect=0 \
    --with-debugging=0 \
    --with-dependencies=0 \
    --with-fc=mpiifort \
    --with-fortran-datatypes=0 \
    --with-fortran-interfaces=0 \
    --with-fortranlib-autodetect=1 \
    --with-ranlib=ranlib \
    --with-shared-ld=ar \
    --with-etags=0 \
    --with-x=0 \
    --with-ssl=0 \
    --with-shared-libraries=1 \
    --with-mpi-lib=[] \
    --with-mpi-include=[] \
    --with-blas-lapack=1 \
    --with-scalapack=1 \
    --with-scalapack-lib="-lmkl_scalapack_ilp64 -lmkl_blacs_intelmpi_ilp64 -lpthread -lm -ldl" \
    --with-superlu=0 \
    --with-metis=1 \
    --with-metis-dir=${metis} \
    --with-mumps=0 \
    --with-hdf5=1 \
    --with-hdf5-dir=${hdf5} \
    --CFLAGS="-g -O2 -DMKL_ILP64 -qmkl=sequential" \
    --CPPFLAGS="" \
    --CXXFLAGS="-g -O2 -DMKL_ILP64 -qmkl=sequential" \
    --with-cxx-dialect=C++11 \
    --FFLAGS="$FFLAGS $FOMPFLAG" \
    --LDFLAGS="-qmkl=sequential -L$prefix/lib" \
    --LIBS="-lstdc++" \
    --PETSC_ARCH="x86-cirrus" \
    --prefix=${prefix}/petsc

make -j 4 PETSC_DIR=$(pwd) PETSC_ARCH="x86-cirrus" all

# Should run ok on front end.
make PETSC_DIR=$(pwd) PETSC_ARCH="x86-cirrus" HDF5_LIB=yes check

make PETSC_DIR=$(pwd) PETSC_ARCH=x86-cirrus install
