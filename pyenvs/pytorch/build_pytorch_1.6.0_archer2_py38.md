Instructions for installing Pyorch 1.6.0 on ARCHER2
===================================================

These instructions are for installing PyTorch 1.6.0 on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using Python 3.8.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
TORCH_LABEL=torch
TORCH_VERSION=1.6.0
TORCH_ROOT=${PRFX}/${TORCH_LABEL}

module load cray-python/3.8.5.0
module load craype-dl-plugin-py3/20.10.1

PYTHON_VERSION_MAJOR=`echo "${CRAY_PYTHON_VERSION}" | cut -d"." -f 1-2 | tr -d .`
TORCH_HOME=${TORCH_ROOT}/${TORCH_VERSION}-py${PYTHON_VERSION_MAJOR}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Create and setup the PyTorch virtual environment
------------------------------------------------

```bash
python -m venv --system-site-packages ${TORCH_HOME}
. ${TORCH_HOME}/bin/activate
pip install --upgrade pip
```


Install the PyTorch packages
----------------------------

```bash
pip install "${TORCH_LABEL}==${TORCH_VERSION}"
pip install torchvision
pip install matplotlib
```


Finish by deactivating the virtual environment
----------------------------------------------

```bash
deactivate
```