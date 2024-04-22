Instructions for installing TensorFlow 2.12.0 for use on the ARCHER2 CPU nodes
==============================================================================

These instructions show how to install TensorFlow 2.12.0 for use on ARCHER2 (HPE Cray EX, AMD Zen2 7742).

Horovod 0.28.1, a distributed deep learning training framework, is also installed - this package is required
for running TensorFlow across multiple compute nodes.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # i.e., PRFX=/work/y07/shared/python/core
cd ${PRFX}

TENSORFLOW_LABEL=tensorflow
TENSORFLOW_VERSION=2.12.0
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
export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHON_VER}/site-packages:${PYTHONPATH}

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
pip install --user wheel
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


Create `extend-venv-activate` script
------------------------------------

The TensorFlow Python environment described here is encapsulated as an Lmod module file on Cirrus.
A user may build a local Python environment based on this module, `tensorflow/2.12.0`, which
means that module must be loaded whenever the local environment is activated.

The `extend-venv-activate` script ensures that this happens: it modifies the local environment's
activate script such that the `tensorflow/2.12.0` module is loaded during activation and unloaded
during deactivation.

The contents of the `extend-venv-activate` script are shown below. The file itself must be added
to the `${PYTHON_BIN}` directory.

```bash
#!/bin/bash

# add extra activate commands
MARK="# you cannot run it directly"
CMDS="${MARK}\n\n"
CMDS="${CMDS}module -q load tensorflow/2.12.0\n\n"
CMDS="${CMDS}CRAY_PYTHON_VER=\`echo \${CRAY_PYTHON_LEVEL} | cut -d'.' -f1-2\`\n"
CMDS="${CMDS}PYTHONUSERSITEPKGS=${1}/lib/python\${CRAY_PYTHON_VER}/site-packages\n"
CMDS="${CMDS}if [[ \${PYTHONPATH} != *\"\${PYTHONUSERSITEPKGS}\"* ]]; then\n"
CMDS="${CMDS}  export PYTHONPATH=\${PYTHONUSERSITEPKGS}\:\${PYTHONPATH}\n"
CMDS="${CMDS}fi\n\n"

sed -ri "s:${MARK}:${CMDS}:g" ${1}/bin/activate


# add extra deactivation commands
INDENT="        "
MARK="unset -f deactivate"
CMDS="${MARK}\n\n"
CMDS="${CMDS}${INDENT}export PYTHONPATH=\`echo \${PYTHONPATH} | sed \"\s\:\${PYTHONUSERSITEPKGS}\\\\\:\:\:\g\"\`\n"
CMDS="${CMDS}${INDENT}module -q unload tensorflow/2.12.0"

sed -ri "s:${MARK}:${CMDS}:g" ${1}/bin/activate
``` 

Lastly, remember to set read and execute permission for all users, i.e., `chmod a+rx ${PYTHON_BIN}/extend-venv-activate`.

See the link below for an example of how the `extend-venv-activate` script is called.

[https://docs.archer2.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip](https://docs.archer2.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip)
