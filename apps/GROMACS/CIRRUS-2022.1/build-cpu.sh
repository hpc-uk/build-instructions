#!/usr/bin/env bash

set -e

# For Gromacs installation see, e.g.,
# http://manual.gromacs.org/documentation/current/install-guide/index.html

# This is the CPU build (both serial and parallel)

# Cirrus
# 0. If tests are required, uncomment the "make check" lines and ...
# 1. Arrange a suitable location in /work file system with access to the
#    back end (so that the tests can run).
# 2. Arrange an "salloc" allocation for the MPI tests (2 hours).
# 3. ... now can run the script

export MY_PREFIX="$(pwd)/install"
export MY_GROMACS="$(pwd)/gromacs-2022.1"

# Download
# https://manual.gromacs.org/current/download.html

wget https://ftp.gromacs.org/regressiontests/regressiontests-2022.1.tar.gz
tar xf regressiontests-2022.1.tar.gz
export MY_REGRESSION_DIR="$(pwd)/regressiontests-2022.1"

wget https://ftp.gromacs.org/gromacs/gromacs-2022.1.tar.gz
tar xf gromacs-2022.1.tar.gz

cd ${MY_GROMACS}

rm -rf _build_cpu_gmx _build_cpu_gmx_mpi

# SERIAL

module load gcc/8.2.0
module load cmake/3.22.1
module list

mkdir _build_cpu_gmx
cd _build_cpu_gmx

cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ \
      -DGMX_MPI=off -DGMX_BUILD_OWN_FFTW=on -DGMX_DEFAULT_SUFFIX=on \
      -DREGRESSIONTEST_PATH=${MY_REGRESSION_DIR} \
      -DMPIEXEC=$(which srun) -DMPIEXEC_EXECUTABLE=$(which srun) \
      -DMPIEXEC_NUMPROC_FLAG=-n -DMPIEXEC_MAX_NUMPROCS=1 \
      -DGMX_OPENMP_MAX_THREADS=32 \
      -DCMAKE_INSTALL_PREFIX=${MY_PREFIX} ..

make -j 8

# If tests are wanted .. (all tests should pass)
# See notes below on the tests.
# make VERBOSE=1 -j 8 check

make install


# PARALLEL

cd ${MY_GROMACS}

mkdir _build_cpu_gmx_mpi
cd _build_cpu_gmx_mpi

# Add ...

module load mpt
module list

cmake -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx \
      -DGMX_MPI=on -DGMX_BUILD_OWN_FFTW=on -DGMX_DEFAULT_SUFFIX=on \
      -DREGRESSIONTEST_PATH=${MY_REGRESSION_DIR} \
      -DMPIEXEC=$(which srun) -DMPIEXEC_EXECUTABLE=$(which srun) \
      -DMPIEXEC_NUMPROC_FLAG=-n -DMPIEXEC_MAX_NUMPROCS=36 \
      -DGMX_OPENMP_MAX_THREADS=32 \
      -DCMAKE_INSTALL_PREFIX=${MY_PREFIX} ..

make -j 8

# Tests will run on 8 MPI tasks by default. Don't let Gromacs choose the
# number of threads per task... (it will choose 72/8 = 9)

# However, don't set OMP_NUM_THREADS explicitly, ...
# export OMP_NUM_THREADS=1
# as this will cause a conflict with the test command line arguments.

#make VERBOSE=1 -j 8 check

make install

# MPI Version
# One fail [  FAILED  ] GmxApiTest.MpiWorldContext
# Test failures from rank 0:
# unknown file: Failure
# C++ exception with description "MPI-enabled Simulator contexts require a valid communicator." thrown in the test body.
