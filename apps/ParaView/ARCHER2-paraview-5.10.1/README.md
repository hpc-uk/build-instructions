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

## Run time

For a given install location `PV_INSTALL` one requires at run time:
```
export PATH = ${PV_INSTALL}/paraview/bin:${PATH}

export LD_LIBRARY_PATH=${PV_INSTALL}/ospray/2.1.0/ospray/lib64:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${PV_INSTALL}/ospray/2.1.0/openvkl/lib64:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${PV_INSTALL}/ospray/2.1.0/embree/lib64:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${PV_INSTALL}/llvm/lib:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${PV_INSTALL}/mesa/21.0.1/lib64:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${PV_INSTALL}/paraview/lib64:${LD_LIBRARY_PATH}

export PYTHONPATH=${PV_INSTALL}/paraview/lib64/python3.8/site-packages:${PYTHONPATH}
```
