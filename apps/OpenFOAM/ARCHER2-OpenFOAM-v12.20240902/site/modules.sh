#!/usr/bin/env bash

set -e

# Modules required at build time

module load PrgEnv-gnu
export LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}

# Modules required at compile time and at run time

module list
