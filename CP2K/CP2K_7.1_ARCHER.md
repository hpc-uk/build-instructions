# Introduction

This document provides instructions on how to build CP2K 7.1 and its
dependencies on ARCHER.

Further information on CP2K can be found at
[the CP2Kwebsite](https://www.cp2k.org) and on the ARCHER
[CP2K documentation page](http://www.archer.ac.uk/documentation/software/cp2k/).

The official build instructions for CP2K are at
https://www.cp2k.org/howto:compile which recommends that the easiest
way to install prerequisites is via te toolchain script.

For historical reasons, the ARCHER build instructions will use the "manual"
route which builds each relevant prerequisite independently.

FURTHER DETAILS ON THE TOOLCHAIN ROUTE PENDING

## General

* We will use the GNU programming environment
* We will target the sopt, psmp, and popt builds for CP2K and so
  it is useful to build some of the prerequisites both with an without
  OpenMP.
* Note that if the autotuned version of libgrid is required, this can
  take some time to runm so you might want to do this first. See the
  LIBGRID SECTION.



## Dependencies

Following https://www.cp2k.org/howto:compile we have the following
depencencies


Dependency | Name         | Optional | Build?    | Comment
---------- | ----         | -------- | ------    | -------
2a.        | Gnu make     | No       | Available |
2b.        | Python       | No       | Available | `module load anaconda/python2`
2c.        | Fortran/C    | No       | Available | Use wrapper ftn, cc, CC
2d.        | BLAS/LAPACK  | No       | Available | via 
2e.        | MPI?SCLAPACK | Yes      | Available | via compiler wrappers
2f.        | FFTW         | Yes      | Avaialble | `module load fftw/3.3.6.1`
2g.        | libint       | Yes      | Build     | 
2h.        | libsmm       | Yes      | No        |
2i.        | libxsmm      | Yes      | Build     |
2j.        | CUDA         | Yes      | --        | Not relevant
2k.        | libxc        | Yes      | Build     |
2l.        | ELPA         | Yes      | Build     |
2m.        | PEXSI        | Yes      | No        |
2n.        | QUIP         | Yes      | No        |
2o.        | PLUMED       | Yes      | Build     |
2p.        | spglib       | Yes      | No        |
2q.        | SIRIUS       | Yes      | No        |
2r.        | FPGA         | Yes      | No        | Not relevant


# Downloading CP2K and basic setup
## Setup
First of all, we need to switch to the GNU compiler suite:

```
$ module swap PrgEnv-cray PrgEnv-gnu
```

At this point, it is also a good idea to load the fftw module:

```
$ module add cray-fftw
```

Finally we can set environment variables to tell `make` to use the compiler wrappers:

```
$ export FC=ftn CC=cc CXX=CC
```

## Download CP2K
We must choose a directory to build CP2K in. Typically this would be in `/work`. Say we have chosen to build it in `/work/[project]/[project]/[username]/CP2K`. We `cd` to this directory, then download CP2K 6.1 using

```
$ svn checkout http://svn.code.sf.net/p/cp2k/code/branches/cp2k-6_1-branch cp2k
```

We will now go on to download and build all of the third party libraries we will link to CP2K.

# Building third-party libraries
In the CP2K build directory, create a `libs` directory:

```
$ mkdir /work/[project]/[project]/[username]/CP2K/libs
```

that we will install the libraries into. We can now proceed to build the libraries:

## ELPA
Download ELPA, extract the tarball and `cd` into the ELPA directory:

```
$ wget https://elpa.mpcdf.mpg.de/html/Releases/2015.05.001/elpa-2015.05.001.tar.gz
$ tar -xzf elpa-2015.05.001.tar.gz
$ cd elpa-2015.05.001
```

Now run
```
$ ./configure --prefix=/work/[project]/[project]/[username]/CP2K/libs/elpa --enable-openmp --enable-shared=no
$ make
$ make install
$ export CRAYPE_LINK_TYPE=static
```

Note: if you encounter linking problems then use `export CRAYPE_LINK_TYPE=dynamic` and reissue the `make`
command (**without** `make clean`) remembering to issue the `export CRAYPE_LINK_TYPE=static` at the end of the build.

## libint
Download libint, extract the tarball and `cd` into the libint directory:
```
$ wget https://downloads.sourceforge.net/project/libint/v1-releases/libint-1.1.4.tar.gz
$ tar -xzf libint-1.1.4.tar.gz
$ cd libint-1.1.4
```
Now create a directory where the object files will be put, and build libint
```
$ mkdir obj
$ cd obj
$ ../configure --prefix=/work/[project]/[project]/[username]/CP2K/libs/libint
$ make
$ make install
```

## libxc
```
$ wget http://www.tddft.org/programs/octopus/down.php?file=libxc/4.2.3/libxc-4.2.3.tar.gz
$ tar -xzf libxc-4.2.3.tar.gz
$ cd libxc-4.2.3
$ ./configure --prefix=/work/[project]/[project]/[username]/CP2K/build/libs/libxc
$ make
$ make install
```

## libxsmm
```
$ git clone https://github.com/hfp/libxsmm.git
$ cd libxsmm
$ make INTRINSICS=1 PREFIX=/work/[project]/[project]/[username]/CP2K/build/libs/libxsmm install
```

## libgrid
This is not actually a third party library, but rather a component of CP2K itself. This step runs some autotuning to determine the optimum compile parameters for this component, and produces a static library `libgrid.a` containing the optimised routines.

To do this, we first compile the various different versions of test code, then run a job on ARCHER to determine the runtimes for each. Finally we build the library.

First `cd` into the `autotune_grid` directory in the CP2K source directory:
```
$ cd  /work/[project]/[project]/[username]/CP2K/cp2k/cp2k/tools/autotune_grid
```

Next we want to extract the data files
```
$ tar -xzf data.tgz
```

We now edit `generate_makefile.sh`, changing the parts that say `./out_${l}_${iopt}/test.x` to `aprun -n 1 ./out_${l}_${iopt}/test.x` so that the script knows to use `aprun` to launch executables.

Now we build the executables
```
$ make all_gen
```

We now need to submit a job to benchmark the executables. To do this we use the following batch script, `submit_libgrid.pbs`:

```
#!/bin/bash --login

#PBS -N libgrid
#PBS -l select=1
#PBS -l walltime=24:00:00
#PBS -A z19-cse

export PBS_O_WORKDIR=$(readlink -f $PBS_O_WORKDIR)               

cd $PBS_O_WORKDIR

export OMP_NUM_THREADS=1

make all_run
```

This is now submitted to the queue (__remember to change the charging code to your own code__):
```
$ qsub submit_libgrid.pbs
```

NOTE: the job can take several hours to complete.

Now determine the optimum compile flags/options and create the static library:

```
$ make gen_best
$ make libgrid.a
```

Finally, create a directory for libgrid and copy the library into this directory

```
$ mkdir /work/[project]/[project]/[username]/CP2K/build/libs/libgrid
$ cp libgrid.a /work/[project]/[project]/[username]/CP2K/build/libs/libgrid/
```

## Plumed

Download plumed 2.3.6 from [here](http://www.plumed.org/get-it) and copy the tarball onto ARCHER. Once it is on ARCHER, extract the tarball, `cd` into the directory and build:

```
$ tar -xzf plumed-2.3.6.tgz
$ cd plumed-2.3.6
$ export CRAYPE_LINK_TYPE=dynamic
$ ./configure --prefix=/work/[project]/[project]/[username]/CP2K/build/libs/plumed
$ make
$ make install
```

# Building CP2K

We are now in a position where we can build CP2K. To do this we need an _arch_ file, which is used to set environment variables and compile options for the machine we are compiling CP2K on. We will use the file `ARCHER.psmp` as the _arch_ file. We wish to place this file in the `arch` directory in the CP2K source directory:

```
$ cp ARCHER.psmp /work/[project]/[project]/[username]/CP2K/cp2k/cp2k/arch/
```

__IMPORTANT:__ You will need to edit the lines
```
DATA_DIR = /work/z01/z01/gpsgibb/CP2K/build/cp2k/cp2k/data
LIB_LOC  = /work/z01/z01/gpsgibb/CP2K/build/libs
```
to point to your CP2K directory.

We then move into the makefiles directory:
```
$ cd /work/[project]/[project]/[username]/CP2K/cp2k/cp2k/makefiles/
```

And make CP2K with:
```
$ make -j4 ARCH=ARCHER VERSION=psmp cp2k
```

If successful, the CP2K executable `cp2k.psmp` should be located at `
 /work/[project]/[project]/[username]/CP2K/cp2k/cp2k/exe/ARCHER/cp2k.psmp
`
