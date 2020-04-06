SIESTA_ARCH=intel-mkl
#
# Cirrus, UK Tier-2 national HPC facility: https://www.cirrus.ac.uk
#
# Intel 18 compiler, Intel MPI 18, Intel MKL
#
FC=mpiifort 
#
FFLAGS=-mkl=sequential -w -mp -tpp5 -O3
FFLAGS_DEBUG= -g 
LDFLAGS=
COMP_LIBS=
RANLIB=echo
#
NETCDF_LIBS=
NETCDF_INTERFACE=
DEFS_CDF=
#
MPI_INTERFACE=libmpi_f90.a
MPI_INCLUDE=/lustre/sw/intel/compilers_and_libraries_2018.5.274/linux/mpi/include64
DEFS_MPI=-DMPI
#
GUIDE=
LAPACK=
BLAS=${MKLROOT}/lib/intel64/libmkl_scalapack_lp64.a -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_intel_lp64.a ${MKLROOT}/lib/intel64/libmkl_sequential.a ${MKLROOT}/lib/intel64/libmkl_core.a ${MKLROOT}/lib/intel64/libmkl_blacs_intelmpi_lp64.a -Wl,--end-group -lpthread -lm -ldl
#G2C=/usr/lib/gcc-lib/i386-redhat-linux/2.96/libg2c.a
LIBS=$(LAPACK) $(BLAS) $(G2C) $(GUIDE)  -lpthread 
SYS=bsd
DEFS= $(DEFS_CDF) $(DEFS_MPI)

EXT_LIBS=extlibs.a

EXEC=siesta.x
#
.F.o:
	$(FC) -c $(FFLAGS)  $(DEFS) $<
.f.o:
	$(FC) -c $(FFLAGS)   $<
.F90.o:
	$(FC) -c $(FFLAGS)  $(DEFS) $<
.f90.o:
	$(FC) -c $(FFLAGS)   $<
#

