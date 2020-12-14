# Configure deal.II

# (Note the we are using a tmp dir as bash doesn't have associative
# arrays like python dicts)
cvars=$(mktemp -d)

echo >$cvars/CMAKE_C_COMPILER `which cc`
echo >$cvars/CMAKE_CXX_COMPILER `which CC`
echo >$cvars/CMAKE_FORTRAN_COMPILER `which ftn`
echo >$cvars/CMAKE_INSTALL_PREFIX $install_dir

# Also make sure CRAYPE_LINK_TYPE=dynamic is exported
echo >$cvars/BUILD_SHARED_LIBS ON

echo >$cvars/DEAL_II_WITH_64BIT_INDICES ON

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
echo >$cvars/METIS_LIBRARIES $CRAY_TPSL_PREFIX_DIR/lib/libmetis-64.so
echo >$cvars/METIS_INCLUDE_DIRS $CRAY_TPSL_PREFIX_DIR/include
echo >$cvars/METIS_VERSION 5.1.0
echo >$cvars/METIS_VERSION_MAJOR 5
echo >$cvars/METIS_VERSION_MINOR 1
echo >$cvars/METIS_VERSION_SUBMINOR 0

# MPI
echo >$cvars/DEAL_II_WITH_MPI ON
echo >$cvars/MPI_FOUND TRUE
echo >$cvars/MPI_HAVE_MPI_SEEK_SET TRUE

# # netCDF - not available as cray-netcdf built without c++ support
# echo >$cvars/DEAL_II_WITH_NETCDF ON
# echo >$cvars/NETCDF_DIR $NETCDF_DIR

# PETSc
echo >$cvars/DEAL_II_WITH_PETSC ON
echo >$cvars/PETSC_DIR $PETSC_DIR
echo >$cvars/PETSC_LIBRARIES $PETSC_DIR/lib/libcraypetsc_gnu_real-64.so

echo >$cvars/PETSC_WITH_64BIT_INDICES ON

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
