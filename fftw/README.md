FFTW
====

This folder contains files and documentation for building and maintaining
[FFTW](http://www.fftw.org) on [Cirrus](http://www.epcc.ed.ac.uk/cirus).

History
-------

Date | Person | Version | Notes
---- | -------|---------|------
2016-12-01 | Andy Turner | 3.3.5 | First build from source.

Build Instructions
------------------

* [FFTW 3.3.5 Build Instructions for Intel 16 Compilers](build_fftw_335_intel16.md)

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

