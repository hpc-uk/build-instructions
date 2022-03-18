# DFT-D4 on ARCHER2 with GCC 11.2.0 and HPE Cray LibSci

These are instructions for building [DFT-D4](https://github.com/dftd4/dftd4) 3.3.0 on ARCHER2
with GCC 11.2.0 compilers and HPE Cray LibSci 21.08 for BLAS/LAPACK. This compiler and library
option has been chosen so that DFT-D4 is compatible with the current (Mar 2022) versions of
VASP 5.4.4.pl2 and VASP 6.3.0 on ARCHER2.

## Download and unpack the DFT-D4 source

Ensure you are using the /work file system so the code you build will be available on the
compute nodes.

Get the source code from the repository:

```
wget https://github.com/dftd4/dftd4/releases/download/v3.3.0/dftd4-3.3.0-source.tar.xz
```

then unpack and move into the source directory:

```
tar -xvf dftd4-3.3.0-source.tar.xz
cd dftd4-3.3.0
```

## Setup build environment

Load the required modules for building the software:

```
module load PrgEnv-gnu
module load cray-python
module load cpe/21.09
```

Modules loaded at build time:

```
Currently Loaded Modules:
  1) craype-x86-rome         4) bolt/0.7           7) PrgEnv-gnu/8.1.0       10) cray-mpich/8.1.9     13) gcc/11.2.0
  2) libfabric/1.11.0.4.71   5) epcc-setup-env     8) cray-dsmml/0.2.1       11) cray-python/3.9.4.1  14) cpe/21.09
  3) craype-network-ofi      6) load-epcc-module   9) cray-libsci/21.08.1.2  12) craype/2.7.10
```

## Install meson and ninja

The DFT-D4 build requires the meson and ninja build systems. These can
be installed using `pip`

```
pip install --user meson
pip install --user ninja
```

## Configure the DFT-D4 build

Modify the `meson_options.txt` file to set a `custom` LAPACK library (as the DFT-D4
build cannot automatically detect LibSci). Change the definition of the LAPACK library
to be:

```
option(
  'lapack',
  type: 'combo',
  value: 'custom',
  yield: true,
  choices: ['auto', 'mkl', 'mkl-rt', 'openblas', 'netlib', 'custom'],
  description : 'linear algebra backend',
)
```

Set the Fortran compiler command:

```
export FC=ftn
```

## Build and install DFT-D4

Use the following commands to build the software:

```
meson setup _build
meson test -C _build --print-errorlogs
```

Once it has built and passed the tests, you can install it in a directory
of your choice with:

```
meson configure _build --prefix=/path/to/install
meson install -C _build
```

Remember to set `/path/to/install` to a location on `/work` so that the installed
software will be visible on the compute nodes.


