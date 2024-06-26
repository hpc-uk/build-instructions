# Instructions for compiling GROMACS 2022.4 for ARCHER2 GPU nodes (AMD MI210) using GCC 11 compilers

These instructions are for compiling GROMACS 2022.4 on [ARCHER2](https://www.archer2.ac.uk) GPU nodes (AMD MI210) using the GCC 11 compilers.

The build is based on the AMD port of GROMACS.

## Download and Unpack the GROMACS source code


Download and unpack the source from the AMD developer hub:

```bash
git clone -b develop_2022_amd https://github.com/ROCmSoftwarePlatform/Gromacs.git
```

## Setup correct modules and build environment


Setup the GCC programming environment:

```bash
module restore
module load PrgEnv-gnu
module load cray-fftw
module load craype-accel-amd-gfx90a
module load craype-x86-milan
module load rocm
module load cray-python
module load cmake
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
```

Set compilers to ARCHER2 compiler wrappers

```
export CC=cc
export CXX=CC
```

## Configure and build the parallel, single-precision build

Create a build directory in the source tree

```bash
cd /path/to/gromacs-2022.4
mkdir build_mpi
cd build_mpi
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake .. \
   -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_C_COMPILER=cc \
   -DCMAKE_C_FLAGS="-mavx2 -mfma -Wno-missing-field-initializers -fexcess-precision=fast -funroll-all-loops -O3 -DNDEBUG -I${ROCM_PATH}/include" \
   -DCMAKE_CXX_COMPILER=CC \
   -DCMAKE_CXX_FLAGS="-mavx2 -mfma -Wno-missing-field-initializers -fexcess-precision=fast -funroll-all-loops -fopenmp -O3 -DNDEBUG -I${ROCM_PATH}/include" \
   -DCMAKE_EXE_LINKER_FLAGS="-L${CRAY_MPICH_ROOTDIR}/gtl/lib -lmpi_gtl_hsa -fopenmp" \
   -DCMAKE_SHARED_LINKER_FLAGS="-fopenmp" \
   -DCMAKE_HIP_ARCHITECTURES=gfx90a \
   -DCMAKE_LIBRARY_PATH="$FFTW_DIR" \
   -DCMAKE_MODULE_PATH="${ROCM_PATH}/hip/cmake" \
   -DFFTWF_INCLUDE_DIR="$FFTW_INC" \
   -DFFTWF_LIBRARY="${FFTW_DIR}/libfftw3f_mpi.so" \
   -DGMX_BLAS_USER="$CRAY_LIBSCI_PREFIX_DIR/lib/libsci_gnu_mpi_mp.so" \
   -DGMX_CYCLE_SUBCOUNTERS=ON \
   -DGMX_EXTERNAL_BLAS=ON \
   -DGMX_EXTERNAL_LAPACK=ON \
   -DGMX_FFT_LIBRARY=fftw3 \
   -DGMX_GPU=HIP \
   -DGMX_GPU_USE_VKFFT=on \
   -DGMX_HWLOC=OFF \
   -DGMX_LAPACK_USER="$CRAY_LIBSCI_PREFIX_DIR/lib/libsci_gnu_mpi_mp.so" \
   -DGMX_MPI=ON \
   -DGMX_OPENMP=ON \
   -DGMX_OPENMP_MAX_THREADS=128 \
   -DGMX_SIMD=AVX2_256 \
   -DGMX_THREAD_MPI=OFF \
   -DHIP_HIPCC_FLAGS="-std=c++17 -O3 --amdgpu-target=gfx90a -I${MPICH_DIR}/include -I${ROCM_PATH}/include" \
   -DCMAKE_INSTALL_PREFIX=/path/to/install

make -j 8
make install
```

