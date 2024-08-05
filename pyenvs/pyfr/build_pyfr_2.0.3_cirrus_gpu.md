Instructions for building PyFR 2.0.3 on Cirrus (GPU)
====================================================

These instructions show how to build PyFR 2.0.3 for use on the Cirrus GPU nodes (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB),
see http://www.pyfr.org for further details. 

The venv is an extension of the Miniconda3 (Python 3.12.1) environment provided by the `python/3.12.1-gpu` module.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software
cd ${PRFX}

PYFR_LABEL=pyfr
PYFR_VERSION=2.0.3
PYFR_ROOT=${PRFX}/${PYFR_LABEL}

module load metis/5.1.0
module load python/3.12.1-gpu

PYTHON_VER=`echo ${MINICONDA3_PYTHON_VERSION} | cut -d'.' -f1-2`
PYTHON_DIR=${PRFX}/${PYFR_LABEL}/${PYFR_VERSION}-gpu/python
PYTHON_BIN=${PYTHON_DIR}/${MINICONDA3_PYTHON_VERSION}/bin


mkdir -p ${PYTHON_BIN}

export PIP_CACHE_DIR=${PYTHON_DIR}/.cache/pip

export PYTHONUSERBASE=${PYTHON_DIR}/${MINICONDA3_PYTHON_VERSION}
export PATH=${PYTHONUSERBASE}/bin:${PATH}
export PYTHONPATH=${PYTHONUSERBASE}/lib/python${PYTHON_VER}/site-packages:${PYTHONPATH}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Install PyFR and supporting packages
------------------------------------

```bash
pip install --user gimmik==3.2.1
pip install --user h5py
pip install --user metis

pip install --user pyfr==${PYFR_VERSION}
```
