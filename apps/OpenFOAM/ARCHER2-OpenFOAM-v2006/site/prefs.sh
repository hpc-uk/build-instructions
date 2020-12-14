

export WM_MPLIB=CRAY-MPICH
export WM_COMPILER=Cray

export WM_COMPILER_LIB_ARCH=64
export WM_CC='cc'
export WM_CXX='CC'
export WM_CFLAGS='-fPIC'
export WM_CXXFLAGS='-fPIC'
export WM_LDFLAGS=''

# MPI
# Because ${WM_PROJECT_DIR}/etc/config.sh/mpi is sourced after  this file
# we need to induce the system to set the appropriate variables:

export MPICH_DIR=${CRAY_MPICH_BASEDIR}
export MPI_ARCH_PATH=${MPICH_DIR}
