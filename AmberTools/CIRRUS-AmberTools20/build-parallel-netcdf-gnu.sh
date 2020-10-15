#!/usr/bin/env bash

set -e

top_level=`pwd`

# Parallel NetCDF
# See, e.g., https://parallel-netcdf.github.io/wiki/Download.html

# This is for versions including and preceding 1.10.0, where
# the tar files were called "parallel-netcdf-1.10.0.tar.gz"

version=1.6.1
pnetcdf=parallel-netcdf-${version}
prefix=${top_level}/${pnetcdf}

wget https://parallel-netcdf.github.io/Release/${pnetcdf}.tar.gz

tar zxf ${pnetcdf}.tar.gz
cd ${pnetcdf}

module load mpt/2.22
module load gcc/6.3.0

./configure MPICC=mpicc MPICXX=mpicxx MPIF90=mpif90 \
	    --enable-fortran --prefix=${prefix}

# Patch for Fortran: we need an mpi module as MPT does not supply one
# for gfortran. A suitable location is the src directory for the
# f90 interface code:

f90_src=src/libf90

cat <<EOF > ./${f90_src}/mpi.f90
module mpi
  include "mpif.h"
end module mpi
EOF

cd ${f90_src}
mpif90 -c mpi.f90
cd -

# Compilation should be just a minute or two
# The tests take a few minutes

make -j 4
make check
make ptest
make install

