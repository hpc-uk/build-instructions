Instructions for compiling CASTEP 18.1.0 for AMD Naples (EPYC) using GCC 7.x compilers
==========================================================================

We assume that you have obtained the CASTEP source code from the UKCP developers.

Unpack the CASTEP source code
-----------------------------

Unpack the source

```bash
tar -xvf CASTEP-18.1.tar.gz 
```

Setup correct modules
---------------------

```bash
module use /opt/amd/modulefiles/AMD/
module load gcc/7.2.0
module load OpenMPI/2.1.1-gcc7.2.0 
module load OpenBLAS/0.2.20/gcc/4.8.5/threads
```

Other prerequisites
-------------------

You may also need to install FFTW if it is not already installed.


Edit the Makefile to set options
--------------------------------

Switch to the main CASTEP directory

```bash
cd CASTEP-18.1
```

Edit `Makefile` and set the following options

```
FFT := fftw3
MATHLIBS := openblas
COMMS_ARCH=mpi
BUILD := fast
```

Build CASTEP
------------

Moveback to the main CASTEP directory from `obj/platoforms`:

```bash
cd ../../
```

Build CASTEP using the following commands:

```bash
unset CPU
make ARCH=linux_x86_64_gfortran7.0 FFTLIBDIR=/scratch_lustre_DDN7k/xguox/fftw/install-gnu7.2.0/lib MATHLIBDIR=/opt/amd/OpenBLAS/0.2.20/gcc/4.8.5/threads/lib
```

Install CASTEP
--------------

To install the binaries in a specified directory use:

```bash
make -j8 INSTALL_DIR=/path/to/install/directory install
```

If you wish to simply install into the `bin/` directory in the CASTEP source
tree you can simply use:

```bash
make -j8 install
```

The built binary is called `castep.mpi`.
