# PreCICE 

PreCICE is an open-source coupling library for partitioned multi-physics simulations. It couples existing programs/solvers capable of simulating a subpart of the complete physics involved in a simulation. 

These instructions cover installing the [preCICE OpenFOAM adapter](https://precice.org/adapter-openfoam-overview.html) and the [preCICE CalculiX adapter](https://precice.org/adapter-calculix-overview.html) on ARCHER2 (HPE Cray EX, AMD Zen2 7742). 


## Environment set-up 

```bash 
PRFX=/path/to/your/user/work
cd $PRFX

module load PrgEnv-gnu
module load eigen
module load libxml2
module load cmake
module load cray-fftw
```

## Load a compatible OpenFOAM

Supported versions are listed [here.](https://precice.org/adapter-openfoam-support.html#supported-openfoam-versions)

```bash 
module load openfoam/com/v2212
source ${FOAM_INSTALL_DIR}/etc/bashrc
```

## Install boost shared libraries 

```bash 
cd $PRFX

wget https://boostorg.jfrog.io/artifactory/main/release/1.82.0/source/boost_1_82_0.tar.bz2
tar -xvf boost_1_82_0.tar.bz2

cd boost_1_82_0/

./bootstrap.sh
./b2 install --prefix=$PRFX/boost
```

## Install preCICE 

```bash 
cd $PRFX
wget https://github.com/precice/precice/archive/v2.5.0.tar.gz
tar -xzvf v2.5.0.tar.gz

cd precice-2.5.0
mkdir build && cd build

export Eigen3_ROOT=/work/y07/shared/libs/core/eigen/3.4.0/
export Boost_ROOT=$PRFX/boost
export CXX=CC

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PRFX/precice-2.5.0 -DPRECICE_PETScMapping=OFF -DPRECICE_PythonActions=OFF -DMPI_CXX_COMPILER=CC -DLIBXML2_LIBRARY=/work/y07/shared/libs/core/libxml2/2.9.7/GNU/9.3/lib/libxml2.so -DLIBXML2_INCLUDE_DIR=/work/y07/shared/libs/core/libxml2/2.9.7/GNU/9.3/include/ ..

make -j 8
make install
```

## Install the preCICE adapter 

```bash 
cd $PRFX

wget https://github.com/precice/openfoam-adapter/archive/refs/tags/v1.2.2.tar.gz
tar -xvf v1.2.2.tar.gz

cd openfoam-adapter-1.2.2/
```

### Link to preCICE:
```bash 
export PATH=$PRFX/precice-2.5.0:$PATH
export LD_LIBRARY_PATH=$PRFX/precice-2.5.0/lib64:$PRFX/boost/lib:$LD_LIBRARY_PATH
export CPATH=$PRFX/precice/include:$CPATH
export PKG_CONFIG_PATH=$PRFX/precice-2.5.0/lib64/pkgconfig:$PKG_CONFIG_PATH
```

Edit line 20 in `./Allwmake` to set an install location. These instructions assume you have chosen `$PRFX/adapter-install`, remember to include the full path for PRFX. 

```bash 
./Allwmake 
```

## Install CalculiX dependancies: 

First ensure the environment is correctly linking preCICE and the adapter
```bash 
export PATH=$PRFX/precice-2.5.0/bin:$PATH:$PRFX/adapter-install
export LD_LIBRARY_PATH=$PRFX/precice-2.5.0/lib64:/work/y07/shared/libs/core/boost/1.72.0/GNU/9.3/lib/:$LD_LIBRARY_PATH:$PRFX/adapter-install
export CPATH=$PRFX/precice/include:$CPATH
export PKG_CONFIG_PATH=$PRFX/precice-2.5.0/lib64/pkgconfig:$PKG_CONFIG_PATH
```

### SPOOLES
```bash 
cd $PRFX

wget http://www.netlib.org/linalg/spooles/spooles.2.2.tgz
mkdir SPOOLES.2.2
tar zxvf spooles.2.2.tgz -C SPOOLES.2.2
cd SPOOLES.2.2
```

Edit `Make.inc` to set `CC=cc` and comment out line 106, 118 and 130. 

```bash 
make lib 
```

### ARPACK 
```bash 
cd $PRFX

wget https://web.archive.org/web/20220526222500fw_/https://www.caam.rice.edu/software/ARPACK/SRC/arpack96.tar.Z
wget https://web.archive.org/web/20220526222500fw_/https://www.caam.rice.edu/software/ARPACK/SRC/patch.tar.Z

tar xzfv arpack96.tar.Z
tar xzfv patch.tar.Z

cd ARPACK
```

Edit `ARmake.inc`
```bash 
Line 28, point to the ARPACK directory in your set-up (i.e. mine is /work/z19/z19/eleanorb/Q2095171/ARPACK)
Line 104 FC      = ftn
Line 105 FFLAGS  = -O --std=legacy
Line 115 MAKE    = make
```

Edit UTIL/second.f to comment out line 24

```bash 
make lib
make all
```

### yaml-cpp 
```bash 
cd $PRFX

wget https://github.com/jbeder/yaml-cpp/archive/yaml-cpp-0.6.2.zip
unzip yaml-cpp-0.6.2.zip && cd yaml-cpp-yaml-cpp-0.6.2

mkdir build && cd build
cmake -DBUILD_SHARED_LIBS=ON ..
make
```

```bash 
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PRFX/yaml-cpp-yaml-cpp-0.6.2
export PATH=$PATH:$PRFX/yaml-cpp-yaml-cpp-0.6.2

```

## Install CalculiX 

```bash 
cd $PRFX
wget http://www.dhondt.de/ccx_2.20.src.tar.bz2
tar xvjf ccx_2.20.src.tar.bz2

wget https://github.com/precice/calculix-adapter/archive/refs/heads/master.tar.gz
tar -xzf master.tar.gz
cd $PRFX/calculix-adapter-master

cp /work/z19/shared/eleanorb/Makefile .
```

Change the PRFX in line 6 of Makefile. 

Edit `calculix-adapter-master/ccx_2.20.c` and replace `spoolesMPI.h` with `../SPOOLES.2.2/MPI.h`. 

```bash 
make clean
make -DCALCULIX_MPI
```

## Example run script: 

```bash 
#!/bin/bash

#SBATCH --job-name=test_job
#SBATCH --nodes=2
#SBATCH --time=1:00:00
#SBATCH --hint=nomultithread
#SBATCH --distribution=block:block

# Replace [budget code] below with your project code (e.g. t01)
#SBATCH --account=[budget code]
#SBATCH --partition=standard
#SBATCH --qos=standard

module load PrgEnv-gnu

# Set the prefix
PRFX=/path/to/your/user/work

# OpenFOAM
module load openfoam/com/v2212
source ${FOAM_INSTALL_DIR}/etc/bashrc

# Paths to preCICE
export PATH=$PRFX/precice-2.5.0/bin:$PATH:$PRFX/adapter-install
export LD_LIBRARY_PATH=$PRFX/precice-2.5.0/lib64:/work/y07/shared/libs/core/boost/1.72.0/GNU/9.3/lib/:$LD_LIBRARY_PATH:$PRFX/adapter-install
export CPATH=$PRFX/precice/include:$CPATH
export PKG_CONFIG_PATH=$PRFX/precice-2.5.0/lib64/pkgconfig:$PKG_CONFIG_PATH

# Paths to CalculiX
export PATH=$PRFX/CalculiX/ccx_2.20/src/:$PATH
export PATH=$PRFX/calculix-adapter-master/bin:$PATH

# Paths to yaml + user boost 
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/work/z19/z19/eleanorb/queries/preCICE+Calculix/yaml-cpp-yaml-cpp-0.6.2/build/:$PRFX/boost/lib
export PATH=$PATH:/work/z19/z19/eleanorb/queries/preCICE+Calculix/yaml-cpp-yaml-cpp-0.6.2/build/:$PRFX/boost 

export OMP_NUM_THREADS=1

  cd $PRFX/test-1
  decomposePar -force
  srun --ntasks=248 --cpus-per-task=${OMP_NUM_THREADS} \
     --exact --mem=25000M pimpleFoam -parallel &

export OMP_NUM_THREADS=8
   cd $PRFX/test-2
   srun --ntasks=1 --cpus-per-task=${OMP_NUM_THREADS} \
     --exact --mem=25000M ccx_preCICE -i flap -precice-participant Solid &
      
# Wait for all subjobs to finish
wait
```


> Note: 
> On ARCHER2 the `precice-config.xml` file will need to use the following for multi-node execution: 
> `<m2n:sockets from="Fluid" to="Solid" network="hsn0" exchange-directory=".." /`
> 
> See preCICE documentation [here](https://precice.org/configuration-communication.html).