# GPAW 21.1.0 ARCHER2 GCC


## Set up the environment

```
module restore PrgEnv-gnu
module load cray-python

```


## Download and install Libxc

```
wget -O libxc-5.1.5.tar.gz http://www.tddft.org/programs/libxc/down.php?file=5.1.5/libxc-5.1.5.tar.gz 
tar xvf Libxc-5.1.5.tar.gz 
cd libxc-5.1.5 

CC=cc CXX=CC FC=ftn ./configure --enable-shared --prefix=/work/group/group/username/path/to/libxc 
make 
make install 
```


## Download and install GPAW

```
git clone -b 21.1.0 https://gitlab.com/gpaw/gpaw.git 
cd gpaw
```

Create the following siteconfig.py file making sure to edit the path to libxc to where 
it was installed

```
# siteconfig.py 

parallel_python_interpreter = True 
compiler = 'cc' 
mpicompiler = 'cc' 
mpilinker = 'cc' 
scalapack = True 
libxc = '/work/group/group/username/path/to/libxc' 
include_dirs += [libxc + '/include'] 
library_dirs += [libxc + '/lib'] 
extra_link_args += ['-O2'] 
extra_compile_args += ['-O2'] 
if 'libxc' not in libraries: 
libraries.append('libxc') 
if 'blas' in libraries: 
libraries.remove('blas') 
if 'lapack' in libraries: 
libraries.remove('lapack') 

if scalapack: 
define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')] 
define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')] 
``` 

Run the following:

```
python setup.py build_ext 
python setup.py install --prefix=/work/group/group/username/path/to/gpaw 
```


## Set up the environment for running GPAW

Add the following to you job script to run GPAW, setting the GPAW_DIR
and LIBXC_DIR to your install location.

```
export GPAW_DIR=/path/to/gpaw/install
export LIBXC_DIR=/path/to/libxc/install

export PATH=$PATH:$GPAW_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$GPAW_DIR/lib
export PYTHONPATH=$PYTHONPATH:$GPAW_DIR/lib/python3.8/site-packages
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LIBXC_DIR/libxc/lib
```
