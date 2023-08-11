Instructions for installing TensorFlow 2.9.3 on ARCHER2
=======================================================

These instructions show how to install TensorFlow 2.9.3 for use on ARCHER2 (HPE Cray EX, AMD Zen2 7742).

This version of TensorFlow is compatible with the Cray PE DL Plugin 22.12.1. The plugin provides a highly tuned communication layer
that can be easily added to any deep learning framework.

Horovod 0.28.1, a distributed deep learning training framework, is also installed - this package provides an alternative method
for running TensorFlow across multiple compute nodes.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
TENSORFLOW_LABEL=tensorflow
TENSORFLOW_VERSION=2.9.3
TENSORFLOW_ROOT=${PRFX}/${TENSORFLOW_LABEL}

module load PrgEnv-gnu
module load cray-python
module load cmake/3.21.3

PYTHON_VER=`echo ${CRAY_PYTHON_LEVEL} | cut -d'.' -f1-2`
PYTHON_DIR=${PRFX}/${TENSORFLOW_LABEL}/${TENSORFLOW_VERSION}/python
PYTHON_BIN=${PYTHON_DIR}/${CRAY_PYTHON_LEVEL}/bin
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Create and setup the TensorFlow virtual python environment
----------------------------------------------------------

```bash
mkdir -p ${PYTHON_BIN}

export PIP_CACHE_DIR=${PYTHON_DIR}/.cache/pip

export PYTHONUSERBASE=${PYTHON_DIR}/${CRAY_PYTHON_LEVEL}
export PATH=${PYTHONUSERBASE}/bin:${PATH}
export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHONVER}/site-packages:${PYTHONPATH}

pip install --user --upgrade pip
```


Install supporting packages
---------------------------

```bash
pip install --user iniconfig
pip install --user toml
pip install --user memory_profiler
pip install --user matplotlib
pip install --user pyqt5
pip install --user graphviz
pip install --user nltk
pip install --user jupyter
pip install --user jupyterlab
pip install --user wandb
pip install --user gym
pip install --user pyspark
pip install --user scikit-learn
pip install --user scikit-image
```


Install the TensorFlow packages
-------------------------------

```bash
pip install --user tensorflow==${TENSORFLOW_VERSION}
pip install --user tensorflow-cpu==${TENSORFLOW_VERSION}
pip install --user tensorboard_plugin_profile
```


Install Numba
-------------

Numba is an open source JIT compiler that translates a subset of Python and NumPy code into fast machine code.

```bash
pip install --user numba
```


Install Horovod
---------------

```bash
CC=mpicc CXX=mpicxx FC=mpifort HOROVOD_CPU_OPERATIONS=MPI HOROVOD_WITH_MPI=1 HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=0 HOROVOD_WITH_MXNET=0 pip install --user --no-cache-dir horovod[tensorflow]==0.28.1
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
