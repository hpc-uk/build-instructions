#!/bin/bash
#
# Slurm job options (name, compute nodes, job time)
#SBATCH --job-name=specfem3d
#SBATCH --time=01:00:00
#SBATCH --partition=standard
#SBATCH --qos=standard
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --tasks-per-node=36
#SBATCH --cpus-per-task=1

# Replace [budget code] below with your project code (e.g. t01)
#SBATCH --account=z04

# Load the required modules
module load specfem3d/3.0.0-impi19-cuda11

NUMCPU=36

mkdir cpu-$NUMCPU-$SLURM_JOB_ID
cd cpu-$NUMCPU-$SLURM_JOB_ID
echo "OUTPUT_FILES from this run stored in folder: cpu-$NUMCPU-$SLURM_JOB_ID"

module list

mkdir OUTPUT_FILES
mkdir DATABASES_MPI
cp -r ../DATA .

cp DATA/Par_file_${NUMCPU}cpu DATA/Par_file
cp DATA/meshfem3D_files/Mesh_Par_file_${NUMCPU}cpu DATA/meshfem3D_files/Mesh_Par_file

echo "running: srun -n $NUMCPU xmeshfem3D"
srun -n $NUMCPU xmeshfem3D
echo "running: srun -n $NUMCPU xgenerate_databases"
srun -n $NUMCPU xgenerate_databases
echo "running: srun -n $NUMCPU xspecfem3D"
srun -n $NUMCPU xspecfem3D
echo "CPU only $NUMCPU cores result:"
grep "Total elapsed time" OUTPUT_FILES/output_solver.txt

mkdir OUTPUT_FILES_$SLURM_JOB_ID
cp OUTPUT_FILES/*.txt OUTPUT_FILES_$SLURM_JOB_ID -r
rm OUTPUT_FILES -r
rm DATABASES_MPI -r
