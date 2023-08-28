Instructions for installing TensorFlow 2.13.0 for Cirrus CPU nodes
==================================================================

These instructions show how to install TensorFlow 2.13.0 for use on the Cirrus CPU nodes (Intel Xeon E5-2695, Broadwell).

Horovod 0.28.1, a distributed deep learning training framework, is also installed - this package is required
for running TensorFlow across multiple compute nodes.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/mnt/lustre/indy2lfs/sw
TENSORFLOW_LABEL=tensorflow
TENSORFLOW_VERSION=2.13.0
TENSORFLOW_ROOT=${PRFX}/${TENSORFLOW_LABEL}

HOROVOD_VERSION=0.28.1

module load python/3.9.13

PYTHON_VER=`echo ${MINICONDA3_PYTHON_VERSION} | cut -d'.' -f1-2`
PYTHON_DIR=${PRFX}/${TENSORFLOW_LABEL}/${TENSORFLOW_VERSION}/python
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


Install supporting packages
---------------------------

```bash
pip install --user pyspark
pip install --user scikit-learn
pip install --user scikit-image
pip install --user opencv-python
```


Install the TensorFlow packages
-------------------------------

```bash
pip install --user tensorflow==${TENSORFLOW_VERSION}
pip install --user tensorflow-cpu==${TENSORFLOW_VERSION}
pip install --user tensorboard_plugin_profile
```


Install Horovod
---------------

```bash
module load cmake

CC=mpicc CXX=mpicxx FC=mpifort HOROVOD_CPU_OPERATIONS=MPI HOROVOD_WITH_MPI=1 HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=0 HOROVOD_WITH_MXNET=0 pip install --user --no-cache-dir -v horovod[tensorflow]==${HOROVOD_VERSION}
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
    [ ] NCCL
    [ ] DDL
    [ ] CCL
    [X] MPI
    [X] Gloo 
```
