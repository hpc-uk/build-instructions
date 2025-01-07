#!/usr/bin/bash

# Modules required at build time
# Use gcc 10.2.0. gcc 11.x has failures.

module load PrgEnv-gnu
module load gcc/11.2.0
module load mkl
module load cray-fftw

# Modules required at compile time and at run time
