# WRF and WPS

For general information on the installation of WRF see e.g.,

https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php

## Install

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
  1) cce/11.0.4                                  9) cray-libsci/21.04.1.1
  2) craype/2.7.6                               10) PrgEnv-cray/8.0.0
  3) craype-x86-rome                            11) bolt/0.7
  4) libfabric/1.11.0.4.71                      12) epcc-setup-env
  5) craype-network-ofi                         13) load-epcc-module
  6) perftools-base/21.02.0                     14) cray-hdf5/1.12.0.3
  7) xpmem/2.2.40-7.0.1.0_2.7__g1d7a24d.shasta  15) cray-netcdf/4.7.4.3
  8) cray-mpich/8.1.4
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

The module environemt at the time of writing was:
```
Currently Loaded Modules:
  1) gcc/10.2.0                                  9) cray-libsci/21.04.1.1
  2) craype/2.7.6                               10) bolt/0.7
  3) craype-x86-rome                            11) epcc-setup-env
  4) libfabric/1.11.0.4.71                      12) load-epcc-module
  5) craype-network-ofi                         13) PrgEnv-gnu/8.0.0
  6) perftools-base/21.02.0                     14) cray-hdf5/1.12.0.3
  7) xpmem/2.2.40-7.0.1.0_2.7__g1d7a24d.shasta  15) cray-netcdf/4.7.4.3
  8) cray-mpich/8.1.4
```


## Static geographical data

Download both low resolution and high resolution data as required

```
wget --no-check-certificate https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz

wget --no-check-certificate https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz

```
The high resolution is about 2.9 GB compressed.

