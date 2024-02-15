Building LAMMPS 15Dec2023 on Cirrus (GCC 12.2.0, FFTW 3.3.10)
=============================================================

These instructions are for building LAMMPS version 15Dec2023, also known as 2Aug2023 update 2, on Cirrus (SGI/HPE ICE XA, Intel Broadwell) using the GCC 12.2.0 compilers, MPI from Intel, and FFTW 3.3.10.

Download LAMMPS
---------------

Clone the latest stable version of LAMMPS from the GitHub repository:

```bash
git clone --depth 1 --branch stable_2Aug2023_update2 https://github.com/lammps/lammps.git lammps-2023-12-15
```

Setup your environment
----------------------

Load the correct modules:

```bash
module load cmake/3.25.2
module load fftw/3.3.10-gcc12.2.0-intel20.4
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
      -D BUILD_MPI=on                \
      -D BUILD_SHARED_LIBS=yes       \
      -D CMAKE_CXX_COMPILER=mpicxx   \
      -D CMAKE_CXX_FLAGS="-O3"       \
      -D FFT=FFTW3                   \
      -D PKG_MPIIO=yes               \
      -D CMAKE_INSTALL_PREFIX=/mnt/?? \
      ../cmake/

make -j 8
make install
```
