OpenFOAM
========

This folder contains files and documentation for building and maintaining
[OpenFOAM](http://www.openfoam.org) on various HPC facilities.

History
-------

Date | Person | System | Version | Notes
---- | -------|--------|---------|------
2019-03-21 | Andy Turner | ARCHER (Cray XC30) | v6 | 
2017-04-19 | Andy Turner | Cirrus | 4.1 | 

Build Instructions
------------------

* [OpenFOAM v6 Build Instructions for GCC 6 Compilers on Cray XC30](build_openfoam_6_CrayXC_gcc6.md)
* [OpenFOAM 4.1 Build Instructions for GCC 6 Compilers](build_openfoam_4.1_gcc6.md)
* [OpenFOAM 5.0 Build Instructions for GCC 6 Compilers](build_openfoam_5.0_gcc6.md)

Notes
-----

### Cirrus MPI Support

All versions of OpenFOAM are compiled against HPE MPI.

To use OpenFOAM with MPI you must load the `mpt` module in your scripts.

```bash
module load mpt
```

