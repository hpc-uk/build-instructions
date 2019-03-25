#!/bin/bash
# required modules
# using gnu compilers
module unload PrgEnv-cray
module unload PrgEnv-gnu
module unload PrgEnv-intel
module load PrgEnv-gnu

module switch gcc/5.3.0

module unload cmake
module load cmake

# deal.II's own Boost should be used.
module unload boost-serial

# optional modules
module unload cray-hdf5-parallel
module load cray-hdf5-parallel
module unload cray-netcdf-hdf5parallel
module load cray-netcdf-hdf5parallel
module unload cray-tpsl
module load cray-tpsl
module unload cray-trilinos
module load cray-trilinos
