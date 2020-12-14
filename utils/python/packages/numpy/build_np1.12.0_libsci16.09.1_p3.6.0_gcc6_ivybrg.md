Numpy 1.12.0 with cray-libsci 16.09.1 for Python 3.6.0 using GCC 6.1.0
======================================================================

Download and Unpack
-------------------

```bash
unzip numpy-1.12.0.zip
cd numpy-1.12.0
```

Configure
---------

Setup your environment:

```bash
module swap PrgEnv-cray PrgEnv-gnu
module swap gcc gcc/6.1.0 
module swap cray-libsci cray-libsci/16.09.1
module load python-compute/3.6.0
module unload xalt
```

Edit `site.cfg` to contain the following as the only uncommented lines::

```
[DEFAULT]
library_dirs = /opt/cray/libsci/16.09.1/GNU/5.1/x86_64/lib/
include_dirs = /opt/cray/libsci/16.09.1/GNU/5.1/x86_64/include/
```

Set the following environment variables:

```bash
export LAPACK=/opt/cray/libsci/16.09.1/GNU/5.1/x86_64/lib/libsci_gnu.so
export BLAS=/opt/cray/libsci/16.09.1/GNU/5.1/x86_64/lib/libsci_gnu.so
```

Build and Install
-----------------

Build using correct Python

```bash
python3 setup.py build --fcompiler=gnu95
```
Set PYTHONPATH and install:

```bash
export PYTHONPATH=/work/y07/y07/cse/numpy/1.12.0-python3.6.0-libsci16.09.1/lib/python3.6/site-packages:$PYTHONPATH
python3 setup.py install --prefix=/work/y07/y07/cse/numpy/1.12.0-python3.6.0-libsci16.09.1
```

Test
----

Test with the following:

```python
import numpy as np
np.test()
```


