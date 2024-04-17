Instructions for running the MNIST benchmark on Cirrus (GPU)
============================================================

The submission scripts below show how to run TensorFlow/PyTorch over multiple GPU nodes.
The jobs run benchmark scripts located within `/work/z04/shared/ml`.


Launch a TensorFlow MNIST benchmark
-----------------------------------

The script below launches a TensorFlow job that uses 16 GPUs across 4 Cascade Lake GPU nodes.

```bash
#!/bin/bash

#SBATCH --job-name=hvtf
#SBATCH --time=00:20:00
#SBATCH --nodes=4
#SBATCH --exclusive
#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --gres=gpu:4
#SBATCH --account=[budget code]

export SLURM_NTASKS=16
export SLURM_NTASKS_PER_NODE=`expr ${SLURM_NTASKS} \/ ${SLURM_NNODES}`
export SLURM_TASKS_PER_NODE="${SLURM_NTASKS_PER_NODE}(x${SLURM_NNODES})"

module load tensorflow/2.13.0-gpu

scontrol show hostnames > ${SLURM_SUBMIT_DIR}/hosts

WORK_ROOT=${HOME/home/work}
DATA_ROOT=${WORK_ROOT}/.keras/datasets
rm -rf ${DATA_ROOT}
mkdir ${DATA_ROOT}

SHARED_ROOT=/work/z04/shared/ml/tensorflow/mnist
for tk in $(seq ${SLURM_NTASKS}); do
  rk=`expr ${tk} - 1`
  cp ${SHARED_ROOT}/data/mnist.npz ${DATA_ROOT}/mnist-${rk}.npz
done

mpirun -n ${SLURM_NTASKS} -N ${SLURM_NTASKS_PER_NODE} \
    -hostfile ${SLURM_SUBMIT_DIR}/hosts -bind-to none -map-by slot \
    -x HOROVOD_MPI=1 -x HOROVOD_MPI_THREADS_DISABLE=1 \
    -x NCCL_DEBUG=INFO -x LD_LIBRARY_PATH -x PATH \
    python ${SHARED_ROOT}/tensorflow_mnist.py \
        --cache ${DATA_ROOT}

rm -f ${SLURM_SUBMIT_DIR}/hosts

CHECKPOINT_ROOT=${SLURM_SUBMIT_DIR}/checkpoints-${SLURM_JOBID}
mkdir ${CHECKPOINT_ROOT}
mv checkpoint ${CHECKPOINT_ROOT}/
mv checkpoints-*.data* ${CHECKPOINT_ROOT}/
mv checkpoints-*.index* ${CHECKPOINT_ROOT}/
```

If you wish to increase the number of GPUs to 32 for example, you will need to make
two changes to the script above.

```bash
...
#SBATCH --nodes=8
...
export SLURM_NTASKS=32
...
```

And if you wish to adjust the number of GPUs per node you will need to change
the `#SBATCH --gres=gpu:4` directive also.


Launch a PyTorch MNIST benchmark
--------------------------------

The script below launches a PyTorch job that uses 2 GPUs on one Cascade Lake GPU node.

```bash
#!/bin/bash

#SBATCH --job-name=hvpt
#SBATCH --time=00:20:00
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --gres=gpu:2
#SBATCH --account=[budget code]

export SLURM_NTASKS=2
export SLURM_NTASKS_PER_NODE=`expr ${SLURM_NTASKS} \/ ${SLURM_NNODES}`
export SLURM_TASKS_PER_NODE="${SLURM_NTASKS_PER_NODE}(x${SLURM_NNODES})"

module load pytorch/1.13.1-gpu

scontrol show hostnames > ${SLURM_SUBMIT_DIR}/hosts

SHARED_ROOT=/work/z04/shared/ml/pytorch/mnist

if [ ! -d ${SLURM_SUBMIT_DIR}/data ]; then
  cp -r ${SHARED_ROOT}/data ${SLURM_SUBMIT_DIR}/
fi

mpirun -n ${SLURM_NTASKS} -N ${SLURM_NTASKS_PER_NODE} \
    --mca mpi_warn_on_fork 0 \
    -hostfile ${SLURM_SUBMIT_DIR}/hosts -bind-to none -map-by slot \
    -x HOROVOD_MPI=1 -x HOROVOD_MPI_THREADS_DISABLE=1 \
    -x NCCL_DEBUG=INFO -x PYTHONWARNINGS="ignore::UserWarning" \
    -x LD_LIBRARY_PATH -x PATH \
    python ${SHARED_ROOT}/pytorch_mnist.py \
        --data-dir ${SLURM_SUBMIT_DIR}/data --batch-size 64 --epochs 10

rm -f hosts
```

If you wish to increase the number of GPUs to 4 for example, you will need to make
two changes to the script above.

```bash
...
#SBATCH --gres=gpu:4
...
export SLURM_NTASKS=4
...
```

And if you wish to use more than one GPU node you will need to change
the `#SBATCH --nodes=1` directive also.
