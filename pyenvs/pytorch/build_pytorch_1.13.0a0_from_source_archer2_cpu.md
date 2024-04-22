Instructions for building PyTorch 1.13.0a0 from source for use on the ARCHER2 CPU nodes
=======================================================================================

These instructions show how to build PyTorch 1.13.0a0 for use on the ARCHER2 CPU nodes (HPE Cray EX, AMD Zen2 7742).
Please note, PyTorch source version 1.13.0a0 corresponds to PyTorch package version 1.13.1.

This is a somewhat complicated process as we first need to setup a Miniconda environment solely for the
purpose of building PyTorch. Further, the memory requirements of the build process necessitate building
PyTorch from a dedicated compute node rather than from a login or serial node.

A reason for building PyTorch from source is to ensure that the `torch.distributed` module is hooked up to the
appropriate HPE MPICH libraries, allowing PyTorch jobs to be run across multiple compute nodes. However, distributing
ML workloads in this fashion can also be done using `horovod` alongside `mpi4py`. Those packages are installed in
the final PyTorch installation environment, near the end of these instructions.


Setup module environment for PyTorch build
------------------------------------------

```bash
PRFX=/path/to/work
cd ${PRFX}
 
module load PrgEnv-gnu
module load cray-fftw
module load mkl/2023.0.0
module load cmake/3.21.3
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Create and setup a Miniconda3 build environment
-----------------------------------------------

```bash
PYTHON_LABEL=py39
MINICONDA_TAG=miniconda
MINICONDA_LABEL=${MINICONDA_TAG}3
MINICONDA_VERSION=24.1.2-0
MINICONDA_ROOT=${PRFX}/${MINICONDA_LABEL}/${MINICONDA_VERSION}-${PYTHON_LABEL}
MINICONDA_TITLE=${MINICONDA_LABEL^}
MINICONDA_BASH_SCRIPT=${MINICONDA_TITLE}-${PYTHON_LABEL}_${MINICONDA_VERSION}-Linux-x86_64.sh

mkdir -p ${MINICONDA_LABEL}
cd ${MINICONDA_LABEL}

wget https://repo.anaconda.com/${MINICONDA_TAG}/${MINICONDA_BASH_SCRIPT}
chmod 700 ${MINICONDA_BASH_SCRIPT}
unset PYTHONPATH
bash ${MINICONDA_BASH_SCRIPT} -b -f -p ${MINICONDA_ROOT}
rm ${MINICONDA_BASH_SCRIPT}
cd ${MINICONDA_ROOT}

PATH=${MINICONDA_ROOT}/bin:${PATH}
conda init --dry-run --verbose > activate.sh
conda_env_start=`grep -n "# >>> conda initialize >>>" activate.sh | cut -d':' -f 1`
conda_env_stop=`grep -n "# <<< conda initialize <<<" activate.sh | cut -d':' -f 1`

echo "sed -n '${conda_env_start},${conda_env_stop}p' activate.sh > activate2.sh" > sed.sh
echo "sed 's/^.//' activate2.sh > activate.sh" >> sed.sh
echo "rm activate2.sh" >> sed.sh
git submodule update --init --recursive --jobs 0. ./sed.sh
rm ./sed.sh

. ${MINICONDA_ROOT}/activate.sh

export PS1="(pytorch-build) [\u@\h \W]\$ "
```


Download PyTorch source code
----------------------------

```bash
PYTORCH_PACKAGE_LABEL=torch
PYTORCH_LABEL=py${PYTORCH_PACKAGE_LABEL}
PYTORCH_VERSION=1.13.0a0
PYTORCH_ARCHIVE=${PYTORCH_LABEL}-v${PYTORCH_VERSION}.tar.gz
PYTORCH_NAME=${PYTORCH_LABEL}-${PYTORCH_VERSION}
PYTORCH_BUILD_ROOT=${MINICONDA_ROOT}/repos/${PYTORCH_NAME}

mkdir -p ${MINICONDA_ROOT}/repos
cd ${MINICONDA_ROOT}/repos

git clone https://github.com/pytorch/pytorch ${PYTORCH_NAME}
cd ${PYTORCH_NAME}

# PyTorch source version 1.13.0a0 corresponds to PyTorch package version 1.13.1
git checkout v1.13.1

git submodule update --init --recursive --jobs 0
```


Install various packages in preparation for PyTorch build
---------------------------------------------------------

```bash
cd ${PYTORCH_BUILD_ROOT}

pip install -r requirements.txt

pip install ninja
```


Build PyTorch
-------------

Building PyTorch requires a significant amount of memory, more than would be available to a single user on a login node.
For this reason, the build is launched from a submission script running on a compute node, see below.

```bash
#!/bin/bash

#SBATCH --job-name=pt-build
#SBATCH --time=01:00:00
#SBATCH --account=<budget code>
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=standard
#SBATCH --qos=standard
#SBATCH --export=none

PRFX=/path/to/work
cd ${PRFX}

module -q load PrgEnv-gnu
module -q load cray-fftw
module -q load mkl/2023.0.0
module -q load cmake/3.21.3

PYTHON_LABEL=py39
MINICONDA_TAG=miniconda
MINICONDA_LABEL=${MINICONDA_TAG}3
MINICONDA_VERSION=24.1.2-0
MINICONDA_ROOT=${PRFX}/${MINICONDA_LABEL}/${MINICONDA_VERSION}-${PYTHON_LABEL}

PATH=${MINICONDA_ROOT}/bin:${PATH}

. ${MINICONDA_ROOT}/activate.sh

PYTORCH_PACKAGE_LABEL=torch
PYTORCH_LABEL=py${PYTORCH_PACKAGE_LABEL}
PYTORCH_VERSION=1.13.0a0
PYTORCH_ARCHIVE=${PYTORCH_LABEL}-v${PYTORCH_VERSION}.tar.gz
PYTORCH_NAME=${PYTORCH_LABEL}-${PYTORCH_VERSION}
PYTORCH_BUILD_ROOT=${MINICONDA_ROOT}/repos/${PYTORCH_NAME}

export CMAKE_PREFIX_PATH=${PYTHONUSERBASE}/lib/python${PYTHON_VER}/site-packages
export USE_DISTRIBUTED=1
export USE_CUDA=0
export USE_ROCM=0
export USE_MKL=1
export INTEL_MKL_DIR=${MKLROOT}
export MKL_THREADING=SEQ  # gnu progenv means threading must be sequential
export BUILD_CAFFE2=0

cd ${PYTORCH_BUILD_ROOT}

CC=cc CXX=CC FC=ftn python setup.py install

echo ""
echo "Source build done."
echo "Building distribution wheel..."
echo ""

python setup.py bdist_wheel
```

You'll need to set the budget code and the `PRFX` path before submitting the build job.

Once the build job finishes, you should find a Python wheel distribution in the following location,
`${PYTORCH_BUILD_ROOT}/dist/torch-1.13.0a0+git49444c3-cp39-cp39-linux_x86_64.whl`.

You can now use that wheel file to install PyTorch in your own Python environment. Further instructions
down below show how to do this, but first, we will deactivate the Miniconda build environment.

```bash
conda deactivate
export PS1="[\u@\h \W]\$ "
```


Setup install environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/python/core
cd ${PRFX}
 
PYTORCH_PACKAGE_LABEL=torch
PYTORCH_LABEL=py${PYTORCH_PACKAGE_LABEL}
PYTORCH_VERSION=1.13.0a0
PYTORCH_ROOT=${PRFX}/${PYTORCH_LABEL}/${PYTORCH_VERSION}

module load PrgEnv-gnu
module load cray-python
module load cray-fftw
module load mkl/2023.0.0
module load cmake/3.21.3

PYTHON_VER=`echo ${CRAY_PYTHON_LEVEL} | cut -d'.' -f1-2`
PYTHON_DIR=${PYTORCH_ROOT}/python
PYTHON_BIN=${PYTHON_DIR}/${CRAY_PYTHON_LEVEL}/bin
```


Create and setup the PyTorch install environment
------------------------------------------------

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
cd ${PYTORCH_ROOT}

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
pip install --user h5py
```


Install PyTorch from previously built wheel distribution
--------------------------------------------------------

```bash
cd ${PYTORCH_ROOT}

pip install --user ${PYTORCH_BUILD_ROOT}/dist/torch-1.13.0a0+git49444c3-cp39-cp39-linux_x86_64.whl 
```


Install the popular PyTorch datasets/models
-------------------------------------------

```bash
cd ${PYTORCH_ROOT}

pip install --user --no-deps torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cpu
pip install --user --no-deps torchvision==0.14.1 --extra-index-url https://download.pytorch.org/whl/cpu
pip install --user --no-deps torchtext==0.14.1 --extra-index-url https://download.pytorch.org/whl/cpu
pip install --user --no-deps torchmetrics==1.0.3 --extra-index-url https://download.pytorch.org/whl/cpu
```


Install tensorboard packages
----------------------------

```bash
cd ${PYTORCH_ROOT}

pip install --user tensorboard==2.11.2
pip install --user tensorboard_plugin_profile==2.11.2
pip install --user tensorboard-plugin-wit
pip install --user tensorboard-pytorch
```


Install latest mpi4py
---------------------

```bash
cd ${PYTORCH_ROOT}

MPICC=cc python -m pip install --no-binary=mpi4py --upgrade mpi4py
```


Install Horovod
---------------

When building horovod for PyTorch it is necessary to have `${CRAY_PYTHON_PREFIX}/lib/python${PYTHON_VER}/site-packages` in the `PYTHONPATH`
and to set `--no-build-isolation` in order for the `packaging` module to be found.

```bash
cd ${PYTORCH_ROOT}

export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHON_VER}/site-packages:${CRAY_PYTHON_PREFIX}/lib/python${PYTHON_VER}/site-packages:/work/y07/shared/utils/core/bolt/0.8/modules

CC=cc CXX=CC FC=ftn HOROVOD_CPU_OPERATIONS=MPI HOROVOD_WITH_MPI=1 HOROVOD_WITH_TENSORFLOW=0 HOROVOD_WITH_PYTORCH=1 HOROVOD_WITH_MXNET=0 pip install --user --no-cache-dir --no-build-isolation horovod[pytorch]==0.28.1
```

Now run `horovodrun --check-build` to confirm that Horovod has been installed correctly. That command should return something like the following output.

```bash
Horovod v0.28.1:

Available Frameworks:
    [ ] TensorFlow
    [X] PyTorch
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

The PyTorch Python environment described here is encapsulated as an Lmod module file on ARCHER2.
A user may build a local Python environment based on this module, `pytorch/1.13.0a0`, which
means that module must be loaded whenever the local environment is activated.

The `extend-venv-activate` script ensures that this happens: it modifies the local environment's
activate script such that the `pytorch/1.13.0a0` module is loaded during activation and unloaded
during deactivation.

The contents of the `extend-venv-activate` script are shown below. The file itself must be added
to the `${PYTHON_BIN}` directory.

```bash
#!/bin/bash
  
# add extra activate commands  
MARK="# you cannot run it directly"
CMDS="${MARK}\n\n"
CMDS="${CMDS}module -q load pytorch/1.13.0a0\n\n"
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
CMDS="${CMDS}${INDENT}module -q unload pytorch/1.13.0a0"

sed -ri "s:${MARK}:${CMDS}:g" ${1}/bin/activate
```

Lastly, remember to set read and execute permission for all users, i.e., `chmod a+rx ${PYTHON_BIN}/extend-venv-activate`.

See the link below for an example of how the `extend-venv-activate` script is called.

[https://docs.archer2.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip](https://docs.archer2.ac.uk/user-guide/python/#installing-your-own-python-packages-with-pip)
