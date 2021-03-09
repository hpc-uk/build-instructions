Instructions for building a machine learning Miniconda3 environment on Cirrus
=============================================================================

These instructions are for building a machine learning Miniconda3 environment on Cirrus
(SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using Python 3.8.

The build for this Miniconda3 environment is based on `miniconda3/4.9.2-py38`.
It provides various machine learning frameworks such as TensorFlow 2.3.0 and PyTorch 1.7.1.
Crucially, the Horovod package allows those frameworks to utilise multiple GPUS distributed
across multiple compute nodes.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
cd ${PRFX}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Set the version environment variables
-------------------------------------

```bash
CUDA_VERSION=10.1
NCCL_VERSION=2.8.3
OPENMPI_VERSION=4.1.0
PYTHON_LABEL=py38
MINICONDA_VERSION=4.9.2
```


Load the required modules
-------------------------

```bash
module load nvidia/cuda-${CUDA_VERSION}
module load nvidia/mathlibs-${CUDA_VERSION}
module load boost/1.73.0
module load openmpi/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}
module load gcc/8.2.0

module use /lustre/sw/modulefiles.dev
module load miniconda3/${MINICONDA_VERSION}-${PYTHON_LABEL}
module load cmake/3.17.3
```


Create new python environment based on the (general purpose) miniconda3 loaded above
------------------------------------------------------------------------------------

```bash
MINICONDA_ML_ROOT=/lustre/sw/miniconda3/${MINICONDA_VERSION}-${PYTHON_LABEL}-ml

python -m venv --system-site-packages ${MINICONDA_ML_ROOT}

. ${MINICONDA_ML_ROOT}/bin/activate
pip install --upgrade pip
```


Install the machine learning packages
-------------------------------------

```bash
pip install torch
pip install torchvision
pip install pytorch-lightning
pip install pytorch-lightning-bolts
pip install pytorch-lightning-bolts["extra"]
pip install wandb
pip install gym

pip install tensorflow==2.3.0
pip install tensorflow-gpu==2.3.0
pip install scikit-learn
```


Install Horovod linking with the Nvidia Collective Communications Library (NCCL)
--------------------------------------------------------------------------------

```bash
NCCL_ROOT=/lustre/sw/nvidia/nccl/${NCCL_VERSION}-cuda-${CUDA_VERSION}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${NCCL_ROOT}/lib
HOROVOD_NCCL_HOME=${NCCL_ROOT} HOROVOD_GPU_OPERATIONS=NCCL pip install --no-cache-dir horovod
```


Finish by deactivating the virtual environment
----------------------------------------------

```bash
deactivate
module unload miniconda3/4.9.2-py38
```
