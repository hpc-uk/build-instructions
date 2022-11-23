#!/bin/bash

#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --exclusive

#SBATCH --partition=standard
#SBATCH --qos=standard

set -e 

# Install location

export prefix=$(pwd)/install
export delft3d=${prefix}/delft3d

# Copy the test directory (from the source directory)
# Remove three outdated keywords from the input 

cp -r delft3d/examples/12_dflowfm/test_data/e02_f14_c040_westerscheldt example

sed -i '/^Bathymetry/d'  example/westerscheldt.mdu
sed -i '/^ManholeFile/d' example/westerscheldt.mdu
sed -i '/^Writebalancefile/d' example/westerscheldt.mdu

cd example

# Modules and library paths

module load oneapi
module load compiler/latest
module load mpi/latest
module load mkl/latest
module load gcc

# This LD_PRELOAD is required to prevent issues in order of loading
# which can result in missing symbols...
export LD_PRELOAD=${MKLROOT}/lib/intel64/libmkl_sequential.so.2:${MKLROOT}/lib/intel64/libmkl_core.so.2
export LD_LIBRARY_PATH=${delft3d}/lib:/usr/lib:${LD_LIBRARY_PATH}

printf "LD_PRELOAD:      %s\n\n" "${LD_PRELOAD}"
printf "LD_LIBRARY_PATH: %s\n\n" "${LD_LIBRARY_PATH}"

export OMP_NUM_THREADS=1

# Preparation

${delft3d}/bin/run_dflowfm_processes.sh "--partition:ndomains=3: icgsolver=6" westerscheldt.mdu

# The script will issue "mpiexec"

${delft3d}/bin/run_dimr.sh -c 3

