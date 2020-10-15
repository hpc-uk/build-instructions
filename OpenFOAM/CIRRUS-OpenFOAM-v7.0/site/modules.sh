#!/usr/bin/bash

# Modules required at build time

module load spack
module load flex-2.6.4-gcc-8.2.0-zlwjqca
module load autoconf-2.69-gcc-8.2.0-bkc32sr

# Modules also required at run time

module load gcc/6.3.0
module load mpt/2.22
module load zlib/1.2.11
