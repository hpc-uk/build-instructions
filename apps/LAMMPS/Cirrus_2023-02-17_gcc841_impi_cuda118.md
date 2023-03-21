Building LAMMPS on Cirrus (GCC 8, FFTW 3.3.10, CUDA 11.8)
=============================================================

These instructions are for building LAMMPS on Cirrus (SGI/HPE ICE XA, Intel Broadwell)
using the GCC 8 compilers, MPI from intel, FFTW 3.3.10, and GPU support using CUDA 11.8.

Download LAMMPS
---------------

Clone the latest stable version of LAMMPS from the GitHub repository:

```bash
  git clone --depth 1 -b stable https://github.com/lammps/lammps.git mylammps
 ```

Setup your environment
----------------------

Load the correct modules:

```bash
module load cmake
module load fftw/3.3.10-intel20.4
module load nvidia/nvhpc-byo-compiler/22.11
```

MPI Version with CUDA support
-----------------------------

Make and go into a build directory:

```bash
mkdir mylammps/build; cd mylammps/build
```

Build using:

```bash
cmake -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_CXX_FLAGS="-O3"         \
      -DBUILD_MPI=on -D FFT=FFTW3 -D PKG_ASPHERE=yes              \
      -D PKG_BODY=yes -D PKG_CLASS2=yes -D PKG_COLLOID=yes        \
      -D PKG_COMPRESS=yes -D PKG_CORESHELL=yes -D PKG_DIPOLE=yes  \
      -D PKG_GRANULAR=yes -D PKG_MC=yes -D PKG_MISC=yes           \
      -D PKG_KSPACE=yes -D PKG_MANYBODY=yes -D PKG_MOLECULE=yes   \
      -D PKG_MPIIO=yes -D PKG_OPT=yes -D PKG_PERI=yes             \
      -D PKG_QEQ=yes -D PKG_SHOCK=yes -D PKG_SRD=yes              \
      -D PKG_RIGID=yes -D PKG_GPU=yes -D GPU_API=cuda             \
      -D GPU_ARCH=sm_80 -DCMAKE_INSTALL_PREFIX=<INSTALL_PATH>     \
      ../cmake/

make -j 8
make install
```
