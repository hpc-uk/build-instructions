Instructions for compiling CASTEP 18.1.0 for A64FX using Fujitsu (Flang) compilers
==================================================================================

These instructions are for compiling CASTEP 18.1.0 on A64FX using the Fujitsu Flang-based compilers.

We assume that you have obtained the CASTEP source code from the UKCP developers.

Unpack the CASTEP source code
-----------------------------

Unpack the source

```bash
tar -xvf CASTEP-18.1.tar.gz 
```

Setup environment
-----------------

```bash
export BASEDIR=/opt/FJSVxtclanga/tcsds-1.2.19
export TCS=${BASEDIR}/bin
export PATH=$TCS:$PATH
export LD_LIBRARY_PATH=${BASEDIR}/lib64:$LD_LIBRARY_PATH
```

Set the compiler executables:

```bash
export CC=fcc
export FC=frt
```

Patch `spg_get_error_code()` function
-------------------------------------

To allow compilation with Flang, modify the function `spg_get_error_code` in `Source/Utility/spglib_f08.f90` to insert `import SPGLIB_SUCCESS`.

Final modified function:

```fortran
   function spg_get_error_code() bind(c, name='spg_get_error_code')
     import SPGLIB_SUCCESS
     integer(kind(SPGLIB_SUCCESS)) :: spg_get_error_code
   end function spg_get_error_code
```

Create the arch file for A64FX
------------------------------

CASTEP 18.1.0 does not contain a configuration file for compiling on A64FX so this
needs to be created. Switch to the platform files directory and create `linux_a64fx_frtpx.mk`

```bash
cd CASTEP-18.1/obj/platforms
touch linux_a64fx_frtpx.mk
```

Edit `linux_a64fx_frtpx.mk.mk` to be:

```
#
# Fujitsu fortran (FLANG) under linux.
#
LINUX = true
#
# ID for "compare_module.pl script
#
COMPILER=A64fx-on-LINUX
#
#
# WARNING WARNING - override default for Cray XT - parallel build only.
#
COMMS_ARCH:=mpi
COMMS_OVERRIDDEN := true
#
#
ifeq ($(COMMS_ARCH),mpi)
F90 = mpifrt
CC = mpifcc
else
F90 = frt
CC = fcc
endif
#
# Flag to specify module path search directory
#
MODULE_PREFIX=-I
#
#  Extension for object files  ".o" for unix
#
OBJ_EXTN = o
#
# General flags
#
FFLAGS_E = -fopenmp -fPIC
#
# Optimiser, performance and debugging flags
#
ifeq ($(BUILD),debug)
OPT = -Ddebug -O0 -g -fbounds-check -fbacktrace -Wall -Waliasing -Wsurprising -Wline-truncation -Wno-tabs -Wno-uninitialized -Wno-unused-dummy-argument -Wno-unused -Wno-character-truncation
else ifeq ($(BUILD),coverage)
OPT = -O1 -g -fbacktrace --coverage
else ifeq ($(BUILD),intermediate)
OPT = -O1 -g -fbacktrace
else
OPT = -O3
$(eval secondd.o (PRIVATE) : OPT=-O3)
# CPU flags should be set appropriately by compute environment
OPT_CPU = 
endif
#
# Don't change this line
#
FFLAGS = $(FFLAGS_E) $(OPT) $(OPT_CPU) $(DEFS) $(INC)

#
# Libraries
#
ifeq ($(MATHLIBS),default)
override MATHLIBS=
endif
#
# Cray scilib (Really only needed for serial compile - ftn includes it
#
ifeq ($(MATHLIBS),scilib)
MATH_LIBS = 
endif
#
# Intel MKL - static link
#
ifeq ($(MATHLIBS),mkl9)
MATH_LIBS =  lmkl_gfortran -lmkl_lapack -lmkl_em64t -lguide 
DYNAMIC_LIBS = -lpthread
endif
ifeq ($(MATHLIBS),mkl10)
MATH_LIBS = -Wl,--start-group -lmkl_gf_lp64 -lmkl_sequential -lmkl_core  -Wl,--end-group
DYNAMIC_LIBS = -lpthread -ldl
endif
#
# AMD ACML
#
ifeq ($(MATHLIBS),acml)
MATH_LIBS = -lacml
DYNAMIC_LIBS = -lrt
endif
#
# OpenBLAS (descendent of Kashushige Goto's fast assembler BLAS)
#
ifeq ($(MATHLIBS),openblas)
MATH_LIBS = -lopenblas
endif
#
# ATLAS BLAS
#
ifeq ($(MATHLIBS),atlas)
#  Link with the ATLAS blas and LAPACK routines.
MATH_LIBS = -llapack -lf77blas -lcblas -latlas
endif
#
# Generic Fortran BLAS
#
ifeq ($(MATHLIBS),generic)
MATH_LIBS = -llapack -lblas 
endif
ifeq ($(MATHLIBS),vendor)
MATH_LIBS = -lssl2mtsve
endif

#
# FFT libs
#
ifeq ($(FFT),default)
override FFT = generic
endif
ifeq ($(FFT),fftw)
FFT_LIBS = -lfftw
endif
ifeq ($(FFT),fftw3)
FFT_LIBS = -lfftw3
endif
#
# Any additional libraries required. 
#
EXTRA_LIBS := -lsymspg 
#
# Optional libXC flags
#
ifneq ($(LIBXC),none)
EXTRA_LIBS := -lxcf90 -lxc $(EXTRA_LIBS)
endif
#
# Link-time options. Add any additional library search directories here.
#
LD_FLAGS = -static $(OPT) -fopenmp
## Total libraries -- should not need to change this.
# CASTEP_LIBS should be set up by specific makefiles.
#
LIBS = $(CASTEP_LIBS) $(FFT_LIBS) $(MATH_LIBS) $(COMMS_LIB) $(EXTRA_LIBS) $(DYNAMIC_LIBS)
#
# Code Coverage
#
GENERATE_COVERAGE := lcov --directory . --capture --output-file castep.info && genhtml --ignore-errors source -o Coverage castep.info
```

You can also [download linux_a64fx_frtpx.mk](linux_a64fx_frtpx.mk)

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
MATHLIBS := vendorq


```

Build CASTEP
------------

Build CASTEP using the following commands:

```bash
unset CPU
make -j8 ARCH=linux_a64fx_frtpx clean
make -j8 ARCH=linux_a64fx_frtpx
```

The install process will ask for the path to the BLAS and LAPACK libraries. Use:

```
/opt/FJSVxtclanga/tcsds-1.2.19/lib64
```

You will also be asked for the path to FFTW; set this to the path to your FFTW3 
install. Mine was:

```
/home/users/uep/uep-2/software/fftw3_sve_own_V4.0L20/lib64
```

Install CASTEP
--------------

To install into the `bin/` directory in the CASTEP source
tree you use:

```bash
make -j8 ARCH=linux_a64fx_frtpx install
```

The built binary is called `castep.mpi`.
