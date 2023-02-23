#!/bin/bash

#SBATCH --job-name=lmp_2gpu_b8
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --gres=gpu:2
#SBATCH --exclusive

# Replace [budget code] below with your budget code (e.g. t01)
#SBATCH --account=[budget code]
#SBATCH --partition=gpu
#SBATCH --qos=gpu

module load lammps/8Feb2023-gcc8-impi-cuda118

# Set the number of threads to 1
export OMP_NUM_THREADS=1

srun lmp -sf gpu -pk gpu 2 -in in.ethanol_optimized -l log.lammps.$SLURM_JOB_ID
