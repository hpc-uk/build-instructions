Instructions for running PyFR 1.10.0 on Cirrus
==============================================

These instructions are for running PyFR 1.10.0 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using Python 3.8.

The instructions take the form of two Slurm submission scripts one using `srun` the other using `mpirun`.
The two scripts are very similar, the main difference being the setting of two Slurm environment variables in the `mpirun` script.

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project. The submission scripts below assume a locally installed
Miniconda3 virtual environment containing mpi4py, pycuda and pyfr.


Launch a PyFR job (via srun) that uses 16 GPUs across 4 compute nodes
---------------------------------------------------------------------

```bash
#!/bin/bash
 
#SBATCH --job-name=16GPU
#SBATCH --time=4-00:00:00
#SBATCH --partition=gpu-cascade
#SBATCH --nodes=4
#SBATCH --exclusive
#SBATCH --qos=gpu
#SBATCH --gres=gpu:4
#SBATCH --account=[budget code]

module load nvidia/cuda-10.2
module load nvidia/mathlibs-10.2
module load boost/1.73.0
module load openmpi/4.1.0-ucx-gcc8

PRFX=/path/to/work
MINICONDA3_ROOT=${PRFX}/miniconda3/4.9.2
MPI4PY_ROOT=${PRFX}/mpi4py/3.0.3-ompi-ucx

INPUTDIR=${PRFX}/input
MESH=${INPUTDIR}/meshes/16GPU_3D_11deg_endwalls_z33.pyfrm
INIT=${INPUTDIR}/tri_airfoil_Re3000_M015_3D.ini

. ${MINICONDA3_ROOT}/activate.sh
. ${MPI4PY_ROOT}/env.sh

srun --ntasks=16 --tasks-per-node=4 --cpus-per-task=10 pyfr run -b cuda -p ${MESH} ${INIT}

conda deactivate
```


Launch a PyFR job (via mpirun) that uses 16 GPUs across 4 compute nodes
-----------------------------------------------------------------------

```bash
#!/bin/bash
 
#SBATCH --job-name=16GPU
#SBATCH --time=4-00:00:00
#SBATCH --partition=gpu-cascade
#SBATCH --nodes=4
#SBATCH --exclusive
#SBATCH --qos=gpu
#SBATCH --gres=gpu:4
#SBATCH --account=[budget code]

module load nvidia/cuda-10.2
module load nvidia/mathlibs-10.2
module load boost/1.73.0
module load openmpi/4.1.0-ucx-gcc8

PRFX=/path/to/work
MINICONDA3_ROOT=${PRFX}/miniconda3/4.9.2
MPI4PY_ROOT=${PRFX}/mpi4py/3.0.3-ompi-ucx

INPUTDIR=${PRFX}/input
MESH=${INPUTDIR}/meshes/16GPU_3D_11deg_endwalls_z33.pyfrm
INIT=${INPUTDIR}/tri_airfoil_Re3000_M015_3D.ini

. ${MINICONDA3_ROOT}/activate.sh
. ${MPI4PY_ROOT}/env.sh

export SLURM_NTASKS_PER_NODE=4
export SLURM_TASKS_PER_NODE='4(x4)'

mpirun -n 16 -N 4 pyfr run -b cuda -p ${MESH} ${INIT}

conda deactivate
```


Loading the `openmpi/4.1.0-ucx-gcc8` module sets a collection of OpenMPI MCA environment variables
--------------------------------------------------------------------------------------------------

```bash
OMPI_MCA_opal_common_ucx_opal_mem_hooks=1
OMPI_MCA_UCX_MEM_MMAP_HOOK_MODE=none
OMPI_MCA_btl_openib_allow_ib=1
OMPI_MCA_btl_openib_if_include=mlx5_0:1,mlx5_1:1
OMPI_MCA_pml=ucx
OMPI_MCA_btl_openib_warn_default_gid_prefix=0
```

MCA stands for Modular Component Architecture. The settings above ensure that the openib Byte Transfer Layer (BTL)
is active and that the UCX API is used for the Point-to-point Management Layer (PML).
