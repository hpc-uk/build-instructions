# ARCHER2 GPAW version 22.1.0

Arrange the three accompanying files in a suitable location on
e.g.,`/work`
```
kevin@ln01:> ls
build_gpaw.sh  build_libxc.sh  siteconfig.py
```

Run the script to build `libxc`:
```
kevin@ln01:> bash ./build_libxc.sh
```
which will use the current directory as the intall location.

Run the script to build `GPAW`:
```
kevin@ln01:> bash ./build_gpaw.sh
```
which will install in the same location. The scripts can be edited
to change the location if required.

## Run time

The location of both `libxc` and `GPAW` should be added to the
`PATH` and `LD_LIBRARY_PATH`, e.g.,
```
export my_prefix=$(pwd)
export PATH=${PATH}:${my_prefix}/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${my_prefix}/lib
```
