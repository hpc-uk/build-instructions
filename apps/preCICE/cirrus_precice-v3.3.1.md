# PreCICE 

Instructions for installing the following software on [Cirrus](https://docs.cirrus.ac.uk/), HPE Cray EX4000 CPU-based system: 
* preCICE v3.3.1 
* OpenFOAM v2412 
* OpenFOAM adapter for preCICE v1.3.1 
* CalculiX v2.20 
* CalculiX adapter for preCICE v2.20.1 

## Environment set-up

```bash 
PRFX=/path/to/your/user/work
cd $PRFX
mkdir preCICE 
cd preCICE 

module load PrgEnv-gnu
module load eigen
module load cmake
module load cray-fftw
module load petsc
module load cray-python
```

## Install libxml2 

```bash 
wget https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.2.tar.xz
tar xf libxml2-2.15.2.tar.xz
cd libxml2-2.15.2
CC=cc ./configure --prefix=$PRFX/preCICE/libxml2 
make
make install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PRFX/preCICE/libxml2/lib
```

## Load a compatible OpenFOAM
Supported versions are listed [here.](https://precice.org/adapter-openfoam-support.html#supported-openfoam-versions)

```bash 
module load openfoam/2412
```

## Install boost shared libraries 
```bash 
cd $PRFX

wget https://archives.boost.io/release/1.82.0/source/boost_1_82_0.tar.gz
tar -xvf boost_1_82_0.tar.gz

cd boost_1_82_0/

./bootstrap.sh
./b2 install --prefix=$PRFX/preCICE/boost
```

## Install preCICE 
```bash 
cd $PRFX
wget https://github.com/precice/precice/archive/v3.3.1.tar.gz
tar -xzvf v3.3.1.tar.gz

cd precice-3.3.1
mkdir build && cd build

export Eigen3_ROOT=/mnt/lustre/e1000/home/y07/shared/cirrus-ex/cirrus-ex-software/spack-cirrus-ex/0.2/cirrus-ex-cse/opt/linux-rhel9-zen5/gcc-14.2/eigen-3.4.0-ehsfahdxqxo6usubv5d6prtodlgb3zj3/include/eigen3
export Boost_ROOT=$PRFX/preCICE/boost
export CXX=CC

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PRFX/preCICE/precice-3.3.1 -DPRECICE_PETScMapping=OFF -DPRECICE_PythonActions=OFF -DMPI_CXX_COMPILER=CC -DLIBXML2_LIBRARY=$PRFX/preCICE/libxml2/lib/libxml2.so -DLIBXML2_INCLUDE_DIR=$PRFX/preCICE/libxml2/include/libxml2 ..

make -j 8
make install
```

## Install the preCICE adapter 
```bash 
cd $PRFX/preCICE

wget https://github.com/precice/openfoam-adapter/archive/refs/tags/v1.3.1.tar.gz
tar -xvf v1.3.1.tar.gz

cd openfoam-adapter-1.3.1/
```

### Link to preCICE:
```bash 
export PATH=$PRFX/preCICE/precice-3.3.1:$PATH
export LD_LIBRARY_PATH=$PRFX/preCICE/precice-3.3.1/lib64:$PRFX/preCICE/boost/lib:$LD_LIBRARY_PATH
export CPATH=$PRFX/preCICE/precice-3.3.1/include:$CPATH
export PKG_CONFIG_PATH=$PRFX/preCICE/precice-3.3.1/lib64/pkgconfig:$PKG_CONFIG_PATH
```

Edit line 20 in `./Allwmake` to set an install location. These instructions assume you have chosen `$PRFX/preCICE/adapter-install`, remember to include the full path for PRFX. 

```bash 
./Allwmake 
```

## Install CalculiX dependancies: 
First ensure the environment is correctly linking preCICE and the adapter
```bash 
export PATH=$PRFX/preCICE/precice-3.3.1/bin:$PATH:$PRFX/preCICE/adapter-install
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PRFX/preCICE/adapter-install
```

### SPOOLES
```bash 
cd $PRFX/preCICE

wget http://www.netlib.org/linalg/spooles/spooles.2.2.tgz
mkdir SPOOLES.2.2
tar zxvf spooles.2.2.tgz -C SPOOLES.2.2
cd SPOOLES.2.2
```

Edit `Make.inc` to set `CC=cc -Wno-int-conversion ` (line 15) and comment out line 106, 118, 130 and 145. 

```bash 
make lib 
```

### ARPACK 
```bash 
cd $PRFX/preCICE

wget https://web.archive.org/web/20220526222500fw_/https://www.caam.rice.edu/software/ARPACK/SRC/arpack96.tar.Z
wget https://web.archive.org/web/20220526222500fw_/https://www.caam.rice.edu/software/ARPACK/SRC/patch.tar.Z

tar xzfv arpack96.tar.Z
tar xzfv patch.tar.Z

cd ARPACK
```

Edit `ARmake.inc`
```bash 
Line 28, point to the ARPACK directory in your set-up (These instructions assume you have chosen `$PRFX/preCICE/ARPACK`, remember to include the full path for PRFX.)
Line 104 FC      = ftn
Line 105 FFLAGS  = -O --std=legacy
Line 115 MAKE    = make
```

Edit UTIL/second.f to comment out line 24

```bash 
make lib
make all
```

### yaml-cpp 
```bash 
cd $PRFX/preCICE

wget https://github.com/jbeder/yaml-cpp/archive/yaml-cpp-0.6.2.zip
unzip yaml-cpp-0.6.2.zip && cd yaml-cpp-yaml-cpp-0.6.2

mkdir build && cd build

sed -i 's/CMP0012 OLD/CMP0012 NEW/' ../CMakeLists.txt
sed -i 's/CMP0015 OLD/CMP0015 NEW/' ../CMakeLists.txt

cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ..
make
```

```bash 
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PRFX/preCICE/yaml-cpp-yaml-cpp-0.6.2
export PATH=$PATH:$PRFX/preCICE/yaml-cpp-yaml-cpp-0.6.2
```


## Install CalculiX 
```bash 
cd $PRFX/preCICE
wget http://www.dhondt.de/ccx_2.20.src.tar.bz2
tar xvjf ccx_2.20.src.tar.bz2

wget https://github.com/precice/calculix-adapter/archive/refs/heads/master.tar.gz
tar -xzf master.tar.gz
cd $PRFX/preCICE/calculix-adapter-master
```

Copy the Makefile from `/work/z19/shared/preCICE/Makefile` and change the $PRFX in line 6 of Makefile to match your own set-up. 

```bash 
make clean 
make 
```


## Example run script: 
```bash 
#!/bin/bash

#SBATCH --job-name=test_job
#SBATCH --nodes=2
#SBATCH --exclusive
#SBATCH --time=1:00:00
#SBATCH --hint=nomultithread
#SBATCH --distribution=block:block

# Replace [budget code] below with your project code (e.g. t01)
#SBATCH --account=z19
#SBATCH --partition=standard
#SBATCH --qos=standard

# Set the prefix
PRFX=/work/z19/z19/eleanorb/queries/

# OpenFOAM
module load PrgEnv-gnu
module load openfoam/2412
source ${FOAM_INSTALL_DIR}/etc/bashrc

# Paths to preCICE
export PATH=$PRFX/preCICE/precice-3.3.1:$PATH
export LD_LIBRARY_PATH=$PRFX/preCICE/precice-3.3.1/lib64:$PRFX/preCICE/boost/lib:$LD_LIBRARY_PATH
export CPATH=$PRFX/preCICE/precice-3.3.1/include:$CPATH
export PKG_CONFIG_PATH=$PRFX/preCICE/precice-3.3.1/lib64/pkgconfig:$PKG_CONFIG_PATH

export PATH=$PRFX/preCICE/precice-3.3.1/bin:$PATH:$PRFX/preCICE/adapter-install
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PRFX/preCICE/adapter-install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PRFX/preCICE/yaml-cpp-yaml-cpp-0.6.2
export PATH=$PATH:$PRFX/preCICE/yaml-cpp-yaml-cpp-0.6.2

# Paths to CalculiX
export PATH=$PRFX/preCICE/CalculiX/ccx_2.20/src/:$PATH
export PATH=$PRFX/preCICE/calculix-adapter-master/bin:$PATH

export OMP_NUM_THREADS=1

which pimpleFoam
which ccx_preCICE
```
