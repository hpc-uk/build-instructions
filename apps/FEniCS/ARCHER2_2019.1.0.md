Instructions for compiling FEniCS 2019.1.0 for ARCHER2
======================================================

These instructions are for compiling FEniCS 2019.1.0 on 
[ARCHER2](https://www.archer2.ac.uk).


Load modules and set python paths/build paths
---------------------------------------------

```bash
  module load cray-python/
  module load cmake

  export PYTHONUSERBASE=/work/<project>/<project>/<username>/.local
  export PATH=$PYTHONUSERBASE/bin:$PATH

  BUILD_DIR=/path/to/your/build/directory
  cd $BUILD_DIR
```

Download, configure, and build pybind
-------------------------------------

```bash
  cd $BUILD_DIR
  export PYBIND11_VERSION=2.6.1
  wget -nc --quiet https://github.com/pybind/pybind11/archive/v${PYBIND11_VERSION}.tar.gz
  tar -xf v${PYBIND11_VERSION}.tar.gz
  mkdir pybind11-${PYBIND11_VERSION}/build
  cd pybind11-${PYBIND11_VERSION}/build
  cmake -DPYBIND11_TEST=off .. -DCMAKE_INSTALL_PREFIX=$(pwd) -DPYTHON_EXECUTABLE:FILEPATH=/opt/cray/pe/python/3.8.5.0/bin/python3
  make install
```

Download, configure, and install BOOST
--------------------------------------

While BOOST is available centrally on ARCHER2, the shared libraries are not 
(and that's what we need for FEniCS/DOLFIN). For this, we'll use the build 
script provided by the ARCHER2 CSE team.

```bash
  cd $BUILD_DIR
  git clone https://github.com/ARCHER2-HPC/pe-scripts.git
  mv pe-script boost
  cd  boost
  git checkout cse-develop
  sed -i 's/make_shared=0/make_shared=1/g' sh/.preamble.sh
  ./sh/boost.sh --prefix=$(pwd)/boost
```

Download, configure, and install EIGEN
--------------------------------------

```bash
  cd $BUILD_DIR
  wget https://gitlab.com/libeigen/eigen/-/archive/3.3.9/eigen-3.3.9.tar.gz
  tar -xvf eigen-3.3.9.tar.gz
  mkdir eigen-3.3.9/build; cd eigen-3.3.9/build
  cmake ../ -DCMAKE_INSTALL_PREFIX=build -DPYTHON_EXECUTABLE:FILEPATH=/opt/cray/pe/python/3.8.5.0/bin/python3
  make -j 8 install
```

Download, configure, and install FEniCS python components
---------------------------------------------------------

```bash
  cd $BUILD_DIR
  wget https://bitbucket.org/fenics-project/ffc/downloads/ffc-2019.1.0.post0.tar.gz
  tar -xvf ffc-2019.1.0.post0.tar.gz
  cd ffc-2019.1.0.post0/
  pip install --user .
```

Download, configure, and install DOLFIN
---------------------------------------

Download DOLFIN, and make sure that all dependencies are correct:

```bash
  cd $BUILD_DIR
  export FENICS_VERSION=2019.1.0.post0
  git clone --branch=$FENICS_VERSION https://bitbucket.org/fenics-project/dolfin
  mkdir dolfin/build; cd dolfin/build
  export BOOST_ROOT=$BUILD_DIR/boost
  export EIGEN3_INCLUDE_DIR=$BUILD_DIR/eigen-3.3.9/build/build/include/eigen3
  export PYTHONPATH=$PYTHONPATH:/opt/cray/pe/python/3.8.5.0:$PYTHONUSERBASE/lib/python3.8/site-packages/:/opt/cray/pe/python/3.8.5.0/lib/python3.8/site-packages/
```

At this point, we need to edit `$BUILD_DIR/dolfin/CMakeLists.txt`. We need to 
add the following text to the top of that file:

```bash
  SET( EIGEN3_INCLUDE_DIR "$ENV{EIGEN3_INCLUDE_DIR}" )
  IF( NOT EIGEN3_INCLUDE_DIR )
      MESSAGE( FATAL_ERROR "Please point the environment variable EIGEN3_INCLUDE_DIR to the include directory of your Eigen3 installation.")
  ENDIF()
  INCLUDE_DIRECTORIES ( "${EIGEN3_INCLUDE_DIR}" )

```

Run CMake:

```bash
  cmake ../ -DCMAKE_INSTALL_PREFIX=$(pwd) -DPYTHON_EXECUTABLE:FILEPATH=/opt/cray/pe/python/3.8.5.0/bin/python3
  make -j 8 install
  source $BUILD_DIR/dolfin/build/share/dolfin/dolfin.conf
```

Build python build

```
  cd ../python
  export pybind11_DIR=$BUILD_DIR/pybind11-2.6.1/build//share/cmake/pybind11/
  export DOLFIN_DIR=$BUILD_DIR/dolfin/build/share/dolfin/cmake
  pip -v install --user .
```

> ## Note for running
> 
> When wanting to use FEniCS and DOLFIN, you will need to run:
>  `source $BUILD_DIR/dolfin/build/share/dolfin/dolfin.conf`
>
{. :note}
