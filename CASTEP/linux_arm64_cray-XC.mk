#
# Cray Compiler Environment Fortran under linux.
#
LINUX = true
#
# ID for "compare_module.pl script
#
COMPILER=CRAY-f90-on-unicos
#
# PATHSCALE uppercases module filenames.
#
MKDEPF90=$(ROOTDIR)/bin/mkdepf90.pl -uc
#
#
# WARNING WARNING - override default for Cray XC - parallel build only.
#
COMMS_ARCH:=mpi
COMMS_OVERRIDDEN := true
#
#
ifeq ($(COMMS_ARCH),mpi)
F90 = ftn
CC=cc
else
F90 = ftn
CC=cc
endif
#
# Flag to specify module path search directory
#
MODULE_PREFIX=-p
#
#  Extension for object files  ".o" for unix
#
OBJ_EXTN = o
#
# General flags
#
FFLAGS_E =  -Dcray -h byteswapio -e m -d w  -fPIC
#
# Optimiser, performance and debugging flags
#
ifeq ($(BUILD),debug)
OPT = -Ddebug  -g -O 0
else ifeq ($(BUILD),intermediate)
OPT = -O 1 -G 2
$(eval cell.o : $(PRIVATE) OPT = -O 1 -h vector0 -G 2)
else
OPT = -O 2 -G 2
$(eval cell.o : $(PRIVATE) OPT = -O 2 -h fp1 -h vector0 -G 2)
$(eval ion_atom.o : $(PRIVATE) OPT = -O 2 -h fp1  -G 2)
#$(eval trace.o : $(PRIVATE) OPT= -O 1 -G 2)
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
override MATHLIBS=scilib
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
$(error Intel MKL is not compatible with $(F90))
endif
ifeq ($(MATHLIBS),mkl10)
$(error Intel MKL is not compatible with $(F90))
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
LD_FLAGS =  $(OPT) -h byteswapio
#
# Total libraries -- should not need to change this.
# CASTEP_LIBS should be set up by specific makefiles.
#
LIBS = $(CASTEP_LIBS) $(FFT_LIBS) $(MATH_LIBS) $(COMMS_LIB) $(EXTRA_LIBS) $(DYNAMIC_LIBS)
