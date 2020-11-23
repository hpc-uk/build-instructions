NetCDF
======

This folder contains files and documentation for building and maintaining
[NetCDF](https://www.unidata.ucar.edu/software/netcdf/) on various HPC systems.

History
-------

Date | Person | System | Version | Notes
---- | -------|--------|---------|------
2018-03-15 | Elena Breitmoser | Cirrus | 4.5.0 Intel 17.0.2 MPT 2.14| Parallel NetCDF
2018-03-15 | Michael Bareford | Cirrus | 4.5.0 GCC 6.2.0 MPT 2.14| Parallel NetCDF

Build Instructions
------------------

* [NetCDF 1.10.1 Intel 17.0.2 MPT 2.14](build_netcdf_1101_intel17mpt214.md)
* [NetCDF 1.10.1 GCC 6.2.0 MPT 2.14](build_netcdf_1101_gcc6mpt214.md)

Notes
-----

### Cirrus

The NetCDF Intel 17 build has been compiled without NetCDF 4 support;
whereas the NetCDF GCC 6 build has been compiled with NetCDF 4 support.

