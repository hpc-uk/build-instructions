OpenFOAM
========

This folder contains files and documentation for building and maintaining
[OpenFOAM](http://www.openfoam.org) on [Cirrus](http://www.cirus.ac.uk).

History
-------

Date | Person | Version | Notes
---- | -------|---------|------
2017-04-19 | Andy Turner | 4.1 | Buidl instructions for GCC 6.2.0

Build Instructions
------------------

* [OpenFOAM 4.1 Build Instructions for GCC 6 Compilers](build_openfoam_4.1_gcc6.md)
* [OpenFOAM 5.0 Build Instructions for GCC 6 Compilers](build_openfoam_5.0_gcc6.md)

Notes
-----

### MPI Support

All versions of OpenFOAM are compiled against SGI MPI.

To use OpenFOAM with MPI you must load the `mpt` module in your scripts.

```bash
module load mpt
```

