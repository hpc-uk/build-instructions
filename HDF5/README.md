HDF5
====

This folder contains files and documentation for building and maintaining
[HDF5](http://www.hdfgroup.org/HDF5) on [Cirrus](http://www.epcc.ed.ac.uk/cirus).

History
-------

Date | Person | Version | Notes
---- | -------|---------|------
2017-06-17 | Andy Turner | 1.10.1 Intel 17.0.2 MPT 2.14| Parallel HDF5

Build Instructions
------------------

* [HDF5 1.10.1 Intel 17.0.2 MPT 2.14](build_hdf5_1101_intel17mpt214.md)

Notes
-----

### MPI Support

All versions of FFTW are compiled against SGI MPI.

To use FFTW with MPI you must load the `mpt` module in your scripts
along with the `fftw` module:

```bash
module load mpt
module load fftw
```

