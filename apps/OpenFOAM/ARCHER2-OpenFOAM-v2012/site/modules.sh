#!/usr/bin/bash

# Modules required at build time

module -s restore /etc/cray-pe.d/PrgEnv-gnu
module load cray-fftw

# Modules required at compile time and at run time
