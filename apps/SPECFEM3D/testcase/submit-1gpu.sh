#!/bin/bash
#
# Slurm job options (name, compute nodes, job time)
#SBATCH --job-name=specfem3d
#SBATCH --time=01:00:00
#SBATCH --partition=gpu-cascade
#SBATCH --qos=gpu
#SBATCH --gres=gpu:1

# Replace [budget code] below with your project code (e.g. t01)
#SBATCH --account=z04

# Load the required modules
module load specfem3d/3.0.0-impi19-cuda11

NUM_GPU=1

mkdir gpu-$NUM_GPU-$SLURM_JOB_ID
cd gpu-$NUM_GPU-$SLURM_JOB_ID
echo "OUTPUT_FILES from this run stored in folder: gpu-$NUM_GPU-$SLURM_JOB_ID"
module list

mkdir OUTPUT_FILES
mkdir DATABASES_MPI
cp -r ../DATA .

cp DATA/Par_file_${NUM_GPU}gpu DATA/Par_file
cp DATA/meshfem3D_files/Mesh_Par_file_${NUM_GPU}gpu DATA/meshfem3D_files/Mesh_Par_file

echo " running srun -n $NUM_GPU xmeshfem3D"
srun -n $NUM_GPU xmeshfem3D
echo " running srun -n $NUM_GPU xgenerate_databases"
srun -n $NUM_GPU xgenerate_databases
echo " running srun -n $NUM_GPU xspecfem3D"
srun -n $NUM_GPU xspecfem3D
echo "$NUM_GPU GPU mesh=$MESH_SIZE result:"
grep "Total elapsed time" OUTPUT_FILES/output_solver.txt

mkdir OUTPUT_FILES_$SLURM_JOB_ID
cp OUTPUT_FILES/*.txt OUTPUT_FILES_$SLURM_JOB_ID -r

rm OUTPUT_FILES -r
rm DATABASES_MPI -r

