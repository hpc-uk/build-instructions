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

Allow 1-2 hours for this build.


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

Note that for `PrgEnv-gnu` we use `gcc/9.3.0` which works with the
default compiler options from the WRF/WPS configuration. For GCC 10,
additional options will be required.

Allow 15-20 minutes for this build.


## Static geographical data

Download both low resolution and high resolution data as required

```
wget --no-check-certificate https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz

wget --no-check-certificate https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz

```
The high resolution is about 2.9 GB compressed.

