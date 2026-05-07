# Building HOOMD-blue 2.9.6 for ARCHER2

These instructions describe how to build [HOOMD-blue](https://github.com/glotzerlab/hoomd-blue) 4.9.1 for use
on [ARCHER2](https://www.archer2.ac.uk).

## Create Python venv with correct version of pybind11

HOOMD-blue requires a newer version of pybind11 than is available in the default Python
environment on ARCHER2. Create a venv and install the required version (remember to replace
the dummy path in the example with the path of your work directory on ARCHER2):

```
module load cray-python
python -m venv --system-site-packages /work/t01/t01/auser/hoomd-blue
pip3 install pybind11==2.12
```

## Install HOOMD-blue dependencies using Spack

HOOMD-blue requires two dependencies that are not already available on ARCHER2: cereal and ninja.
We use Spack on ARCHER2 to install these (you may want to consider a
[Spack environment](https://docs.archer2.ac.uk/data-tools/spack/#creating-an-environment) to isolate
this install if you want to use Spack for other, unrealted builds):

```
module load other-software
module load spack

spack install cereal %gcc
...wait for build to finish...

spack install eigen %gcc
...wait for build to finish...

spack install ninja
...wait for build to finish...
```

Note the install locations that are reported by Spack as you will need these paths for the 
step of compiling HOOMD-blue.

## Clone HOOMD-blue 4.9.1 from Github

```
git clone --recursive --branch v4.9.1 https://github.com/hpc-uk/build-instructions.git
```

## Configure the HOOMD-blue build

Configure the build using the paths from pip3 pybind11 install and the Spack cereal install
(remember to replace the dummy path in the example with the path of your work directory on ARCHER2):

```
module restore
module load PrgEnv-gnu
module load cray-fftw
module load cray-python

# Path to custom pybind11 installation
export CMAKE_PREFIX_PATH=/work/t01/t01/auser/venvs/hoomd-blue/lib/python3.10/site-packages:$CMAKE_PREFIX_PATH

# Paths to dependencies installed by Spack
export CMAKE_PREFIX_PATH=/work/t01/t01/auser/.spack-1.0.2/opt/spack/linux-sles15-zen2/gcc-11.2.0/cereal-1.3.2-iljatwyqc3vvmuphiabdcvwe2psfluns:$CMAKE_PREFIX_PATH
export CMAKE_PREFIX_PATH=/work/t01/t01/auser/.spack-1.0.2/opt/spack/linux-sles15-zen2/gcc-11.2.0/eigen-3.4.0-hi7jtnmsbz3ktsci45mocaktujlnmjfp:$CMAKE_PREFIX_PATH



# Configure the HOOMD-blue build
cmake -DENABLE_MPI=on -B build -S . -GNinja

```

## Build and test HOOMD-blue build

Activate the Python venv, make Spack ninja install available in the path and build HOOMD-blue:

```
source $WORK/venvs/hoomd-blue/bin/activate

export PATH=/work/t01/t01/auser/.spack-1.0.2/opt/spack/linux-sles15-zen2/gcc-11.2.0/ninja-1.12.1-pwtxljk5jfvp44zpuozgka6mwzp4pxoa/bin:$PATH

cd build

ninja -j8

python3 -m pytest hoomd
```


