# Delft3d

See https://oss.deltares.nl/web/delft3dfm/get-started

Note that one needs to register to obtain access to the Delft3d svn
repository itself (see link above "register" at the top right).

Delft3d has a significant number of potential dependencies,
and I have tried to minimise the ones actually built here.

All elements are built with the latest Intel oneAPI version (currently
2022.1.0 and gcc/8.2.0)

```
module load oneapi
module load compiler/latest
module load gcc
```

Arrange the accompanying scripts in an appropriate location in the
work file system.
All installations are in `$(pwd)/install` (currently hardwired in
each script).

## General

Delft3d wants to produce shared objects, so make sure `-fPIC` is used,
even if generating static libraries.


## Utilities

```
$ bash ./build-expat.sh
$ bash ./build-readline.sh
```

## HDF5, NetCDF

Note that both `netcdf` and `netcdf-fortran` are installed to
`$(pwd)/install/netcdf`.

```
$ bash ./build-hdf5.sh
$ bash ./build-netcdf.sh
$ bash ./build-netcdf-fortran.sh
```

## OSGeo packages

```
$ bash ./build-proj.sh
$ bash ./build-shapelib.sh
$ bash ./build-gdal.sh
```

## Metis, PETSc

Note that PETSc also has a significant number of optional dependencies.
Here we use Intel MKL, Metis, and HDF5 (as above).

```
$ bash ./build-metis.sh
$ bash ./build-petsc.sh
```

## Delft3d

Again, one needs to register at the Deltares site and obtain a password to
allow access to the svn repository.

It is assumed that the repository is available as subdirectory `delft3d`.

```
$ svn checkout https://svn.oss.deltares.nl/repos/delft3d/tags/delft3dfm/141346 delft3d
$ bash ./build-delft3d/.sh
```

The resulting executables should be in `$(pwd)/install/delft3d/bin`.
