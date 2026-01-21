# Paraview 6.0.1

The accompanying script may be used to install a version of Paraview
along with its relevant dependencies.

The script should be edited to reflect the desired install location,
e.g.,
```
export PARAVIEW_VERSION=6.0.1
export PV_INSTALL=/work/y07/shared/utils/core/paraview/${PARAVIEW_VERSION}
```

Similarly, dependencies versions can be edited from the header of the script.

Place the script in a suitable location and run
```
$ bash build-paraview.sh
```
This should take around one hour or so.

Note that this version contains the configuration option
```
-DPARAVIEW_ENABLE_RAYTRACING=on
```
which is required to allow OSPRay volume rendering functionality.

## Run time

At runtime the `PATH`, `LD_LIBRARY_PATH` and `PYTHON_PATH` variables need to be appended. The commands to run can be retrieved by running:
```
$ bash build-paraview.sh export
```

