Instructions for building TensorFlow 2.14.0 from source for use on the ARCHER2 CPU nodes
========================================================================================

These instructions show how to build and install TensorFlow 2.14.0 from source for use on ARCHER2 (HPE Cray EX, AMD Zen2 7742).

Horovod 0.28.1, a distributed deep learning training framework, is also installed - this package is required for running
TensorFlow across multiple compute nodes.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # i.e., PRFX=/work/y07/shared/python/core
cd ${PRFX}

TENSORFLOW_LABEL=tensorflow
TENSORFLOW_VERSION=2.14.0
TENSORFLOW_NAME=${TENSORFLOW_LABEL}-${TENSORFLOW_VERSION}
TENSORFLOW_ROOT=${PRFX}/${TENSORFLOW_LABEL}

module -q load PrgEnv-gnu
module -q load cray-python

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
pip install --user wandb
pip install --user gym
pip install --user pyspark
pip install --user scikit-learn
pip install --user scikit-image
```


Prepare for installing tools required for building TensorFlow from source
-------------------------------------------------------------------------

```bash
TF_PRFX=${PRFX}/${TENSORFLOW_LABEL}/${TENSORFLOW_VERSION}
```


Install Bazel
-------------

Install the Bazel build tool.

```bash
BAZEL_LABEL=bazel
BAZEL_VERSION=6.1.0
BAZEL_ROOT=${TF_PRFX}/${BAZEL_LABEL}
BAZEL_NAME=${BAZEL_LABEL}-${BAZEL_VERSION}
BAZEL_INSTALL=${BAZEL_ROOT}/${BAZEL_VERSION}
BAZEL_INSTALLER=${BAZEL_NAME}-installer-linux-x86_64.sh

mkdir -p ${BAZEL_ROOT}
cd ${BAZEL_ROOT}

wget https://github.com/bazelbuild/${BAZEL_LABEL}/releases/download/${BAZEL_VERSION}/${BAZEL_INSTALLER}
bash ./${BAZEL_INSTALLER} --prefix=${BAZEL_INSTALL}
rm ./${BAZEL_INSTALLER}

export PATH=${BAZEL_INSTALL}/lib/${BAZEL_LABEL}/bin:${PATH}
```


Install patchelf
----------------

PatchELF is a simple utility for modifying existing ELF executables and libraries.
This tool is required for the building of the TensorFlow package.

```bash
PATCHELF_LABEL=patchelf
PATCHELF_VERSION=0.18.0
PATCHELF_NAME=${PATCHELF_LABEL}-${PATCHELF_VERSION}
PATCHELF_ROOT=${TF_PRFX}/${PATCHELF_LABEL}
PATCHELF_INSTALL=${PATCHELF_ROOT}/${PATCHELF_VERSION}

mkdir -p ${PATCHELF_ROOT}
cd ${PATCHELF_ROOT}

git clone https://github.com/NixOS/${PATCHELF_LABEL}.git ${PATCHELF_NAME}
cd ${PATCHELF_NAME}
git checkout ${PATCHELF_VERSION}

./bootstrap.sh

./configure --prefix=${PATCHELF_INSTALL}

make
make install
make clean

export PATH=${PATCHELF_INSTALL}/bin:${PATH}
```


Download TensorFlow source
--------------------------

```bash
cd ${TF_PRFX}

mkdir -p ${TENSORFLOW_LABEL}
cd ${TENSORFLOW_LABEL}

git clone https://github.com/${TENSORFLOW_LABEL}/${TENSORFLOW_LABEL}.git ${TENSORFLOW_NAME}
cd ${TENSORFLOW_NAME}
git checkout v${TENSORFLOW_VERSION}
```


Configure TensorFlow build environment
--------------------------------------

```bash
export TF_PYTHON_VERSION=${PYTHON_VER}
export TF_NEED_ROCM=0
export TF_NEED_CUDA=0
export TF_NEED_CLANG=0
export TF_SET_ANDROID_WORKSPACE=0

python configure.py
```

When you come to run the `configure.py` script you will be prompted for three pieces of information.

First, you will be asked for the location of the Python executable.
Simply select the default path by hitting return.

Second, you'll be prompted for the Python library path.
Please enter the path suitable for this install, i.e., `${PYTHONUSERBASE}/lib/python${PYTHON_VER}/site-packages`.
 
Lastly, you will be asked to specify the optimization flags.
Just hit return here as we'll specify the options by directly editing the `.tf_configure.bazelrc` file, see below.


Append the following options to the `.tf_configure.bazelrc` file
----------------------------------------------------------------

The `.tf_configure.bazelrc` file should exist in `${TF_PRFX}/${TENSORFLOW_LABEL}/${TENSORFLOW_NAME}`.
It contains two `build:opt` lines.

```bash
build:opt --copt=-Wno-sign-compare
build:opt --host_copt=-Wno-sign-compare
```

Those lines must be replaced with six new `build:opt` lines, see below.

```bash
build:opt --cxxopt=-msse3 --copt=-msse3 --host_cxxopt=-march=native --host_copt=-march=native
build:opt --cxxopt=-msse4.1 --copt=-msse4.1 --host_cxxopt=-march=native --host_copt=-march=native
build:opt --cxxopt=-msse4.2 --copt=-msse4.2 --host_cxxopt=-march=native --host_copt=-march=native
build:opt --cxxopt=-mavx --copt=-mavx --host_cxxopt=-march=native --host_copt=-march=native
build:opt --cxxopt=-mavx2 --copt=-mavx2 --host_cxxopt=-march=native --host_copt=-march=native
build:opt --cxxopt=-mfma --copt=-mfma --host_cxxopt=-march=native --host_copt=-march=native
```

The new options ensure that TensorFlow is optimized for the various instructions sets supported
by the AMD Zen2 (Rome) EPYC 7742 processor present on ARCHER2.


Build TensorFlow
----------------

This stage consists of two steps, building the TensorFlow package builder and building the
TensorFlow package.

The first step proceeds through more than 22k actions (i.e., compilations), taking over 2 hours
to complete and requiring a significant amount of memory. For these reasons it is best to 
build the package builder from within a serial job.

The second step takes much less time (minutes rather than hours) but does generate a lot
of output; so, the command for building the TensorFlow package is added to the serial job
submission script, see below.

```bash
#!/bin/bash

#SBATCH --job-name=tf-build
#SBATCH --time=04:00:00
#SBATCH --ntasks=8
#SBATCH --mem=32G
#SBATCH --account=z19
#SBATCH --partition=serial
#SBATCH --qos=serial

PRFX=/path/to/work
TENSORFLOW_LABEL=tensorflow
TENSORFLOW_VERSION=2.14.0
TENSORFLOW_NAME=${TENSORFLOW_LABEL}-${TENSORFLOW_VERSION}
TENSORFLOW_ROOT=${PRFX}/${TENSORFLOW_LABEL}

module -q load PrgEnv-gnu
module -q load cray-python

PYTHON_VER=`echo ${CRAY_PYTHON_LEVEL} | cut -d'.' -f1-2`
PYTHON_DIR=${PRFX}/${TENSORFLOW_LABEL}/${TENSORFLOW_VERSION}/python
PYTHON_BIN=${PYTHON_DIR}/${CRAY_PYTHON_LEVEL}/bin

export PIP_CACHE_DIR=${PYTHON_DIR}/.cache/pip

export PYTHONUSERBASE=${PYTHON_DIR}/${CRAY_PYTHON_LEVEL}
export PATH=${PYTHONUSERBASE}/bin:${PATH}
export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHON_VER}/site-packages:${PYTHONPATH}

TF_PRFX=${PRFX}/${TENSORFLOW_LABEL}/${TENSORFLOW_VERSION}
export PATH=${TF_PRFX}/bazel/6.1.0/lib/bazel/bin:${PATH}
export PATH=${TF_PRFX}/patchelf/0.18.0/bin:${PATH}

export TF_PYTHON_VERSION=${PYTHON_VER}

cd ${TF_PRFX}/${TENSORFLOW_LABEL}/${TENSORFLOW_NAME}


# build the TensorFlow package builder
bazel build --jobs ${SLURM_NTASKS} --verbose_failures --config=opt //tensorflow/tools/pip_package:build_pip_package &> build-tf-package-builder.out.${SLURM_JOB_ID}

# build the TensorFlow package
./bazel-bin/tensorflow/tools/pip_package/build_pip_package ./tensorflow_pkg &> build-tf-package.out.${SLURM_JOB_ID}
```


Install TensorFlow
------------------

```bash
cd ${TF_PRFX}/${TENSORFLOW_LABEL}/${TENSORFLOW_NAME}

pip install --user ./tensorflow_pkg/${TENSORFLOW_NAME}-cp${PYTHON_VER//.}-cp${PYTHON_VER//.}-linux_x86_64.whl
```


Install Horovod
---------------

```bash
module -q load cmake/3.21.3

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
A user may build a local Python environment based on this module, `tensorflow/2.14.0`, which
means that module must be loaded whenever the local environment is activated.

The `extend-venv-activate` script ensures that this happens: it modifies the local environment's
activate script such that the `tensorflow/2.14.0` module is loaded during activation and unloaded
during deactivation.

The contents of the `extend-venv-activate` script are shown below. The file itself must be added
to the `${PYTHON_BIN}` directory.

```bash
#!/bin/bash

# add extra activate commands
MARK="# you cannot run it directly"
CMDS="${MARK}\n\n"
CMDS="${CMDS}module -q load tensorflow/2.14.0\n\n"
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
CMDS="${CMDS}${INDENT}module -q unload tensorflow/2.14.0"

sed -ri "s:${MARK}:${CMDS}:g" ${1}/bin/activate
```

Lastly, remember to set read and execute permission for all users, i.e., `chmod a+rx ${PYTHON_BIN}/extend-venv-activate`.

See the link below for an example of how the `extend-venv-activate` script is called.

[https://docs.archer2.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip](https://docs.archer2.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip)
