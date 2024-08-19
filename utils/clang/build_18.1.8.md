Instructions for compiling clang 18.1.8
==================================

These instructions are for compiling clang 18.1.8 on Cirrus.

**Note:** This Clang build from source takes quite a long time!

Setup the environment
-----------------------

```bash
module load gcc/10.2.0
module load cmake/3.25.2
VERSION=18.1.8
INSTALL_DIR=<you_path_were_to_install_clang>
```

Download
---------------------

```bash
git clone https://github.com/llvm/llvm-project.git
cd llvm-project
git checkout tags/llvmorg-$VERSION
cd ../
```

Configure
---------------------------------------

```bash
mkdir -p  build
cd build

export CPATH=/work/y07/shared/cirrus-software/gcc/10.2.0/include/c++/10.2.0:/work/y07/shared/cirrus-software/gcc/10.2.0/include/c++/10.2.0/x86_64-pc-linux-gnu:$CPATH
cmake ../llvm-project/llvm -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_ENABLE_RUNTIMES="openmp"  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR -DCLANG_CONFIG_FILE_SYSTEM_DIR=$INSTALL_DIR/etc
```

Build and Install
-----------------

```bash
make -j 8
make install
```

Configuration ( optional )
--------------------------------
Optionally, you can set a configuration file in the `$INSTALL_DIR/etc` directory named `clang++.cfg` and `clang.cfg` , respectively for the C++ and C compiler. The configuration file contains a list of default flags to be passed to the compiler.
We provide two configuration files:

- [clang-gcc10.cfg](clang-gcc10.cfg): configuration for this build with gcc 10
- [clang-gcc10-cuda12.4.cfg](clang-gcc10-cuda12.4.cfg) : as above, but also pointing at the cuda installation in nvhpc 24.5

To install these configurations use

```bash

cp <my_config.cfg> $INSTALL_DIR/etc/clang++.cfg
cp <my_config.cfg> $INSTALL_DIR/etc/clang.cfg

```