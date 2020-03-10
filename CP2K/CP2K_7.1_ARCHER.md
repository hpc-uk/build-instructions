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
2c.        | Fortran/C/C++| No       | Available | via module `gcc/6.3.0`
2d.        | BLAS/LAPACK  | No       | Available | via module `cray-libsci/16.11.1`
2e.        | MPI?SCLAPACK | Yes      | Available | 
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
2r.        | FPGA         | Yes      | --        | Not relevant


# Downloading CP2K and basic setup

## Setup
First of all, we need to switch to the GNU compiler suite:

```
$ module swap PrgEnv-cray PrgEnv-gnu
```

## Download CP2K


# Building third-party libraries

## libint

CP2K releases versions of libint appropirate for CP2K at https://github.com/cp2k/libint-cp2k
so a download can be selected. A choice is required on the highest `lmax` supported: we choose
`lmax = 4`.

```
$ wget https://github.com/cp2k/libint-cp2k/releases/download/v2.6.0/libint-v2.6.0-cp2k-lmax-4.tgz
```



## libxc


## libxsmm


## Plumed



# Compile CP2K itself

## libgrid autotuning

## CP2K

`
