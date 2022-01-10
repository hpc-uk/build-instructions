Instructions for building a Miniconda3 environment that provides mpi4py suitable for Cirrus CPU nodes
=====================================================================================================

These instructions show how to build Miniconda3-based mpi4py environment for the Cirrus CPU nodes
(Intel Xeon E5-2695, Broadwell), one that supports parallel computation.

The build instructions cover the installation of two flavours of mpi4py 3.1.3, one linked with OpenMPI 4.1.0
and the other linked with HPE MPT 2.22.

The Miniconda3 environment also provides a suite of packages pertinent to parallel processing and numerical analysis,
e.g., dask, ipyparallel, jupyter, matplotlib, numpy, pandas and scipy.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/lustre/sw
cd ${PRFX}

OPENMPI_VERSION=4.1.0
MPT_VERSION=2.22

MPI4PY_LABEL=mpi4py
MPI4PY_VERSION=3.1.3

PYTHON_LABEL=py38
MINICONDA_TAG=miniconda
MINICONDA_LABEL=${MINICONDA_TAG}3
MINICONDA_VERSION=4.9.2
MINICONDA_ROOT=${PRFX}/${MINICONDA_LABEL}/${MPI4PY_LABEL}/${MPI4PY_VERSION}
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

export PS1="(mpi4py) [\u@\h \W]\$ "
```


Build and install mpi4py using OpenMPI 4.1.0 and HPE MPT 2.22
-------------------------------------------------------------

```bash
cd ${MINICONDA_ROOT}

PYTHON_LABEL_LONG=python${PYTHON_LABEL:2:1}.${PYTHON_LABEL:3:1}
MPI4PY_NAME=${MPI4PY_LABEL}-${MPI4PY_VERSION}

mkdir -p ${MPI4PY_LABEL}
cd ${MPI4PY_LABEL}

wget https://github.com/${MPI4PY_LABEL}/${MPI4PY_LABEL}/archive/${MPI4PY_VERSION}.tar.gz
tar -xvzf ${MPI4PY_VERSION}.tar.gz
rm ${MPI4PY_VERSION}.tar.gz

cd ${MPI4PY_NAME}


module load openmpi/${OPENMPI_VERSION}

MPI4PY_ROOT=${MINICONDA_ROOT}/${MPI4PY_LABEL}/${MPI4PY_VERSION}-ompi-${OPENMPI_VERSION}

python setup.py build
python setup.py install --prefix=${MPI4PY_ROOT}
python setup.py clean --all

module unload openmpi/${OPENMPI_VERSION}


module load mpt/${MPT_VERSION}

MPI4PY_ROOT=${MINICONDA_ROOT}/${MPI4PY_LABEL}/${MPI4PY_VERSION}-mpt-${MPT_VERSION}

python setup.py build
python setup.py install --prefix=${MPI4PY_ROOT}
python setup.py clean --all

module unload mpt/${MPT_VERSION}
```


Checking the mpi4py package
---------------------------

Which MPI library is supporting mpi4py will depend on how you set up the runtime environment, specifically,
the `LD_LIBRARY_PATH` and `PYTHONPATH` environment variables.

For example, if you wish to use the HPE MPT library, simply add `3.1.3-mpt-2.22` to the appropriate paths.

```bash
export LD_LIBRARY_PATH=${MINICONDA_ROOT}/mpi4py/3.1.3-mpt-2.22/lib:${LD_LIBRARY_PATH}
export PYTHONPATH=${MINICONDA_ROOT}/mpi4py/3.1.3-mpt-2.22/lib/python3.8/site-packages:${PYTHONPATH}
```

And for OpenMPI you will need to use `3.1.3-ompi-4.1.0` instead.

To check that the intended MPI library is supporting mpi4py, start a python session and run the following commands.

```python
import mpi4py.rc
mpi4py.rc.initialize = False
from mpi4py import MPI
MPI.Get_library_version()
```


Install general purpose python packages
---------------------------------------

```bash
cd ${MINICONDA_ROOT}

pip install scipy
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