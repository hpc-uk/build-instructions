# WRF and WPS

For general information on the installation of WRF see e.g.,

https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php

## Install

### `PrgEnv-gnu`

Two prerequisites are installed in the current directory

```
$ bash ./build-jasper-gnu.sh
$ bash ./build-libpng-gnu.sh
```

The WRF and WPS can be built

```
$ bash ./build-wrf-gnu.sh
$ bash ./build-wps-gnu.sh
```

Note that for `PrgEnv-gnu` we use `gcc/9.3.0` which works with the
default compiler options from the WRF/WPS configuration. For GCC 10,
additional options will be required.


## Static geographical data

Download both low resolution and high resolution data as required

```
wget --no-check-certificate https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz

wget --no-check-certificate https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz

```
The high resolution is about 2.9 GB compressed.

