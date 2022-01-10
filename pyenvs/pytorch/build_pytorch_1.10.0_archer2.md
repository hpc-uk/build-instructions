Instructions for installing Pyorch 1.10.0 on ARCHER2
====================================================

These instructions show how to install PyTorch 1.10.0 for use on ARCHER2 (HPE Cray EX, AMD Zen2 7742).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
PYTORCH_PACKAGE_LABEL=torch
PYTORCH_LABEL=py${PYTORCH_PACKAGE_LABEL}
PYTORCH_VERSION=1.10.0
PYTORCH_ROOT=${PRFX}/${PYTORCH_LABEL}

module load cray-python

PYTHON_VER=`echo ${CRAY_PYTHON_LEVEL} | cut -d'.' -f1-2`
PYTHON_DIR=${PRFX}/${PYTORCH_LABEL}/${PYTORCH_VERSION}/python
PYTHON_BIN=${PYTHON_DIR}/${CRAY_PYTHON_LEVEL}/bin
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Create and setup the PyTorch virtual python environment
-------------------------------------------------------

```bash
mkdir -p ${PYTHON_BIN}

export PIP_CACHE_DIR=${PYTHON_DIR}/.cache/pip

export PYTHONUSERBASE=${PYTHON_DIR}/${CRAY_PYTHON_LEVEL}
export PATH=${PYTHONUSERBASE}/bin:${PATH}
export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHONVER}/site-packages:${PYTHONPATH}

pip install --user --upgrade pip
```


Install the PyTorch packages
----------------------------

```bash
pip install --user --upgrade dask
pip install --user memory_profiler
pip install --user matplotlib
pip install --user pyqt5
pip install --user numba
pip install --user graphviz
pip install --user nltk
pip install --user jupyter
pip install --user jupyterlab
pip install --user wandb
pip install --user gym
pip install --user pyspark
pip install --user scikit-learn
pip install --user scikit-image

pip install --user ${PYTORCH_PACKAGE_LABEL}==${PYTORCH_VERSION}
pip install --user torchvision
pip install --user pytorch-lightning
pip install --user pytorch-lightning-bolts
pip install --user pytorch-lightning-bolts["extra"]
pip install --user lightning-flash
pip install --user 'lightning-flash[all]'
```