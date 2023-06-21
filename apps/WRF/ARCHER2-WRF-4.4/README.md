# WRF and WPS

For general information on the installation of WRF see e.g.,

https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php

## Install

### Note

The scripts described below use
```
module load cray-hdf5
module load cray-netcdf
```
to provide (serial) HDF5 and NetCDF, respectively. It should be possible
to make a uniform replacement by
```
module load cray-hdf5-parallel
module load cray-netcdf-hdf5parallel
```
to provide parallel version, if this is wanted.

### `PrgEnv-cray`

Two prerequisites are installed to a subdirectory `grib2` of the current
directory

```
$ bash ./build-jasper-cray.sh
$ bash ./build-libpng-cray.sh
```

Then WRF and WPS can be built

```
$ bash ./build-wrf-cray.sh
$ bash ./build-wps-cray.sh
```

Allow 2-3 hours for this build.

The module environment at the time of writing was:
```
Currently Loaded Modules:
  1) craype-x86-rome                         9) cce/15.0.0
  2) libfabric/1.12.1.2.2.0.0               10) craype/2.7.19
  3) craype-network-ofi                     11) cray-dsmml/0.2.2
  4) perftools-base/22.12.0                 12) cray-mpich/8.1.23
  5) xpmem/2.5.2-2.4_3.30__gd0f7936.shasta  13) cray-libsci/22.12.1.1
  6) bolt/0.8                               14) PrgEnv-cray/8.3.3
  7) epcc-setup-env                         15) cray-hdf5/1.12.2.1
  8) load-epcc-module                       16) cray-netcdf/4.9.0.1
```


### `PrgEnv-gnu`

Two prerequisites are installed in the current directory (subdirectory
`grib2` specified in the script)

```
$ bash ./build-jasper-gnu.sh
$ bash ./build-libpng-gnu.sh
```

Then WRF and WPS can be built

```
$ bash ./build-wrf-gnu.sh
$ bash ./build-wps-gnu.sh
```

Allow 15-20 minutes for this build.

The module environment at the time of writing was:
```
Currently Loaded Modules:
  1) craype-x86-rome                         9) gcc/11.2.0
  2) libfabric/1.12.1.2.2.0.0               10) craype/2.7.19
  3) craype-network-ofi                     11) cray-dsmml/0.2.2
  4) perftools-base/22.12.0                 12) cray-mpich/8.1.23
  5) xpmem/2.5.2-2.4_3.30__gd0f7936.shasta  13) cray-libsci/22.12.1.1
  6) bolt/0.8                               14) PrgEnv-gnu/8.3.3
  7) epcc-setup-env                         15) cray-hdf5/1.12.2.1
  8) load-epcc-module                       16) cray-netcdf/4.9.0.1
```


## Static geographical data

Download both low resolution and high resolution data as required

```
wget --no-check-certificate https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz

wget --no-check-certificate https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz

```
The high resolution is about 2.9 GB compressed.

