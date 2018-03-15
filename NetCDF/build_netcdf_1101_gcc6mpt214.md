Download from github: netcdf-c-4.5.0.tar.gz
Download from github: netcdf-fortran-4.4.0.tar.gz

su cse

module load mpt/2.14
module load gcc/6.2.0
module load hdf5parallel/1.10.1-gcc6-mpt214


cd /lustre/sw/netcdfparallel/4.5.0-gcc6-mpt214
tar -xvf netcdf-c-4.5.0.tar.gz
cd netcdf-c-4.5.0

export MPICC_CC=gcc
export MPICXX_CXX=g++
export CPPFLAGS=-I/lustre/sw/hdf5parallel/1.10.1-gcc6-mpt214/include
export LDFLAGS=-L/lustre/sw/hdf5parallel/1.10.1-gcc6-mpt214/lib
export CC=gcc 

./configure --disable-dap --enable-parallel-tests --enable-fortran --disable-netcdf-4 --prefix=/lustre/sw/netcdfparallel/lustre/sw/netcdfparallel/4.5.0-gcc6-mpt214

make all
make check install


cd /lustre/sw/netcdfparallel/4.5.0-gcc6-mpt214
tar -xvf netcdf-fortran-4.4.0.tar.gz
cd netcdf-fortran-4.4.0
  
export NCDIR=/lustre/sw/netcdfparallel/4.5.0-gcc6-mpt214

export CC=gcc
export FC=gfortran

export LD_LIBRARY_PATH=$NCDIR/lib:$LD_LIBRARY_PATH

export NFDIR=$NCDIR
export CPPFLAGS=-I$NCDIR/include
export LDFLAGS=-L$NCDIR/lib

./configure --prefix=$NFDIR

make all
make check install

Module at /lustre/sw/modulefiles/netcdf-parallel/4.5.0-gcc6-mpt214
