GCC
===

This folder contains files and documentation for building and maintaining GCC on Cirrus.

History
-------

Date | Person | Version | Notes
---- | -------|---------|------
2016-11-07 | Andy Turner | 6.2.0 | First build from source.

Build Instructions
------------------

* [GCC 6.2.0 Build Instructions](build_gcc_6.md)

Notes
-----

### MPI Library Compatibility

All versions of GCC are compatible with SGI MPT.

### Using SGI MPT with gfortran

SGI MPT does not support the "use" syntax for MPI with any version of gfortran.
i.e. the syntax:

```fortran
use mpi
```

**will not work**.

Instead, you must use the older:

```fortran
include 'mpif.h'
```

syntax.

