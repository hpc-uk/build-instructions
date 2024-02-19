Instructions for installing TensorFlow 2.15.0 for Cirrus GPU nodes
==================================================================

These instructions show how to install TensorFlow 2.15.0 for use on the Cirrus GPU nodes (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB).

Horovod 0.28.1, a distributed deep learning training framework, is also installed - this package is required
for running TensorFlow across multiple compute nodes.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software
cd ${PRFX}

TENSORFLOW_LABEL=tensorflow
TENSORFLOW_VERSION=2.15.0
TENSORFLOW_ROOT=${PRFX}/${TENSORFLOW_LABEL}

CUDA_VERSION=11.6
CUDNN_VERSION=8.6.0-cuda-${CUDA_VERSION}
TENSORRT_VERSION=8.4.3.1-u2

module load python/3.10.8-gpu
module load nvidia/cudnn/${CUDNN_VERSION}
module load nvidia/tensorrt/${TENSORRT_VERSION}

PYTHON_VER=`echo ${MINICONDA3_PYTHON_VERSION} | cut -d'.' -f1-2`
PYTHON_DIR=${PRFX}/${TENSORFLOW_LABEL}/${TENSORFLOW_VERSION}-gpu/python
PYTHON_BIN=${PYTHON_DIR}/${MINICONDA3_PYTHON_VERSION}/bin
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Create and setup the TensorFlow virtual python environment
----------------------------------------------------------

```bash
mkdir -p ${PYTHON_BIN}

export PIP_CACHE_DIR=${PYTHON_DIR}/.cache/pip

export PYTHONUSERBASE=${PYTHON_DIR}/${MINICONDA3_PYTHON_VERSION}
export PATH=${PYTHONUSERBASE}/bin:${PATH}
export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHON_VER}/site-packages:${PYTHONPATH}

pip install --user --upgrade pip
```


Install the TensorFlow packages
-------------------------------

```bash
pip install --user tensorflow==${TENSORFLOW_VERSION}
pip install --user tensorboard_plugin_profile
```


Install Horovod linking with the Nvidia Collective Communications Library (NCCL)
--------------------------------------------------------------------------------

Please note, in preparation for the Horovod install, you must check that `libcuda.so.1` exists as soft link to `libcuda.so` in `${NVHPC_ROOT}/cuda/lib64/stubs`.

```bash
module load cmake/3.25.2

export LD_LIBRARY_PATH=${NVHPC_ROOT}/cuda/lib64/stubs:${LD_LIBRARY_PATH}

CC=mpicc CXX=mpicxx FC=mpifort HOROVOD_CUDA_HOME=${NVHPC_ROOT}/cuda/${CUDA_VERSION} HOROVOD_NCCL_HOME=${NVHPC_ROOT}/comm_libs/nccl HOROVOD_GPU=CUDA HOROVOD_BUILD_CUDA_CC_LIST=70 HOROVOD_CPU_OPERATIONS=MPI HOROVOD_GPU_OPERATIONS=NCCL HOROVOD_WITH_MPI=1 HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=0 HOROVOD_WITH_MXNET=0 CUDA_PATH=${NVHPC_ROOT}/cuda/${CUDA_VERSION} pip install --user --no-cache-dir -v horovod[tensorflow]==0.28.1
```

Now run `horovodrun --check-build` to confirm that Horovod has been installed correctly. That command should return something like the following output.

```bash
Horovod v0.28.1:

Available Frameworks:
    [X] TensorFlow
    [ ] PyTorch
    [ ] MXNet

Available Controllers:
    [X] MPI
    [X] Gloo

Available Tensor Operations:
    [X] NCCL
    [ ] DDL
    [ ] CCL
    [X] MPI
    [X] Gloo 
```
