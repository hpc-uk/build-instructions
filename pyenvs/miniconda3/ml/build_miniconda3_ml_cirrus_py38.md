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

PYTHON_LABEL=py38
MINICONDA_VERSION=4.9.2
CUDA_VERSION=11.2
NCCL_VERSION=2.8.3
OPENMPI_VERSION=4.1.0
BOOST_VERSION=1.73.0
CMAKE_VERSION=3.17.3

module load nvidia/cuda-${CUDA_VERSION}
module load nvidia/mathlibs-${CUDA_VERSION}
module load boost/${BOOST_VERSION}
module load openmpi/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}
module load boost/${BOOST_VERSION}
module load cmake/${CMAKE_VERSION}

module use /lustre/sw/modulefiles.dev
module load miniconda3/${MINICONDA_VERSION}-${PYTHON_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


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

pip install tensorflow
pip install tensorflow-gpu
pip install scikit-learn
pip install scikit-image
```


Install Horovod linking with the Nvidia Collective Communications Library (NCCL)
--------------------------------------------------------------------------------

```bash
NCCL_ROOT=/lustre/sw/nvidia/hpcsdk-212/Linux_x86_64/21.2/comm_libs/${CUDA_VERSION}/nccl
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${NCCL_ROOT}/lib
HOROVOD_NCCL_HOME=${NCCL_ROOT} HOROVOD_GPU_OPERATIONS=NCCL pip install --no-cache-dir horovod
```


Finish by deactivating the virtual environment
----------------------------------------------

```bash
deactivate
module unload miniconda3/4.9.2-py38
```
