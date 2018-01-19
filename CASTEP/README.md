CASTEP
======

This folder contains files and documentation for building CASTEP on various HPC facilities.

History
-------

Date | Person | System | Version | Notes
---- | -------|--------|---------|------
2018-01-19 | Andy Turner | Athena (HPC Mid+) | 18.1.0, GCC 6.x, MPI, Broadwell | MPI build instructions for Athena
2018-01-19 | Andy Turner | ARCHER (EPCC) | 18.1.0, GCC 6.x, MPI, Ivy Bridge | MPI build instructions for ARCHER
2017-11-30 | Andy Turner | CSD3-Skylake (Cambridge) | 16.1.2, Intel 17, Skylake | MPI build instructions for CSD3 Skylake
2017-01-05 | Andy Turner | ARCHER (EPCC) | 16.1.2, Intel 16, Serial, x86_64 | Serial build instructions for ARCHER PP nodes using Intel 16 compilers
2016-12-21 | Andy Turner | ARCHER (EPCC) | 16.1.2, Intel 16, MPI, Ivy Bridge | MPI build instructions for ARCHER Ivy Bridge nodes using Intel 16 compilers

Build Instructions
------------------

* [CASTEP 18.1.0 Athena HPC Mid+ GCC 6.x Build Instructions](Athena_18.1.0_gcc6_IMPI.md)
* [CASTEP 18.1.0 ARCHER Ivy Bridge GCC 6.x Build Instructions](ARCHER_18.1.0_gcc6_CrayMPT.md)
* [CASTEP 17.2.1 CSD3-Skylake Intel 17 Build Instructions](CSD3Skylake_17.2.1_intel17_IMPI.md)
* [CASTEP 16.1.2 ARCHER Ivy Bridge Intel 16 Build Instructions](ARCHER_16.1.2_intel16_CrayMPT.md)
* [CASTEP 16.1.2 ARCHER serial x86_64 Intel 16 Build Instructions](ARCHER_16.1.2_serial_intel16.md)

Notes
-----

* ARCHER serial versions are compiled to work on post-processing nodes, login nodes and compute nodes
* ARCHER MPI versions are compiled to work on compute nodes only

