# arck.mk for ARCHER2 CPU build using GNU compiler
#
# Load the following modules before building:
#
# module restore
# module load PrgEnv-gnu
# module load cray-fftw
# module load cray-hdf5-parallel
# module load cray-libsci
# module load cray-python
#
COMPFLAG = -DGNU
PARAFLAG = -DMPI -DOMP
MATHFLAG = -DUSESCALAPACK -DUNPACKED -DUSEFFTW3 -DHDF5

FCPP = /usr/bin/cpp -C -nostdinc
# F90free = ftn -fopenmp -ffree-form -ffree-line-length-none -fno-second-underscore
# LINK = ftn -fopenmp -dynamic
F90free = ftn -fopenmp -ffree-form -ffree-line-length-none -fno-second-underscore -fbounds-check -fbacktrace -Wall -fallow-argument-mismatch 
LINK = ftn -fopenmp -ffree-form -ffree-line-length-none -fno-second-underscore -fbounds-check -fbacktrace -Wall -fallow-argument-mismatch -dynamic
FOPTS = -O1 -funsafe-math-optimizations -fallow-argument-mismatch
FNOOPTS = $(FOPTS)
MOD_OPT = -J
INCFLAG = -I

C_PARAFLAG = -DPARA -DMPICH_IGNORE_CXX_SEEK
CC_COMP = CC
C_COMP = cc
C_LINK = CC -dynamic
C_OPTS = -O1 -ffast-math
C_DEBUGFLAG =

REMOVE = /bin/rm -f

FFTWINCLUDE = $(FFTW_INC)
PERFORMANCE =

# LAPACKLIB = /pscratch/home/mdelben/LIBS_local/OpenBLAS-0.3.21/libopenblas.a 
# SCALAPACKLIB = /pscratch/home/mdelben/LIBS_local/scalapack-2.1.0/libscalapack.a

HDF5_LDIR = $(HDF5_DIR)/lib
HDF5LIB = $(HDF5_LDIR)/libhdf5hl_fortran.so \
$(HDF5_LDIR)/libhdf5_hl.so \
$(HDF5_LDIR)/libhdf5_fortran.so \
$(HDF5_LDIR)/libhdf5.so -lz -ldl
HDF5INCLUDE =$(HDF5_DIR)/include