# QMCPACK

Building version 3.0.0, based on guidance in the manual for building
on the ORNL Cray XC30 "Eos", using the Intel compilers

Note that the Boost 1.60 module is missing for Intel, so we just
download the latest version from the net. We don't have to build it,
as the code only uses header-only sublibraries.

```
mkdir ~/qmcpack
cd ~/qmcpack
wget -O boost_1_64_0.tar.gz https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.gz
tar -xzf boost_1_64_0.tar.gz
export BOOST_INCLUDEDIR=$PWD/boost_1_64_0

wget https://github.com/QMCPACK/qmcpack/archive/v3.0.0.tar.gz
tar -xzf v3.0.0
cd qmcpack-3.0.0/

mkdir build
cd build

module swap PrgEnv-cray PrgEnv-intel
module swap intel intel/17.0.0.098
module load gcc/6.3.0

module load cray-hdf5
module load cmake/3.5.2
module load fftw

export FFTW_HOME=$(readlink -f $FFTW_DIR/..)

cmake -DCMAKE_BUILD_TYPE=release ..
make -j 8

```

The code doesn't have an install target. You will need to copy the
build to $WORK manually. Certainly the `bin` and `lib` directories
need to be copied. Perhaps the `examples` and `tests` dirs should also
be copied for testing?
