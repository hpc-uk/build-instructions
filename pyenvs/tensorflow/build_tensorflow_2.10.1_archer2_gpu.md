Instructions for installing TensorFlow 2.10.1 for use on the ARCHER2 GPU nodes
==============================================================================

These instructions show how to install TensorFlow 2.10.1 for use on the ARCHER2 GPU nodes (HPE Cray EX, AMD EPYC 7534P, AMD Instinct MI210).

Unfortunately, this information is for reference only as currently TensorFlow cannot be installed/built for use on the ARCHER2 GPU nodes.
This is because of a fundamental version incompatibility between TensorFlow, ROCm and AMD MI210 GFX.

TensorFlow 2.10.x is apparently compatible with ROCm 5.2.x but not with GFX 9.0.a, and those versions of TensorFlow that are compatible with GFX 9.0.a
are not compatible with ROCm 5.2.x.

The information on this page are based on [LUMI TensorFlow-ROCM Docker file](https://lumi-supercomputer.github.io/LUMI-EasyBuild-docs/t/TensorFlow/TensorFlow-2.11.1-rocm-5.5.1-python-3.10-horovod-0.28.1-singularity-20231110-docker).

Note, Horovod 0.28.1, a *distributed* deep learning training framework, is also installed in the environment - this package can be used
to run TensorFlow across multiple GPU nodes.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # i.e., PRFX=/work/y07/shared/python/core
cd ${PRFX}

TENSORFLOW_LABEL=tensorflow
TENSORFLOW_VERSION=2.10.1
TENSORFLOW_ROOT=${PRFX}/${TENSORFLOW_LABEL}/${TENSORFLOW_VERSION}-gpu

module -q load PrgEnv-gnu
module -q load craype-x86-milan
module -q load craype-accel-amd-gfx90a
module -q load cray-python/3.9.13.1
module -q load cray-hdf5-parallel/1.12.2.1
module -q load rocm/5.2.3
module -q load cmake/3.21.3

PYTHON_VER=`echo ${CRAY_PYTHON_LEVEL} | cut -d'.' -f1-2`
PYTHON_DIR=${TENSORFLOW_ROOT}/python
PYTHON_BIN=${PYTHON_DIR}/${CRAY_PYTHON_LEVEL}/bin

PYTHON_VER2=${PYTHON_VER/./}
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


Upgrade mpi4py
--------------

```bash
cd ${TENSORFLOW_ROOT}

pip install --no-binary=mpi4py --upgrade mpi4py
```


Install supporting packages
---------------------------

```bash
cd ${TENSORFLOW_ROOT}

pip install --user wandb
pip install --user gym
pip install --user pyspark
pip install --user scikit-learn
pip install --user scikit-image
pip install --user opencv-python
pip install --user wheel
pip install --user tomli
pip install --user h5py
pip install --user numba
```


Build a library for reading and writing CXI files
-------------------------------------------------

```bash
mkdir -p ${TENSORFLOW_ROOT}/repos
cd ${TENSORFLOW_ROOT}/repos

git clone https://github.com/cxidb/libcxi.git

cd ./libcxi

mkdir ./build
cd ./build

cmake ..

make -j 8

cd ..
mkdir lib
cp ./build/libcxi.so ./lib/
```


Build the AWS OFI RCCL plugin
-----------------------------

AWS OFI RCCL is a plugin which enables EC2 developers to use libfabric as a network provider while running AMD's RCCL based applications.
In short, the AWS OFI RCCL plugin is a library that can be used as a back-end for RCCL to interact with the Slingshot interconnect via libfabric.

```bash
cd ${TENSORFLOW_ROOT}/repos

git clone -b cxi https://github.com/ROCmSoftwarePlatform/aws-ofi-rccl

cd ./aws-ofi-rccl

./autogen.sh

LIBFABRIC_PATH=/opt/cray/libfabric/1.12.1.2.2.0.0

export CPATH=${LIBFABRIC_PATH}/include
export LIBRARY_PATH=${TENSORFLOW_ROOT}/repos/libcxi/lib:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${TENSORFLOW_ROOT}/repos/libcxi/lib:${LD_LIBRARY_PATH}

LDFLAGS='-lcxi' CC=cc ./configure --with-libfabric=${LIBFABRIC_PATH} --enable-trace --with-hip=${ROCM_PATH} --with-rccl=${ROCM_PATH}/rccl --disable-tests
LDFLAGS='-lcxi' CC=cc make -j 8

cp -r ./src/.libs ./lib

export LD_LIBRARY_PATH=${TENSORFLOW_ROOT}/repos/aws-ofi-rccl/lib:${LD_LIBRARY_PATH}
```


Build a test suite for checking both the performance and the correctness of RCCL operations 
-------------------------------------------------------------------------------------------

```bash
cd ${TENSORFLOW_ROOT}/repos

git clone https://github.com/ROCmSoftwarePlatform/rccl-tests

cd ./rccl-tests

export CXI_FORK_SAFE=1
export CXI_FORK_SAFE_HP=1
export FI_CXI_DISABLE_CQ_HUGETLB=1

sed -i 's/-std=c++14/-std=c++14 --amdgpu-target=gfx90a:xnack- --amdgpu-target=gfx90a:xnack+/g' ./src/Makefile

CC=cc DEBUG=0 CXX=CC PREFIX=${TENSORFLOW_ROOT}/repos/rccl-tests/bin MPI_HOME=${CRAY_MPICH_DIR} ROCM_PATH=${ROCM_PATH} MPI=1 NCCL_HOME=${ROCM_PATH}/rccl make -j 8

mv ./build ./bin
```


Install TensorFlow for ROCm
---------------------------

```bash
cd ${TENSORFLOW_ROOT}

TF_VER=`echo ${TENSORFLOW_VERSION} | cut -d. -f1-2`
TF_VER=${TF_VER/./}

TF_ROCM_VERSION=`echo ${CRAY_ROCM_VERSION} | cut -d- -f1`

TF_ROCM_VER=`echo ${TF_ROCM_VERSION} | cut -d. -f1-2`
TF_ROCM_VER=${TF_ROCM_VER}.0
TF_ROCM_VER2=${TF_ROCM_VER//./}

TF_ROCM_WHEEL=tensorflow_rocm-${TENSORFLOW_VERSION}.${TF_ROCM_VER2}-cp${PYTHON_VER2}-cp${PYTHON_VER2}-manylinux2014_x86_64.whl

wget http://ml-ci.amd.com:21096/job/tensorflow/job/release-rocmfork-r${TF_VER}-rocm-enhanced/job/rocm-${TF_ROCM_VER}-python3x-manylinux2014-whls/lastSuccessfulBuild/artifact/artifactory/${TF_ROCM_WHEEL}

pip install --user ${TF_ROCM_WHEEL}
```


Install OpenNMT-tf
------------------

OpenNMT-tf (https://opennmt.net/) is a general purpose sequence learning toolkit using TensorFlow 2.
Version 2.29.0 is compatible with TensorFlow 2.10.

```bash
cd ${TENSORFLOW_ROOT}

pip install --user opennmt-tf==2.29.0
```


Install Tensorboard packages
----------------------------

```bash
cd ${TENSORFLOW_ROOT}

pip install --user tensorboard_plugin_profile
```


Install Horovod
---------------

```bash
cd ${TENSORFLOW_ROOT}

CC=cc CXX=CC FC=ftn HOROVOD_CPU_OPERATIONS=MPI HOROVOD_WITH_MPI=1 HOROVOD_GPU_OPERATIONS=NCCL HOROVOD_GPU=ROCM HCC_AMDGPU_TARGET=gfx90a HOROVOD_ROCM_HOME=${CRAY_ROCM_DIR} HOROVOD_RCCL_HOME=${ROCM_PATH}/rccl RCCL_INCLUDE_DIRS=${ROCM_PATH}/rccl/include HOROVOD_RCCL_LIB=${ROCM_PATH}/rccl/lib CMAKE_PREFIX_PATH=${CRAY_MPICH_DIR} HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=0 HOROVOD_WITH_MXNET=0 HOROVOD_WITH_GLOO=0 pip install --user --no-cache-dir --force-reinstall --no-deps --verbose horovod[tensorflow]==0.28.1
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
A user may build a local Python environment based on this module, `tensorflow/2.10.1-gpu`, which
means that module must be loaded whenever the local environment is activated.

The `extend-venv-activate` script ensures that this happens: it modifies the local environment's
activate script such that the `tensorflow/2.10.1-gpu` module is loaded during activation and unloaded
during deactivation.

The contents of the `extend-venv-activate` script are shown below. The file itself must be added
to the `${PYTHON_BIN}` directory.

```bash
#!/bin/bash

# add extra activate commands
MARK="# you cannot run it directly"
CMDS="${MARK}\n\n"
CMDS="${CMDS}module -q load tensorflow/2.10.1-gpu\n\n"
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
CMDS="${CMDS}${INDENT}module -q unload tensorflow/2.10.1-gpu"

sed -ri "s:${MARK}:${CMDS}:g" ${1}/bin/activate
``` 

Lastly, remember to set read and execute permission for all users, i.e., `chmod a+rx ${PYTHON_BIN}/extend-venv-activate`.

See the link below for an example of how the `extend-venv-activate` script is called.

[https://docs.archer2.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip](https://docs.archer2.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip)
