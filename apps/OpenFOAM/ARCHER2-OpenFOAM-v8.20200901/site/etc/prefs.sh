#!/usr/bin/bash
# Local environment settings for OpenFOAM version 8.0
# This file is at e.g., ${FOAM_INST_DIR}/site/etc/prefs.h
# See ${WM_PROJECT_DIR}/etc/bashrc for details.

# Local non-default options for PrgEnv-gnu

export WM_ARCH_OPTION='cray'

export WM_COMPILER_LIB_ARCH=64
export WM_CC='cc'
export WM_CXX='CC'
export WM_CFLAGS='-fPIC'
export WM_CXXFLAGS='-fPIC'
export WM_LDFLAGS=''

# MPI
# Because ${WM_PROJECT_DIR}/etc/config.sh/mpi is sourced after  this file
# we need to induce the system to set the appropriate variables:

# Use "SYSTEMMPI" and set the environment variables that are initialised via
# ${WM_PROJECT_DIR}/etc/config.sh/mpi

export WM_MPLIB=SYSTEMMPI
export MPI_ROOT=${CRAY_MPICH_BASEDIR}
export MPI_ARCH_PATH=${MPI_ROOT}

# Set the following variables, which are not actually required,
# to prevent warnings from ${WM_PROJECT_DIR}/etc/config.sh/mpi
# The test is [ -z ... ]

export MPI_ARCH_INC=" "
export MPI_ARCH_FLAGS=" "
export MPI_ARCH_LIBS=" "
