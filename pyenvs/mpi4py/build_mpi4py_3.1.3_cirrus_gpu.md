Instructions for building a Miniconda3 environment that provides mpi4py suitable for Cirrus GPU nodes
=====================================================================================================

These instructions show how to build Miniconda3-based mpi4py environment for the Cirrus GPU nodes
(Cascade Lake, NVIDIA Tesla V100-SXM2-16GB), one that supports parallel computation.

The environment features mpi4py 3.1.3 (OpenMPI 4.1.0 with ucx 1.9.0 and CUDA 11.2) with pycuda 2021.1 and cupy 10.1.0.
It also provides a suite of packages pertinent to parallel processing and numerical analysis,
e.g., dask, ipyparallel, jupyter, matplotlib, numpy, pandas and scipy.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/lustre/sw
cd ${PRFX}

CUDA_VERSION=11.2
OPENMPI_VERSION=4.1.0
BOOST_VERSION=1.73.0

module load nvidia/cuda-${CUDA_VERSION}
module load nvidia/mathlibs-${CUDA_VERSION}
module load openmpi/${OPENMPI_VERSION}-cuda-${CUDA_VERSION}
module load boost/${BOOST_VERSION}

MPI4PY_LABEL=mpi4py
MPI4PY_VERSION=3.1.3

PYTHON_LABEL=py38
MINICONDA_TAG=miniconda
MINICONDA_LABEL=${MINICONDA_TAG}3
MINICONDA_VERSION=4.9.2
MINICONDA_ROOT=${PRFX}/${MINICONDA_LABEL}/${MPI4PY_LABEL}/${MPI4PY_VERSION}-gpu
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Create and setup a Miniconda3 virtual environment
-------------------------------------------------

```bash
cd ${PRFX}

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
. ./sed.sh
rm ./sed.sh

. ${MINICONDA_ROOT}/activate.sh

conda update -y -n root --all

export PS1="(mpi4py-gpu) [\u@\h \W]\$ "
```


Build and install mpi4py using OpenMPI 4.1.0
--------------------------------------------

```bash
cd ${MINICONDA_ROOT}

PYTHON_LABEL_LONG=python${PYTHON_LABEL:2:1}.${PYTHON_LABEL:3:1}
MPI4PY_NAME=${MPI4PY_LABEL}-${MPI4PY_VERSION}
MPI4PY_ROOT=${MINICONDA_ROOT}/${MPI4PY_LABEL}/${MPI4PY_VERSION}-ompi-${OPENMPI_VERSION}

mkdir -p ${MPI4PY_LABEL}
cd ${MPI4PY_LABEL}

wget https://github.com/${MPI4PY_LABEL}/${MPI4PY_LABEL}/archive/${MPI4PY_VERSION}.tar.gz
tar -xvzf ${MPI4PY_VERSION}.tar.gz
rm ${MPI4PY_VERSION}.tar.gz

cd ${MPI4PY_NAME}

python setup.py build
python setup.py install --prefix=${MPI4PY_ROOT}
python setup.py clean --all
```


Checking the mpi4py package
---------------------------

To show the MPI library supporting mpi4py, first set the environment like so.

```bash
export LD_LIBRARY_PATH=${MINICONDA_ROOT}/mpi4py/3.1.3-ompi-4.1.0/lib:${LD_LIBRARY_PATH}
export PYTHONPATH=${MINICONDA_ROOT}/mpi4py/3.1.3-ompi-4.1.0/lib/python3.8/site-packages:${PYTHONPATH}
```

Then start a python session and run the following commands.

```python
import mpi4py.rc
mpi4py.rc.initialize = False
from mpi4py import MPI
MPI.Get_library_version()
```


Build and install pycuda
------------------------

```bash
cd ${MINICONDA_ROOT}

PYCUDA_LABEL=pycuda
PYCUDA_VERSION=2021.1
PYCUDA_NAME=${PYCUDA_LABEL}-${PYCUDA_VERSION}

mkdir -p ${PYCUDA_LABEL}
cd ${PYCUDA_LABEL}

wget https://files.pythonhosted.org/packages/5a/56/4682a5118a234d15aa1c8768a528aac4858c7b04d2674e18d586d3dfda04/${PYCUDA_NAME}.tar.gz
tar -xvzf ${PYCUDA_NAME}.tar.gz
rm ${PYCUDA_NAME}.tar.gz

cd ${PYCUDA_NAME}

python configure.py --cuda-root=${CUDAROOT} --no-use-shipped-boost --boost-python-libname=boost_python-py36 --ldflags="-L${CUDAROOT}/targets/x86_64-linux/lib/stubs"
make
make install
make clean
```

Note that the python configure command for pycuda has one anomalous setting, the `py36` suffix used for the boost python library name.
This is not a mistake; it is merely a workaround required to get pycuda to build.


Install general purpose python packages
---------------------------------------

```bash
cd ${MINICONDA_ROOT}

pip install scipy
pip install cupy-cuda112
pip install pandas
pip install dask
pip install memory_profiler
pip install matplotlib
pip install pyqt5
pip install numba
pip install graphviz
pip install nltk
pip install ipyparallel
pip install jupyter
pip install jupyterlab
pip install jupyterlab-server==2.10.3
pip install notebook
pip install sympy
pip install wandb
pip install gym
```


Finish by deactivating the virtual environment
----------------------------------------------

```bash
conda deactivate
export PS1="[\u@\h \W]\$ "
```
