# Delft3D 4 Suite (tag 65936) Build Instructions

Dependencies:
 - svn
 - ruby 
 - autotools (not version 2.63 for autoconf or version 1.16.2 for automake
 - gnu libtool (delft3d currently uses version 2.4.2)
 - intel compilers version 18 or higher 
 - expat-devel 
 - mpich (version 3.1.2 or higher) 
 - lex & yacc 
 - openssl (NOT version 0.9.8)
 - readline-devel 
 - NetCDF (netcdf-c-4.6.1 or above, netcdf-fortran-4.4.5 or above, with hdf5 enabled)
 - netcdf-c-4.3.3 (or other versions that include the library libnetcdf.so.7)
 - uuid-dev 
 - HDF5
 - PETSc
 - METIS
 - tcl (required by morphological module, but untested)

*NOTE: mpich, netCDF and Delft3D must all be built using the same compilers!*

The software and its dependencies will be installed in `$PRFX`, an environment
variable that we will define beforehand.

```
# Define PRFX
PRFX=/work/gid/gid/uid

# Load relevant modules 
module load svn
module load bison 
module load flex
module load libtool
module load intel-compilers-18

# Set relevant environment variables 
export CC=icc
export CPP='/mnt/lustre/indy2lfs/sw/intel/compilers_and_libraries_2018.5.274/linux/bin/intel64/icpc -E'
export FC=ifort
export PERL_USE_UNSAFE_INC=1
```

## Build ruby 
```
cd $PRFX
wget https://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.1.tar.gz
tar -xvf ruby-2.5.1.tar.gz
cd ruby-2.5.1
./configure --prefix=$PRFX/ruby_install --disable-dtrace
make 
make install
export PATH=$PRFX/ruby_install/bin:$PATH
export LD_LIBRARY_PATH=$PRFX/ruby_install/lib/:$LD_LIBRARY_PATH
cd $PRFX
```


## Build autotools
```
cd $PRFX
# autoconf v2.68
wget https://mirrors.gethosted.online/gnu/autoconf/autoconf-2.68.tar.gz
tar -xvf autoconf-2.68.tar.gz
cd autoconf-2.68
./configure --prefix=$PRFX/autoconf/
make 
make install
export PATH=$PRFX/autoconf/bin:$PATH
cd $PRFX

## automake v1.16.5
wget https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.gz
tar -xvf automake-1.16.5.tar.gz
cd automake-1.16.5
./configure --prefix=$PRFX/automake/
make 
make install
export PATH=$PRFX/automake/bin:$PATH
cd $PRFX
```

## Build expat-devel
```
git clone https://github.com/libexpat/libexpat.git 
cd libexpat
cd expat/
./buildconf.sh
./configure --prefix=$PRFX/libexpat_install/
make
make install
export PATH=$PRFX/libexpat_install/bin:$PATH
export LD_LIBRARY_PATH=$PRFX/libexpat_install/lib/:$LD_LIBRARY_PATH
cd $PRFX
```


## Build mpich v3.1.2 
```
git clone https://github.com/pmodels/mpich.git
cd mpich
git checkout v3.1.2
git submodule update --init
./autogen.sh
./configure --prefix=$PRFX/mpich_install
make 
make install
export PATH=$PRFX/mpich_install/bin:$PATH
export LD_LIBRARY_PATH=$PRFX/mpich_install/lib/:$LD_LIBRARY_PATH
cd $PRFX
```

## Build openssl 
```
cd $PRFX
git clone git://git.openssl.org/openssl.git
cd openssl
git submodule update --init
./Configure 
make
make test
export LD_LIBRARY_PATH=$PRFX/openssl/:$LD_LIBRARY_PATH
cd $PRFX
```

## Build readline-devel 
```
cd $PRFX
wget http://git.savannah.gnu.org/cgit/readline.git/snapshot/readline-8.1.tar.gz 
tar -xvf readline-8.1.tar.gz 
cd readline-8.1
./configure --prefix=$PRFX/readline_install
make 
make install
export PATH=$PRFX/readline_install/bin:$PATH
export LD_LIBRARY_PATH=$PRFX/readline_install/lib/:$LD_LIBRARY_PATH
cd $PRFX
```

## Build HDF5
```
cd $PRFX
v=1.8.13
wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4/hdf5-${v}.tar.gz
tar -xf hdf5-${v}.tar.gz
cd hdf5-${v}
./configure --enable-shared --enable-hl --prefix=$PRFX/hdf5_install
make 
make install
export PATH=$PRFX/hdf5_install/bin:$PATH
export LD_LIBRARY_PATH=$PRFX/hdf5_install/lib:$LD_LIBRARY_PATH 
cd $PRFX
```

## Build netcdf
```
# C version
## version 4.3.3 
## (Note:this version is not necessary for building delft3d, but it contains library necessary for 
## running dimr example, i.e. the FM_WAVE example in example 12, see instructions for more detail)

cd $PRFX
export CPPFLAGS=-I$PRFX/hdf5_install/include:$CPPFLAGS
export LDFLAGS=-L$PRFX/hdf5_install/lib:$LDFLAGS
export NCDIR=$PRFX/netcdf_4.3.3_install/
v=4.3.3
wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v${v}.tar.gz
tar -xvf v${v}.tar.gz && cd netcdf-c-${v}
CPPFLAGS=-I$PRFX/hdf5_install/include LDFLAGS=-L$PRFX/hdf5_install/lib ./configure --enable-dap --enable-netcdf-4 --enable-shared --prefix=$NCDIR
make
make install
export PATH=$PATH:$NCDIR/bin
export LD_LIBRARY_PATH=$NCDIR/lib:$LD_LIBRARY_PATH 
export CPPFLAGS=-I$NCDIR/include
export LDFLAGS=-L$NCDIR/lib
cd $PRFX

## version 4.6.1
cd $PRFX
export CPPFLAGS=-I$PRFX/hdf5_install/include:$CPPFLAGS
export LDFLAGS=-L$PRFX/hdf5_install/lib:$LDFLAGS
export NCDIR=$PRFX/netcdf_install/
v=4.6.1
wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v${v}.tar.gz
tar -xvf v${v}.tar.gz && cd netcdf-c-${v}
CPPFLAGS=-I$PRFX/hdf5_install/include LDFLAGS=-L$PRFX/hdf5_install/lib ./configure --enable-dap --enable-netcdf-4 --enable-shared --prefix=$NCDIR
make
make install
export PATH=$PATH:$NCDIR/bin
export LD_LIBRARY_PATH=$NCDIR/lib:$LD_LIBRARY_PATH 
export CPPFLAGS=-I$NCDIR/include
export LDFLAGS=-L$NCDIR/lib
cd $PRFX

# FORTRAN version
cd $PRFX
v=4.4.5
wget https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v${v}.tar.gz
tar -xvf v${v}.tar.gz && cd netcdf-fortran-${v}
./configure --prefix=$NCDIR  
make 
make install
export NETCDFROOT=$NCDIR
export PKG_CONFIG_PATH=$PRFX/netcdf_install/lib/pkgconfig/:$PKG_CONFIG_PATH
cd $PRFX
```

## Build PETSc
```
# NOTE: Metis gets installed with PETSc!
INSTALL_DIR=${PRFX}/petsc_install/
mkdir -p ${PRFX}/downloads
cd ${PRFX}/downloads
wget https://github.com/hypre-space/hypre/archive/93baaa8c9.tar.gz
wget https://bitbucket.org/petsc/pkg-metis/get/v5.1.0-p8.tar.gz
wget https://bitbucket.org/petsc/pkg-parmetis/get/v4.0.3-p6.tar.gz
wget https://gitlab.inria.fr/scotch/scotch/-/archive/v6.0.9/scotch-v6.0.9.tar.gz
wget https://github.com/xiaoyeli/superlu/archive/a3d5233.tar.gz
wget https://github.com/xiaoyeli/superlu_dist/archive/v6.3.0.tar.gz
wget http://ftp.mcs.anl.gov/pub/petsc/externalpackages/sundials-2.5.0p1.tar.gz
wget https://bitbucket.org/petsc/pkg-fblaslapack/get/v3.4.2-p3.tar.gz
wget https://bitbucket.org/petsc/pkg-scalapack/get/v2.1.0-p1.tar.gz
wget https://bitbucket.org/petsc/pkg-mumps/get/v5.2.1-p2.tar.gz
wget https://cmake.org/files/v3.15/cmake-3.15.6.tar.gz
wget http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-3.13.2.tar.gz
tar xf petsc-lite-3.13.2.tar.gz

export FC=mpifort
export CC=mpicc
export MPICC_CC=icc
export CXX=mpicxx
export MPICXX_CXX=icpc
unset PETSC_DIR
export CFLAGS="-O3 -g -march=native -mtune=native"
export FFLAGS="-O3 -g -march=native -mtune=native"
export CXXFLAGS="-O3 -g -march=native -mtune=native"
 
export PATH=$PATH:${INSTALL_DIR}/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${INSTALL_DIR}/lib

cd ../
cd petsc-3.13.2
./configure CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" FFLAGS="$FFLAGS" CC=$CC CXX=$CXX FC=$FC --with-cxx=$CXX --with-cc=$CC --with-fc=$FC --with-openmp --with-shared-libraries=1 --with-debugging=0 --prefix=${INSTALL_DIR} --with-blas-lapack-dir=/mnt/lustre/indy2lfs/sw/intel/compilers_and_libraries_2018.5.274/linux/mkl --with-mkl_pardiso-dir=/mnt/lustre/indy2lfs/sw/intel/compilers_and_libraries_2018.5.274/linux/mkl--with-scalapack-lib='-lmkl_scalapack_ilp64 -lmkl_blacs_intelmpi_ilp64 -lpthread -lm -ldl' --with-display=0 --with-scalapack --download-superlu --download-hypre --download-ptscotch --download-sundials --download-metis --download-mumps --download-parmetis --download-cmake --with-packages-download-dir=${PRFX}/downloads
make PETSC_DIR=${PRFX}/petsc-3.13.2 PETSC_ARCH=arch-linux-c-opt all
make PETSC_DIR=${PRFX}/petsc-3.13.2 PETSC_ARCH=arch-linux-c-opt install
make PETSC_DIR=${INSTALL_DIR} PETSC_ARCH="" check

export PATH=$PATH:${INSTALL_DIR}/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${INSTALL_DIR}/lib
export PKG_CONFIG_PATH=$PRFX/petsc_install/lib/pkgconfig/:$PKG_CONFIG_PATH
export CPATH=$CPATH:$PRFX/petsc_install/include
cd $PRFX
```

## Build Delft3D 4 Suite (tag 65936)
```
# use these instructions to setup the environment quickly, only when all prerequisits were already installed
# Define PRFX
PRFX=/work/gid/gid/uid/delft3d_install

# Load relevant modules
module load svn
module load bison 
module load flex
module load libtool
module load intel-compilers-18

# Set relevant environment variables 
export CC=mpicc
export MPICC_CC=icc
export CXX=mpicxx
export MPICXX_CXX=icpc
export CPP='/mnt/lustre/indy2lfs/sw/intel/compilers_and_libraries_2018.5.274/linux/bin/intel64/icpc -E'
export FC=mpifort
export PERL_USE_UNSAFE_INC=1

# Load ruby$$
export PATH=$PRFX/ruby_install/bin:$PATH
export LD_LIBRARY_PATH=$PRFX/ruby_install/lib/:$LD_LIBRARY_PATH

# Load autotools
export PATH=$PRFX/autoconf/bin:$PATH
export PATH=$PRFX/automake/bin:$PATH

# Load expat-devel
export PATH=$PRFX/libexpat_install/bin:$PATH
export LD_LIBRARY_PATH=$PRFX/libexpat_install/lib/:$LD_LIBRARY_PATH

# Load mpich
export PATH=$PRFX/mpich_install/bin:$PATH
export LD_LIBRARY_PATH=$PRFX/mpich_install/lib/:$LD_LIBRARY_PATH

# Load openssl
export LD_LIBRARY_PATH=$PRFX/openssl/:$LD_LIBRARY_PATH

# Load readline-devel
export PATH=$PRFX/readline_install/bin:$PATH
export LD_LIBRARY_PATH=$PRFX/readline_install/lib/:$LD_LIBRARY_PATH

# Load HDF5
export PATH=$PRFX/hdf5_install/bin:$PATH
export LD_LIBRARY_PATH=$PRFX/hdf5_install/lib:$LD_LIBRARY_PATH 
export CPPFLAGS=-I$PRFX/hdf5_install/include:$CPPFLAGS
export LDFLAGS=-L$PRFX/hdf5_install/lib:$LDFLAGS

# Load netcdf
export PATH=$PATH:$PRFX/netcdf_install/bin
export LD_LIBRARY_PATH=$PRFX/netcdf_install/lib:$LD_LIBRARY_PATH 
export LD_LIBRARY_PATH=$PRFX/netcdf_4.3.3_install/lib:$LD_LIBRARY_PATH 
export CPPFLAGS=-I$PRFX/netcdf_install/include
export LDFLAGS=-L$PRFX/netcdf_install/lib
export NETCDFROOT=$PRFX/netcdf_install
export PKG_CONFIG_PATH=$PRFX/netcdf_install/lib/pkgconfig/:$PKG_CONFIG_PATH

# Load PETSC
export PATH=$PATH:$PRFX/petsc_install/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PRFX/petsc_install/lib
export PKG_CONFIG_PATH=$PRFX/petsc_install/lib/pkgconfig/:$PKG_CONFIG_PATH
export CPATH=$CPATH:$PRFX/petsc_install/include

```
```
# vim src/README to see compilation instructions
svn co https://svn.oss.deltares.nl/repos/delft3d/tags/delft3d4/65936 delft3d_65936_repository
cd delft3d_65936_repository/src
./autogen.sh
cd third_party_open/kdtree2
./autogen.sh
cd -
CFLAGS='-O2 -I'$PRFX'/petsc_install/include -L'$PRFX'/petsc_install/lib' CXXFLAGS='-O2' FFLAGS='-O2' FCFLAGS='-O2' ./configure --prefix=`pwd` --with-netcdf --with-mpi --with-metis --with-petsc
cp third_party_open/swan/src/* third_party_open/swan/swan_mpi
cp third_party_open/swan/src/* third_party_open/swan/swan_omp/
# change first line in scripts_lgpl/linux/gatherlibraries.rb from /usr/bin/ruby to $PRFX/ruby_install/bin/ruby
FC=mpif90 make ds-install
# build dflowfm
FC=mpif90 make ds-install -C engines_gpl/dflowfm

```
