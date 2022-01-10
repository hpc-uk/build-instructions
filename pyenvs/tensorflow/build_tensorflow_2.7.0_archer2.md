Instructions for installing TensorFlow 2.7.0 on ARCHER2
=======================================================

These instructions show how to install TensorFlow 2.7.0 for use on ARCHER2 (HPE Cray EX, AMD Zen2 7742).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
TENSORFLOW_LABEL=tensorflow
TENSORFLOW_VERSION=2.7.0
TENSORFLOW_ROOT=${PRFX}/${TENSORFLOW_LABEL}

module load cray-python

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


Install the TensorFlow packages
-------------------------------

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
pip install --user ${TENSORFLOW_LABEL}==${TENSORFLOW_VERSION}
```