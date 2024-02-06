module load gcc/10.2.0

export BASE_PREFIX=/mnt/lustre/indy2lfs/sw # Base directory where to install openmpi and its dependencies, not already available on cirrus

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


