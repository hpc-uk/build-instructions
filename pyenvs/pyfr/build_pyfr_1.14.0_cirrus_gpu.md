Instructions for building PyFR 1.14.0 on Cirrus (GPU)
=====================================================

These instructions show how to build PyFR 1.14.0 for use on the Cirrus GPU nodes (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB),
see http://www.pyfr.org for further details. 

The venv is an extension of the Miniconda3 (Python 3.9.12) environment provided by the `python/3.9.12-gpu` module.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/mnt/lustre/indy2lfs/sw
cd ${PRFX}

PYFR_LABEL=pyfr
PYFR_VERSION=1.14.0
PYFR_ROOT=${PRFX}/${PYFR_LABEL}

module load python/3.9.12-gpu

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
pip install --user gimmik==2.3
pip install --user h5py

pip install --user pyfr==${PYFR_VERSION}
```