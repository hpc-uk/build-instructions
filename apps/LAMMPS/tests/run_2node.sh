#!/bin/bash

#SBATCH --job-name=lmp_2cpu_b8
#SBATCH --time=1:00:00
#SBATCH --nodes=2
#SBATCH --exclusive
#SBATCH --tasks-per-node=36
#SBATCH --cpus-per-task=1

# Replace [budget code] below with your budget code (e.g. t01)
#SBATCH --account=[budget code]
#SBATCH --partition=standard
#SBATCH --qos=standard

module load lammps/8Feb2023-gcc8-impi-cuda118

# Set the number of threads to 1
export OMP_NUM_THREADS=1

# Launch the parallel job
srun lmp -in in.ethanol_optimized -l log.lammps.$SLURM_JOB_ID
