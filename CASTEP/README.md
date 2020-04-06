CASTEP
======

This folder contains files and documentation for building CASTEP on various HPC facilities.

History
-------

Date | Person | System | Version | Notes
---- | -------|--------|---------|------
2020-03-23 | Andy Turner | A64FX | 18.1.0, Fujitsu Flang 1.2.19, A64FX | MPI build instructions for A64FX
2019-02-04 | Andy Turner | Tesseract (EPCC) | 18.1.0, Intel 18, Intel Skylake Silver | MPI build instructions for Tessearct
2019-02-04 | Andy Turner | Cirrus (EPCC) | 18.1.0, Intel 17, Intel Broadwell | MPI build instructions for Cirrus
2018-08-09 | Andy Turner | Isambard (GW4) | 18.1.0, Cray CCE 8, Arm ThunderX2 | MPI build instructions for Isambard
2018-05-08 | Andy Turner | Cirrus (EPCC) | 16.1.1, Intel 17, Intel Broadwell | MPI build instructions for Cirrus
2018-01-19 | Andy Turner | Athena (HPC Mid+) | 18.1.0, GCC 6.x, Intel Broadwell | MPI build instructions for Athena
2018-01-19 | Andy Turner | ARCHER (EPCC) | 18.1.0, GCC 6.x, Intel Ivy Bridge | MPI build instructions for ARCHER
2017-11-30 | Andy Turner | Peta4-Skylake (Cambridge) | 16.1.2, Intel 17, Intel Skylake Gold | MPI build instructions for CSD3 Skylake
2017-01-05 | Andy Turner | ARCHER (EPCC) | 16.1.2, Intel 16, Serial, Intel x86_64 | Serial build instructions for ARCHER PP nodes using Intel 16 compilers
2016-12-21 | Andy Turner | ARCHER (EPCC) | 16.1.2, Intel 16, Intel Ivy Bridge | MPI build instructions for ARCHER Ivy Bridge nodes using Intel 16 compilers

Build Instructions
------------------

* [CASTEP 18.1.0 A64FX, Fujitsu Flang 1.2.19 Build Instructions](Fujitsu-A64fx_18.1.0_tcsds1.2.19.md)
* [CASTEP 18.1.0 ARCHER (Intel Xeon Ivy Bridge, Cray XC30) GCC 6.x Build Instructions](ARCHER_18.1.0_gcc6_CrayMPT.md)
* [CASTEP 16.1.2 ARCHER (Intel Xeon Ivy Bridge, Cray XC30) Intel 16 Build Instructions](ARCHER_16.1.2_intel16_CrayMPT.md)
* [CASTEP 16.1.2 ARCHER (Intel Xeon Ivy Bridge, Cray XC30) serial x86_64 Intel 16 Build Instructions](ARCHER_16.1.2_serial_intel16.md)
* [CASTEP 18.1.0 Athena HPC Mid+ (Intel Xeon Broadwell, Huawei) GCC 6.x Build Instructions](Athena_18.1.0_gcc6_IMPI.md)
* [CASTEP 18.1.0 Cirrus (Intel Xeon Broadwell, HPE/SGI Apollo 8600) Intel 17 Build Instructions](Cirrus_18.1.0_intel17_HPEMPT.md)
* [CASTEP 16.1.1 Cirrus (Intel Xeon Broadwell, HPE/SGI Apollo 8600) Intel 17 Build Instructions](Cirrus_16.1.1_intel17_HPEMPT.md)
* [CASTEP 17.2.1 CSD3-Skylake (Intel Xeon Skylake Gold) Intel 17 Build Instructions](CSD3Skylake_17.2.1_intel17_IMPI.md)
* [CASTEP 18.1.0 Isambard (Cavium ThunderX2, Arm, Cray XC50) CCE 8.x Build Instructions](Isambard_18.1.0_cce8_mpich3.md)
* [CASTEP 18.1.0 Tesseract (Intel Xeon Skylake Silver, HPE/SGI Apollo 8600) Intel 18 Build Instructions](Tesseract_18.1.0_intel18_IMPI.md)


Notes
-----

* ARCHER serial versions are compiled to work on post-processing nodes, login nodes and compute nodes
* ARCHER MPI versions are compiled to work on compute nodes only

