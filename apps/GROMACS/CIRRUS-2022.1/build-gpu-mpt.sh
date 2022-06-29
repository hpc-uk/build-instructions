#!/usr/bin/env bash

set -e

# For Gromacs installation see, e.g.,
# http://manual.gromacs.org/documentation/current/install-guide/index.html

# Cirrus
# 1. Arrange a suitable location in /work file system with access to the
#    back end (so that the tests can run).

# WE ASSUME HAVE source and tests (have built cpu version first)

export MY_PREFIX="$(pwd)/install-gpu"
export MY_GROMACS="$(pwd)/gromacs-2022.1"
export MY_REGRESSION_DIR="$(pwd)/regressiontests-2022.1"

cd ${MY_GROMACS}

# Device version SERIAL

module load gcc/8.2.0
module load nvidia/nvhpc-nompi/22.2
module load cmake/3.22.1
module list

rm -rf _build_gpu_gmx
mkdir _build_gpu_gmx
cd _build_gpu_gmx

cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ \
      -DGMX_MPI=off \
      -DGMX_OPENMP=ON -DGMX_X11=OFF -DGMX_DOUBLE=OFF \
      -DGMX_BUILD_OWN_FFTW=on \
      -DGMX_GPU=CUDA \
      -DCUDA_cufft_LIBRARY=${NVHPC_ROOT}/math_libs/lib64/libcufft.so \
      -DCUDA_CUDART_LIBRARY=${NVHPC_ROOT}/cuda/lib64/libcudart.so \
      -DCUDA_TOOLKIT_INCLUDE=${NVHPC_ROOT}/cuda/include \
      -DGMX_CUDA_TARGET_SM=80 \
      -DGMX_OPENMP_MAX_THREADS=32 \
      -DREGRESSIONTEST_PATH=${MY_REGRESSION_DIR} \
      -DCMAKE_INSTALL_PREFIX=${MY_PREFIX}  ..

make -j 8 install


# Device PARALLEL version

cd ${MY_GROMACS}

rm -rf _build_gpu_gmx_mpi
mkdir _build_gpu_gmx_mpi
cd _build_gpu_gmx_mpi

# Add MPI:
module load mpt
module list

cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ \
      -DMPI_C_COMPILER=mpicc -DMPI_CXX_COMPILER=mpicxx -DGMX_MPI=ON \
      -DGMX_OPENMP=on -DGMX_X11=OFF -DGMX_DOUBLE=OFF \
      -DGMX_BUILD_OWN_FFTW=on -DBUILD_SHARED_LIBS=yes \
      -DGMX_GPU=CUDA \
      -DCUDA_cufft_LIBRARY=${NVHPC_ROOT}/math_libs/lib64/libcufft.so \
      -DCUDA_CUDART_LIBRARY=${NVHPC_ROOT}/cuda/lib64/libcudart.so \
      -DCUDA_TOOLKIT_INCLUDE=${NVHPC_ROOT}/cuda/include \
      -DGMX_CUDA_TARGET_SM="70;80" \
      -DMPIEXEC="$(which srun) -q" -DMPIEXEC_EXECUTABLE=$(which srun) \
      -DMPIEXEC_NUMPROC_FLAG=-n -DMPIEXEC_MAX_NUMPROCS=36 \
      -DGMX_OPENMP_MAX_THREADS=32 \
      -DREGRESSIONTEST_PATH=${MY_REGRESSION_DIR} \
      -DCMAKE_INSTALL_PREFIX=${MY_PREFIX}  ..

make -j 8 install

