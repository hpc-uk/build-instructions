Building LAMMPS 23Sep2023 on Cirrus (GCC 8.2.0, FFTW 3.3.10)
============================================================


These instructions are for building LAMMPS version 23Sep2023, also known as 2Aug2023 update 1, on Cirrus (SGI/HPE ICE XA, Intel Broadwell) using the GCC 8.2.0 compilers, MPI from Intel, FFTW 3.3.10, and GPU support using CUDA 11.8.

Download LAMMPS
---------------

Clone the latest stable version of LAMMPS from the GitHub repository:

```bash
git clone --depth 1 --branch stable_2Aug2023_update2 https://github.com/lammps/lammps.git lammps-2023-09-23
```

Setup your environment
----------------------

Load the correct modules:

```bash
module load cmake/3.25.2
module load fftw/3.3.10-intel20.4
module load nvidia/nvhpc-byo-compiler/22.11
```

MPI Version
-----------

Make and go into a build directory:

```bash
cd lammps-2023-09-23 && mkdir build_gcc_impi && cd build_gcc_impi
```

Build using:

```bash

cmake -C ../cmake/presets/most.cmake \
      -D CMAKE_CXX_COMPILER=mpicxx   \
      -D CMAKE_CXX_FLAGS="-O3"       \
      -D BUILD_MPI=on                \
      -D FFT=FFTW3                   \
      -D BUILD_SHARED=yes            \
      -D PKG_MPIIO=yes               \
      -D PKG_GPU=yes                 \
      -D GPU_API=cuda                \
      -D GPU_ARCH=sm_80              \
      -D CMAKE_INSTALL_PREFIX=/mnt/lustre/indy2lfs/sw/LAMMPS/23Sep2023-gcc8-impi20-cuda118 \
      ../cmake/

make -j 8
make install
```
