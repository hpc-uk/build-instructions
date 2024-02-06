Instructions for building OpenMPI 5.0.0 on CIRRUS
==================================================

These instructions are for building OpenMPI 5.0.0 on CIRRUS using gcc 10.2.0.

In order to install OpenMPI you will need to install two additional libraries: `hwloc` and `pmix`.

Setup initial environment
-------------------------
First you need to setup the environment. 
The environment variables `HWLOC_ROOT`,`PMIX_ROOT`, `OPENMPI_ROOT` point to the directories where respectively `hwloc`, `pmix` and `openmpi` will be installed.
Below we specify them as subdirectories of `${BASE_PREFIX}`.
Remember to change the setting `BASE_PREFIX` to a path appropriate for your project.

```bash
module load gcc/10.2.0

export BASE_PREFIX=/mnt/lustre/indy2lfs/sw # Base directory where to install openmpi and its dependencies. Change to your custom directory

# Define compilers
export CC=gcc 
export CXX=g++
export FC=gfortran

CC_VERSION=$($CC --version | head -n 1 |  awk '{ print $3}') # get the version from the executable. This is used to define the path of all libraries required by the install


HWLOC_VERSION=2.9.3
HWLOC_ROOT=${BASE_PREFIX}/hwloc/hwloc-${HWLOC_VERSION}-${CC}-${CC_VERSION}


PMIX_VERSION=4.2.7
PMIX_ROOT=${BASE_PREFIX}/pmix/pmix-${PMIX_VERSION}-${CC}-${CC_VERSION}

LIBEVENT_ROOT=/mnt/lustre/indy2lfs/sw/libevent/2.1.12

OPENMPI_VERSION=5.0.0
OPENMPI_ROOT=${BASE_PREFIX}/openmpi/openmpi-${OPENMPI_VERSION}-${CC}-${CC_VERSION}

```

Install hwloc
-------------------------


```bash 

wget https://download.open-mpi.org/release/hwloc/v2.9/hwloc-$HWLOC_VERSION.tar.gz .

tar xvf hwloc-$HWLOC_VERSION.tar.gz


cd hwloc-$HWLOC_VERSION


../configure --prefix=${HWLOC_ROOT}
make 
make install
cd ..

```
Install pmix
-------------------------
```bash
PMIX=pmix-$PMIX_VERSION
wget https://github.com/openpmix/openpmix/releases/download/v${PMIX_VERSION}/$PMIX.tar.gz


tar -xvf ${PMIX}.tar.gz 
cd $PMIX
mkdir build
cd build

../configure CFLAGS="-I${HWLOC_ROOT}/include" LDFLAGS="-L${HWLOC_ROOT}/lib" --with-hwloc=${HWLOC_ROOT} --with-libevent=${LIBEVENT_ROOT} --prefix=${PMIX_ROOT}
make 
make install
cd ../..
```

Install OpenMPI
-------------------------


```bash 
CFLAGS="-I${HWLOC_ROOT}/include -I${PMIX_ROOT}/include"
LDFLAGS="-L${PMIX_ROOT}/lib -L${HWLOC_ROOT}/lib"


CONF="CC=${CC} CXX=${CXX} FC=${FC} "\
'--enable-mpi1-compatibility '\
'--enable-mpi-fortran '\
'--enable-mpi-interface-warning '\
'--enable-mpirun-prefix-by-default --with-slurm '\
'--with-ucx=/mnt/lustre/indy2lfs/sw/ucx/1.15.0 '\
"--with-pmix=${PMIX_ROOT} "\
"--with-pmix-libdir=${PMIX_ROOT}/lib "\
'--with-libevent=/mnt/lustre/indy2lfs/sw/libevent/2.1.12 '\
"--with-hwloc=${HWLOC_ROOT} "\
"--without-cuda --without-hcoll"

OMPI="openmpi-${OPENMPI_VERSION}"


wget https://download.open-mpi.org/release/open-mpi/v`echo $OPENMPI_VERSION | cut -c1-3`/${OMPI}.tar.gz
tar -xvf ${OMPI}.tar.gz
cd ${OMPI}
mkdir build
cd build
../configure CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" $CONF --prefix=${OPENMPI_ROOT}
make 2>&1 | tee make.log
make install
```