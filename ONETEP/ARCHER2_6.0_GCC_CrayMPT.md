Instructions for compiling ONETEP 6.0 for ARCHER2 using GCC compilers
=====================================================================

These instructions are for compiling ONETEP 6.0 on [ARCHER2](https://www.archer2.ac.uk)
using the GCC compilers. ARCHER2 is an HPE Cray EX supercomputer with two AMD 7742 64-core
processors per node and the HPE Cray Slingshot interconnect.

We assume that you have obtained the ONETEP source code from the developers.

Unpack the CASTEP source code
-----------------------------

Unpack the source

```bash
tar -xvf ONETEP-6.0.tar.gz 
```

Setup correct modules
---------------------

Setup the GCC compilers and load the FFTW library module:

```bash
module restore PrgEnv-gnu
module swap gcc gcc/9.3.0
module load cray-fftw
```

Note that the default `gcc/10.1.0` module gives an error when building ONETEP in one of
the OpenMP parallel regions so we switch to an older version of the compiler.

Build ONETEP
------------

Build ONETEP using the following commands:

```bash
gmake onetep ARCH=archer2
```

(This will use the ARCHER2 configuration file supplied with
ONETEP.)

The built binary can be found at:

```
bin/onetep.archer2
```

