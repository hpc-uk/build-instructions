#!/usr/bin/env bash

set -e

module load oneapi
module load compiler/latest
module load mpi/latest
module load gcc

# Configuration process also requires svn
module load cmake/3.22.1
module load svn

prefix=$(pwd)/install


# Delft repository access requires a password.
# We expect the repository to appears as ./delft3d

cd delft3d
mkdir _build_all
cd _build_all

# Installed dependencies are located via PKG_CONFIG_PATH (bar metis)

netcdf=${prefix}/netcdf
metis=${prefix}/metis
petsc=${prefix}/petsc
proj=${prefix}/proj
gdal=${prefix}/gdal

export PKG_CONFIG_PATH=${netcdf}/lib/pkgconfig:${PKG_CONFIG_PATH}
export PKG_CONFIG_PATH=${petsc}/lib/pkgconfig:${PKG_CONFIG_PATH}
export PKG_CONFIG_PATH=${proj}/lib/pkgconfig:${PKG_CONFIG_PATH}
export PKG_CONFIG_PATH=${gdal}/lib/pkgconfig:${PKG_CONFIG_PATH}

# nb. CMAKE_BUILD_TYPE=Debug will fail with incorrect compiler args

# nb. Potential problems are metis, which does not appear in
# CMakelists.txt, and the dependency of proj on sqlite.
# These are introduced here:

# nb. Does not process CMAKE_INSTALL_PREFIX correctly, apparently. Omit.

# nb. It seems safest to do "make -j 1", more than one thread can fail,
# suggesting dependency problems. The alternative is to repeat without
# the dependency stage.

export LDFLAGS="-L${metis}/lib -lmetis /usr/lib64/libsqlite3.so"

cmake -G "Unix Makefiles" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_COMPILER=mpiicc \
      -DCMAKE_CXX_COMPILER=mpiicpc \
      -DCMAKE_Fortran_COMPILER=mpiifort \
      -DCMAKE_C_FLAGS="-I${metis}/include" \
      -DCMAKE_VERBOSE_MAKEFILE=1 \
      -DCONFIGURATION_TYPE="all" ../src/cmake

make -j 4
make -j 1

# Additionally, to get past the install stage ...
# An analogous statement probably also required at runtime, at the least

export LD_LIBRARY_PATH=${metis}/lib:${proj}/lib:${LD_LIBRARY_PATH}

cmake --install . --prefix=${prefix}/delft3d
