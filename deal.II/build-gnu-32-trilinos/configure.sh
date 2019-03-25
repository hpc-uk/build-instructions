#!/bin/bash
# Configure deal.II

# https://github.com/dealii/candi/pull/31
# has
# DEAL_CONFOPTS=" -D DEAL_II_WITH_LAPACK=OFF -D DEAL_II_WITH_BLAS=OFF -D DEAL_II_WITH_GSL=OFF  -D DEAL_II_WITH_BZIP2=OFF -D DEAL_II_FORCE_BUNDLED_BOOST=ON -D DEAL_II_WITH_UMFPACK=OFF -D MPI_INCLUDE_PATH=$MPICH_DIR/include -D MPI_CXX_LIBRARIES=\"$MPICH_DIR/lib/libmpichcxx.so;$MPICH_DIR/lib/libmpich.so\" "

# (Note the we are using a tmp dir as bash doesn't have associative
# arrays like python dicts)
cvars=$(mktemp -d)

# It might be better to use CrayLinuxEnvironment but means you are
# cross-compiling (although you are not) and that means you have to
# "make expand_instantiations_exe" and then add build/bin directory to
# PATH so that the make works.
#echo >$cvars/CMAKE_SYSTEM_NAME CrayLinuxEnvironment

echo >$cvars/CMAKE_C_COMPILER cc
echo >$cvars/CMAKE_CXX_COMPILER CC
echo >$cvars/CMAKE_FORTRAN_COMPILER ftn

echo >$cvars/CMAKE_INSTALL_PREFIX $install_dir

echo >$cvars/CMAKE_VERBOSE_MAKEFILE ON

# Also make sure CRAYPE_LINK_TYPE=dynamic is exported
echo >$cvars/BUILD_SHARED_LIBS ON

echo >$cvars/DEAL_II_WITH_64BIT_INDICES OFF

# deal.II's own Boost should be used.
echo >$cvars/DEAL_II_FORCE_BUNDLED_BOOST=ON


# HDF5
echo >$cvars/DEAL_II_WITH_HDF5 ON
echo >$cvars/HDF5_DIR $HDF5_DIR

# LAPACK and BLAS
echo >$cvars/DEAL_II_WITH_LAPACK ON
echo >$cvars/BLAS_FOUND TRUE
echo >$cvars/LAPACK_FOUND TRUE

# METIS - values must be checked if you change the version of TPSL
echo >$cvars/DEAL_II_WITH_METIS ON
echo >$cvars/METIS_DIR $CRAY_TPSL_PREFIX_DIR
echo >$cvars/METIS_LIBRARIES $CRAY_TPSL_PREFIX_DIR/lib/libmetis.so
echo >$cvars/METIS_INCLUDE_DIRS $CRAY_TPSL_PREFIX_DIR/include
echo >$cvars/METIS_VERSION 5.1.0
echo >$cvars/METIS_VERSION_MAJOR 5
echo >$cvars/METIS_VERSION_MINOR 1
echo >$cvars/METIS_VERSION_SUBMINOR 0

# MPI
echo >$cvars/DEAL_II_WITH_MPI ON
echo >$cvars/MPI_FOUND TRUE
echo >$cvars/MPI_HAVE_MPI_SEEK_SET TRUE
echo >$cvars/MPIEXEC aprun
# use printf because echo will not ignore -n
printf "%s\n" "-n" >$cvars/MPIEXEC_NUMPROC_FLAG

# # netCDF - not available as cray-netcdf built without c++ support
# echo >$cvars/DEAL_II_WITH_NETCDF ON
# echo >$cvars/NETCDF_DIR $NETCDF_DIR

# PETSc
echo >$cvars/DEAL_II_WITH_PETSC OFF

# Trilinos
echo >$cvars/DEAL_II_WITH_TRILINOS ON
echo >$cvars/TRILINOS_DIR $CRAY_TRILINOS_PREFIX_DIR

# p4est
echo >$cvars/DEAL_II_WITH_P4EST ON
echo >$cvars/P4EST_DIR $p4est_install_dir

# Threading with TBB - check values if you change the version of the
# Intel compilers
echo >$cvars/DEAL_II_WITH_THREADS ON
# echo >$cvars/TBB_DIR $TBBROOT
# echo >$cvars/TBB_LIBRARY $TBBROOT/lib/intel64/gcc4.1/libtbb.so.2

# munge variables into the command line format needed by CMake
cmake_defines=''
for key in $(ls $cvars); do 
    cmake_defines="$cmake_defines -D$key=$(cat $cvars/$key)"
done

# Actually do the configuration - takes about 20 mins
cmake $cmake_defines $src_dir
