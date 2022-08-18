# Paraview 5.10.1

The accompanying script may be used to install a version of Paraview
along with its relevant dependencies.

The script should be edited to reflect the desired install location,
e.g.,
```
# Install path
version="5.10.1"
export PV_INSTALL=/work/y07/shared/utils/core/paraview/${version}
```

Place the script in a suitable location and run
```
$ bash ./build-pv.sh
```
This should take around one hour or so.

Note that this version contains the configuration option
```
-DPARAVIEW_ENABLE_RAYTRACING=on
```
which is required to allow OSPRay volume rendering functionality.
