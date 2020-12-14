Instructions for compiling CASTEP 18.1.0 for Isambard using Cray compilers
==========================================================================

These instructions are for compiling CASTEP 18.1.0 on Isambard (Cray XC, Cavium ThunderX2 Arm64 processors)
using the Cray compilers (CCE 8.x).

We assume that you have obtained the CASTEP source code from the UKCP developers.

Unpack the CASTEP source code
-----------------------------

Unpack the source

```bash
tar -xvf CASTEP-18.1.tar.gz 
```

Setup correct modules
---------------------

Switch to the GCC compilers and load the FFTW library module:

```bash
module load fftw/3.3.6.3
```

(This assumes that the Cray compilers, Cray LibSci and MPICH modules are already loaded (they are by
default on Isambard). If they are not on your system then you will need to load the 'PrgEnv-cray',
'cray-libsci' and 'anl-mpich' modules.)


Edit the Makefile to set options
--------------------------------

Switch to the main CASTEP directory

```bash
cd CASTEP-18.1
```

Edit `Makefile` and set the following options

```
COMMS_ARCH := mpi
FFT := fftw3
BUILD := fast
MATHLIBS := scilib
```

Setup an CASTEP *platform* file for the Cray XC50 Arm system
------------------------------------------------------------

Switch to the `platforms` directory:

```bash
cd obj/platforms
```

and copy the `linux_x86_64_cray-XT.mk` file:

```bash
cp linux_x86_64_cray-XT.mk linux_arm64_cray-XC.mk
```

(The [linux_arm64_cray-XC.mk file is also available in this repository](linux_arm64_cray-XC.mk) for reference.)

Build CASTEP
------------

Moveback to the main CASTEP directory from `obj/platoforms`:

```bash
cd ../../
```

Build CASTEP using the following commands:

```bash
unset CPU
make -j8 CASTEP_ARCH=linux_arm64_cray-XC clean
make -j8 CASTEP_ARCH=linux_arm64_cray-XC
```

The install process will ask for the path to the BLAS and LAPACK libraries; just leave this blank as the compiler 
wrapper scripts automatically deal with this.

You will also be asked for the path to FFTW; again, just leave this blank as the compiler 
wrapper scripts automatically deal with this.

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
