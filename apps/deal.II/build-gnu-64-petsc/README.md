# deal.II

Version 8.4.1, with Gnu compilers, 64 bit indices and the following
optional packages:
* HDF5
* LAPACK
* METIS
* MPI
* PETSc
* TBB

The short version:
1. If you need to, download the
 [source tarball](https://github.com/dealii/dealii/releases/download/v8.4.1/dealii-8.4.1.tar.gz)
 and unpack it - make sure `$src_dir` in env.sh matches.
1. If installing centrally, name your configuration by setting
   `$config_name`. This one is called `gnu-petsc-64`.
1. Make a build directory, making sure `$build_dir` in env.sh
   matches. I used `build-$config_name`
1. Copy these scripts into build
1. Run master.sh, which simply sources the other scripts in turn.
```
. env.sh
. modules.sh
. configure.sh
. build.sh
. package.sh
```

## env.sh
This sets up some varibles with paths and exports
`CRAYPE_LINK_TYPE=dynamic`.

## modules.sh
Loads required modules

## configure.sh
This sets all the various CMake variables needed. Note it uses a tmp
dir as bash doesn't have an associative array type (like e.g. python
dicts). Then is calls cmake - this is quite slow.

## build.sh
`make install`

## package.sh
This uses craypkg-gen to create the .pc file for deal_II and the basic
modulefile. The script then creates a .version file and adds a bunch
of extra stuff to set the modules up correctly. Finally, if run as the
cse user, will sudo install the modulefile.
