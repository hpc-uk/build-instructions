Login and setup module environment
----------------------------------

```bash
su cse  

module load mpt/2.14  
module load gcc/6.2.0  
module load hdf5parallel/1.10.1-gcc6-mpt214  
```

Make and enter installation folder
----------------------------------

```bash
mkdir /lustre/sw/netcdfparallel/4.5.0-gcc6-mpt214
cd /lustre/sw/netcdfparallel/4.5.0-gcc6-mpt214
```

Download and unpack NetCDF archives
-----------------------------------

Download NetCDF C v4.5.0 source from [NetCDF-C Releases](https://github.com/Unidata/netcdf-c/releases) and then unpack
```bash
tar -xvf netcdf-c-4.5.4.tar.gz
```

Download NetCDF Fortran v4.4.4 source from [NetCDF-Fortran Releases](https://github.com/Unidata/netcdf-fortran/releases) and then unpack
```bash
tar -xvf netcdf-fortran-4.4.4.tar.gz
```

Configure, make and install NetCDF C 4.5.0
------------------------------------------

```bash
cd /lustre/sw/netcdfparallel/4.5.0-gcc6-mpt214/netcdf-c-4.5.0  

export MPICC_CC=gcc  
export MPICXX_CXX=g++  
export CPPFLAGS=-I/lustre/sw/hdf5parallel/1.10.1-gcc6-mpt214/include  
export LDFLAGS=-L/lustre/sw/hdf5parallel/1.10.1-gcc6-mpt214/lib  
export CC=gcc   

./configure --disable-dap --enable-parallel-tests --enable-fortran --disable-netcdf-4 --prefix=/lustre/sw/netcdfparallel/4.5.0-gcc6-mpt214  

make all  
make install  
```

Configure, make and install NetCDF Fortran 4.4.4
------------------------------------------------

```bash
cd /lustre/sw/netcdfparallel/4.5.0-gcc6-mpt214/netcdf-fortran-4.4.4  
  
export NCDIR=/lustre/sw/netcdfparallel/4.5.0-gcc6-mpt214  
export CC=gcc  
export FC=gfortran  
export LD_LIBRARY_PATH=$NCDIR/lib:$LD_LIBRARY_PATH  
export NFDIR=$NCDIR  
export CPPFLAGS=-I$NCDIR/include  
export LDFLAGS=-L$NCDIR/lib  

./configure --prefix=$NFDIR  

make all  
make install  
```

Module file location
--------------------

```bash
/lustre/sw/modulefiles/netcdf-parallel/4.5.0-gcc6-mpt214
```
