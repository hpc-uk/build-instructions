Instructions for compiling GROMACS 2023.5 for Cirrus using GCC 10.2, Intel MPI 20.4, and CUDA 12.4
======================================================================================================

These instructions are for compiling GROMACS 2023.5 on [Cirrus](https://www.cirrus.ac.uk)
using the GCC 10.2 compilers, intel 20.4 MPI, FFTW3.3.10 and CUDA 12.4.


Workaround to known issue -- 




Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source and regression tests
(if done after the CPU version, the same can be reused, just set `$SRC` and `$REG_DIR`)

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2023.5.tar.gz
tar -xf gromacs-2023.5.tar.gz
wget https://ftp.gromacs.org/regressiontests/regressiontests-2023.5.tar.gz
tar xf regressiontests-2023.5.tar.gz

export REG_DIR="$(pwd)/regressiontests-2023.5"
cd gromacs-2023.5
export SRC=$(pwd)
```

Setup correct modules and build environment
-------------------------------------------

```
module load cmake/3.25.2
module load gcc/10.2.0
module load intel-20.4/mpi
module load intel-20.4/cmkl
module load fftw/3.3.10-gcc10.2-impi20.4
module load nvidia/nvhpc-byo-compiler/24.3
module load nvidia/tensorrt/8.4.3.1-u2
```

Configure and build the GPU accelerated serial version
------------------------------------------------------

Create a build directory in the source tree

```bash
cd ${SRC}
mkdir build_cuda
cd build_cuda
```

Use CMake to configure the build and then build and install.

```bash
export CC=gcc
export CXX=g++
export GMX_INSTALL=/work/y07/shared/cirrus-software/gromacs/2023.5-gpu

cmake                                                                 \
      -D CMAKE_CXX_COMPILER=g++                                       \
      -D CMAKE_C_COMPILER=gcc                                         \
      -D CUDA_CUDART_LIBRARY=${NVHPC_ROOT}/cuda/lib64/libcudart.so    \
      -D CUDA_TOOLKIT_INCLUDE=${NVHPC_ROOT}/cuda/include              \
      -D CUDA_cufft_LIBRARY=${NVHPC_ROOT}/math_libs/lib64/libcufft.so \
      -D GMX_BUILD_OWN_FFTW=OFF                                       \
      -D GMX_CUDA_TARGET_SM=70                                        \
      -D GMX_DEFAULT_SUFFIX=ON                                        \
      -D GMX_DOUBLE=OFF                                               \
      -D GMX_FFT_LIBRARY=fftw3                                        \
      -D GMX_GPU=CUDA                                                 \
      -D GMX_MPI=OFF                                                  \
      -D GMX_OPENMP=ON                                                \
      -D GMX_OPENMP_MAX_THREADS=32                                    \
      -D REGRESSIONTEST_PATH=${REG_DIR}                               \
      -D CMAKE_INSTALL_PREFIX=${GMX_INSTALL}                          \
      ../

make -j 8
make VERBOSE=1 -j 8 check  # for tests
make install
```



Configure and build the GPU accelerated parallel version
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd ${SRC}
mkdir build_cuda_mpi
cd build_cuda_mpi
```

Use CMake to configure the build and then build and install.

```bash
export CC=gcc
export CXX=g++
export GMX_INSTALL=/work/y07/shared/cirrus-software/gromacs/2023.5-gpu
export SRUN_FLAGS=  # add srun info needed for test runs

cmake                                                                 \
      -D CMAKE_CXX_COMPILER=g++                                       \
      -D CMAKE_C_COMPILER=gcc                                         \
      -D CUDA_CUDART_LIBRARY=${NVHPC_ROOT}/cuda/lib64/libcudart.so    \
      -D CUDA_TOOLKIT_INCLUDE=${NVHPC_ROOT}/cuda/include              \
      -D CUDA_cufft_LIBRARY=${NVHPC_ROOT}/math_libs/lib64/libcufft.so \
      -D GMX_BUILD_OWN_FFTW=OFF                                       \
      -D GMX_CUDA_TARGET_SM=70                                        \
      -D GMX_DEFAULT_SUFFIX=ON                                        \
      -D GMX_DOUBLE=OFF                                               \
      -D GMX_FFT_LIBRARY=fftw3                                        \
      -D GMX_GPU=CUDA                                                 \
      -D GMX_MPI=ON                                                   \
      -D GMX_OPENMP=ON                                                \
      -D GMX_OPENMP_MAX_THREADS=32                                    \
      -D MPI_C_COMPILER=mpicc                                         \
      -D MPI_CXX_COMPILER=mpicxx                                      \
      -D MPIEXEC=$(which srun)                                        \
      -D MPIEXEC_EXECUTABLE=$(which srun)                             \
      -D MPIEXEC_MAX_NUMPROCS=1                                       \
      -D MPIEXEC_NUMPROC_FLAG=-n                                      \
      -D MPIEXEC_PREFLAGS=${SRUN_FLAGS}                               \
      -D REGRESSIONTEST_PATH=${REG_DIR}                               \
      -D CMAKE_INSTALL_PREFIX=${GMX_INSTALL}                          \
      ../

make -j 8
make VERBOSE=1 -j 8 check  # for tests, also set SRUN_FLAGS
make install
```



