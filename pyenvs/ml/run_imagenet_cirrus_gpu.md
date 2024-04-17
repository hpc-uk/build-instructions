Instructions for running the ImageNet benchmark on Cirrus (GPU)
===============================================================

The submission scripts below show how to run TensorFlow/PyTorch over multiple GPU nodes.
The jobs run benchmark scripts located within `/work/z04/shared/ml`.


Launch a TensorFlow ImageNet benchmark
--------------------------------------

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

SHARED_ML_ROOT=/work/z04/shared/ml/tensorflow
BENCHMARK_PATH=${SHARED_ML_ROOT}/benchmarks/scripts/tf_cnn_benchmarks/tf_cnn_benchmarks.py
DATA_DIR=${SHARED_ML_ROOT}/imagenet/data

export UCX_MEMTYPE_CACHE=n
export OMPI_MCA_mca_base_component_show_load_errors=0
export OMPI_MCA_mpi_warn_on_fork=0

mpirun -n ${SLURM_NTASKS} -N ${SLURM_NTASKS_PER_NODE} \
    -hostfile ${SLURM_SUBMIT_DIR}/hosts -bind-to none -map-by slot \
    -x HOROVOD_MPI=1 -x HOROVOD_MPI_THREADS_DISABLE=1 \
    -x NCCL_DEBUG=INFO -x LD_LIBRARY_PATH -x PATH \
    python ${BENCHMARK_PATH} \
        --data_format=NCHW --model=resnet50 --variable_update=horovod --num_gpus=1 \
        --data_dir=${DATA_DIR} --print_training_accuracy=True

rm -f ${SLURM_SUBMIT_DIR}/hosts
```


Launch a PyTorch ImageNet benchmark
-----------------------------------

```bash
#!/bin/bash

#SBATCH --job-name=hvpt
#SBATCH --time=02:00:00
#SBATCH --nodes=4
#SBATCH --exclusive
#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --gres=gpu:4
#SBATCH --account=[budget code]

export SLURM_NTASKS=16
export SLURM_NTASKS_PER_NODE=`expr ${SLURM_NTASKS} \/ ${SLURM_NNODES}`
export SLURM_TASKS_PER_NODE="${SLURM_NTASKS_PER_NODE}(x${SLURM_NNODES})"

module load pytorch/1.13.1-gpu

scontrol show hostnames > ${SLURM_SUBMIT_DIR}/hosts

SHARED_ROOT=/work/z04/shared/ml/pytorch
DATA_ROOT=${SHARED_ROOT}/imagenet/ILSVRC/Data/CLS-LOC
BENCHMARK_PATH=${SHARED_ROOT}/benchmarks/imagenet

rm -f ${SLURM_SUBMIT_DIR}/checkpoint-*.tar
rm -rf ${SLURM_SUBMIT_DIR}/logs

THREADS_PER_WORKER=2
WORKERS_PER_TASK=4

mpirun -n ${SLURM_NTASKS} -N ${SLURM_NTASKS_PER_NODE} \
    --mca mpi_warn_on_fork 0 \
    -hostfile ${SLURM_SUBMIT_DIR}/hosts -bind-to none -map-by slot \
    -x HOROVOD_MPI=1 -x HOROVOD_MPI_THREADS_DISABLE=1 \
    -x NCCL_DEBUG=INFO -x PYTHONWARNINGS="ignore::UserWarning" \
    -x LD_LIBRARY_PATH -x PATH \
    python ${BENCHMARK_PATH}/pytorch_imagenet_resnet50.py \
        --train-dir ${DATA_ROOT}/train --val-dir ${DATA_ROOT}/val \
        --batch-size 64 --epochs 1 \
        --num-workers ${WORKERS_PER_TASK} --num-threads-per-worker ${THREADS_PER_WORKER}

rm -f ${SLURM_SUBMIT_DIR}/hosts

sed -i "s/^M/\n/g" slurm-${SLURM_JOB_ID}.out
```
