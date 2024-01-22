Instructions for compiling VMD 1.9.3 on ARCHER2
===============================================

These instructions are for compiling VMD 1.9.3 (serial and parallel) on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using the GCC 11 compilers and Cray MPICH 8.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/utils/core
VMD_LABEL=vmd
VMD_VERSION=1.9.3
VMD_ROOT=${PRFX}/${VMD_LABEL}
VMD_NAME=${VMD_LABEL}-${VMD_VERSION}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download and unpack VMD source
------------------------------

```bash
mkdir -p ${VMD_ROOT}
cd ${VMD_ROOT}

# expand VMD software archive
if [ -f ${VMD_ROOT}/arc/${VMD_NAME}.src.tar.gz ]; then
  cp ${VMD_ROOT}/arc/${VMD_NAME}.src.tar.gz ${VMD_ROOT}/
  tar -vxzf ${VMD_NAME}.src.tar.gz
  rm ${VMD_NAME}.src.tar.gz
else
  mkdir -p ${VMD_ROOT}/arc
  echo "Please download the VMD source archive from http://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=VMD"
  echo "into  the ${VMD_ROOT}/arc folder."
  exit
fi

cd ${VMD_NAME}
```


Switch to the GNU Programming Environment and setup required modules
--------------------------------------------------------------------

```bash
module -q load PrgEnv-gnu
GNU_VERSION_MAJOR=`echo ${GNU_VERSION} | cut -d'.' -f1`

module -q load cray-hdf5/1.12.2.1
module -q load cray-netcdf/4.9.0.1
module -q load cray-python/3.9.13.1
module -q load tcl/8.6.13
module -q load tk/8.6.13
module -q load mesa/23.3.3
```


Build VMD plugins
-----------------

```bash
mkdir ${VMD_ROOT}/${VMD_NAME}/plugins
export PLUGINDIR=${VMD_ROOT}/${VMD_NAME}/plugins
cd ${VMD_ROOT}/plugins

export TCLINC=-I${PRFX}/tcl/8.6.13/include
export TCLLIB=-L${PRFX}/tcl/8.6.13/lib
```

Add the following line to the LINUXAMD64 section in the `Make-arch` file.

```bash
...
LINUXAMD64:
        ...
        "TCLLDFLAGS = -ltcl8.6 -ldl" \
        "NETCDFLDFLAGS = -L/opt/cray/pe/netcdf/4.9.0.1/GNU/9.1/lib -lnetcdf" \
        ...
...
```

Run the plugin make commands.

```bash
make LINUXAMD64
make distrib PLUGINDIR=${VMD_ROOT}/${VMD_NAME}/plugins
```


Build the Fast Light Tool Kit (FLTK)
------------------------------------

```bash
cd ${VMD_ROOT}
mkdir fltk
cd fltk
wget https://www.fltk.org/pub/fltk/1.3.9/fltk-1.3.9-source.tar.gz
tar -xvzf fltk-1.3.9-source.tar.gz
cd fltk-1.3.9
./configure --prefix=${VMD_ROOT}/fltk/1.3.9-gcc${GNU_VERSION_MAJOR}
make
make install
```


Build Stride
------------

```bash
cd ${VMD_ROOT}/${VMD_NAME}
cd lib
cd stride
wget http://webclu.bio.wzw.tum.de/stride/stride.tar.gz
tar -xvzf stride.tar.gz
make
ln -s stride stride_LINUXAMD64
```


Build Surf
----------

```bash
cd ../surf
tar -xvzf surf.tar.Z
make depend
make surf
ln -s surf surf_LINUXAMD64
```


Build Tachyon
-------------

```bash
cd ..
mv tachyon tachyon.arc
git clone https://github.com/thesketh/Tachyon.git tachyon.serial
cp -r tachyon.serial tachyon.parallel

cd tachyon.serial/unix
make linux-64
cd ..
ln -s ./compile/linux-64/tachyon tachyon_LINUXAMD64

cd ../tachyon.parallel/unix
```

Amend the following lines in the linux-lam-64 section of the `Make-arch` file.

```bash
...
linux-lam-64:
        ...
        "CC = cc"
        "CFLAGS = -I/opt/cray/pe/mpich/8.1.23/ofi/GNU/9.1/include ..."
        ...
        "LIBS = -L. -L$(LAMHOME)/lib -L/opt/cray/pe/mpich/8.1.23/ofi/GNU/9.1/lib ..."
...
```

Make Tachyon.

```bash
make linux-lam-64
cd ..
ln -s ./compile/linux-lam-64/tachyon tachyon_LINUXAMD64
```


Return to the VMD folder
------------------------

```bash
cd ${VMD_ROOT}/${VMD_NAME}
```


Edit the VMD `configure` file as shown below
----------------------------------------------

```bash
...
# Directory where VMD startup script is installed, should be in users' paths.
$install_bin_dir="/work/y07/shared/utils/core/vmd/1.9.3-gcc11/bin";

# Directory where VMD files and executables are installed
$install_library_dir=""/work/y07/shared/utils/core/vmd/1.9.3-gcc11/lib";

...

################ Mesa location
# location of Mesa library and include files; basically does the same
# as OpenGL.  This is based on the default instructions from the Mesa
# README; the include files should by default be in /usr/local/include/GL.
$mesa_dir         = "/work/y07/shared/libs/core/mesa/23.3.3";
$mesa_include     = "-I$mesa_dir/include";
$mesa_library     = "-L$mesa_dir/lib64";
$mesa_libs        = "-lOSMesa";

...

################ FLTK GUI
...
$fltk_dir         = "/work/y07/shared/utils/core/vmd/fltk/1.3.9-gcc11";
$fltk_include     = "-I$fltk_dir/include";
$fltk_library     = "-L$fltk_dir/lib";

...

################ Tcl / Tk 
# location of TCL library and include file.
# If left blank, standard system  directories will be searched.
$stock_tcl_include_dir=$ENV{"TCL_INCLUDE_DIR"} || "/work/y07/shared/utils/core/tcl/8.6.13/include";
$stock_tcl_library_dir=$ENV{"TCL_LIBRARY_DIR"} || "/work/y07/shared/utils/core/tcl/8.6.13/lib";

...

# location of Tk (for TK option)
$stock_tk_include_dir=$ENV{"TK_INCLUDE_DIR"} || "/work/y07/shared/utils/core/tk/8.6.13/include";
$stock_tk_library_dir=$ENV{"TK_LIBRARY_DIR"} || "/work/y07/shared/utils/core/tk/8.6.13/lib";

...

$tcl_libs         = "-ltcl8.6";
if ($config_tk) { $tcl_libs = "-ltk8.6 -lX11 " . $tcl_libs; }

...

#######################
# OPTIONAL COMPONENT: MPI message passing API
#   This option enables cluster-wide VMD runs.
#   Choose one of the template MPI configs below and edit paths as needed
#######################
...
$mpi_dir         = "/opt/cray/pe/mpich/8.1.23/ofi/gnu/9.1";
$mpi_include     = "-I$mpi_dir/include";
$mpi_library     = "-L$mpi_dir/lib";
$mpi_libs        = "-lmpich";

...

#######################
# OPTIONAL COMPONENT: NetCDF I/O Library (Used by cdfplugin)
#######################
...
$netcdf_dir         = "/opt/cray/pe/netcdf/4.9.0.1/GNU/9.1";
$netcdf_include     = "-I$netcdf_dir/include";
$netcdf_library     = "-L$netcdf_dir/lib";
$netcdf_libs        = "-lnetcdf";

...

###################
# OPTIONAL COMPONENT: Python support
###################
$stock_python_include_dir=$ENV{"PYTHON_INCLUDE_DIR"} || "/opt/cray/pe/python/3.9.13.1/include/python3.9";
$stock_python_library_dir=$ENV{"PYTHON_LIBRARY_DIR"} || "/opt/cray/pe/python/3.9.13.1/include/lib/python3.9";

$stock_numpy_include_dir=$ENV{"NUMPY_INCLUDE_DIR"} || "/opt/cray/pe/python/3.9.13.1/lib/python3.9/site-packages/numpy/core/include";
$stock_numpy_library_dir=$ENV{"NUMPY_LIBRARY_DIR"} || "/opt/cray/pe/python/3.9.13.1/lib/python3.9/site-packages/numpy/core/lib";

...

if ($config_arch eq "LINUXAMD64") {
    ...
    $xlibs = "-lX11 -lXft -lXext -lXrender -lXinerama -lXcursor -lXfixes -lfontconfig";
    if (!$config_opengl_dispatch) {
      $opengl_dep_libs  = "-L/usr/lib64 -lGL $xlibs";
      $mesa_libs        = "-L/usr/lib64 $xlibs -L/work/y07/shared/libs/core/mesa/23.3.3/lib64 -lglapi -lOSMesa";
    }
    ...
}

...

```


Prepare to build VMD serial
---------------------------

```bash
cd ${VMD_ROOT}/${VMD_NAME}
rm -f ${VMD_ROOT}/${VMD_NAME}/LINUXAMD64/foobar
rm -f ${VMD_ROOT}/${VMD_NAME}/lib/tachyon
ln -s ${VMD_ROOT}/${VMD_NAME}/lib/tachyon.serial ${VMD_ROOT}/${VMD_NAME}/lib/tachyon
cd src
```


Edit the VMD `Makefile` file as shown below
-------------------------------------------

```
...

INCDIRS     =   -I/work/y07/shared/utils/core/tcl/8.6.13/include -I/work/y07/shared/utils/core/tk/8.6.13/include -I../plugins/include -I../plugins/LINUXAMD64/molfile -I/opt/cray/pe/netcdf/4.9.0.1/GNU/9.1/include -I/work/y07/shared/utils/core/vmd/fltk/1.3.9-gcc11/include -I.

...

LIBDIRS     =   -L/work/y07/shared/utils/core/tcl/8.6.13/lib -L/work/y07/shared/utils/core/tk/8.6.13/lib  -L../plugins/LINUXAMD64/molfile -L/opt/cray/pe/netcdf/4.9.0.1/GNU/9.1/lib -L/work/y07/shared/utils/core/vmd/fltk/1.3.9-gcc11/lib

...

```


Backup VMD `Makefile`
--------------------

```bash
cd ${VMD_ROOT}/${VMD_NAME}/src
cp Makefile Makefile.sav
```


Build VMD serial
----------------

```bash
cd ${VMD_ROOT}/${VMD_NAME}

./configure LINUXAMD64 OPENGL FLTK TK NETCDF TCL

cd src

make
make install
make clean

cd ..
```


Edit the VMD `configure` file once more
---------------------------------------

```bash
...
# Directory where VMD startup script is installed, should be in users' paths.
$install_bin_dir="/work/y07/shared/utils/core/vmd/1.9.3-mpi-gcc11/bin";

# Directory where VMD files and executables are installed
$install_library_dir="/work/y07/shared/utils/core/vmd/1.9.3-mpi-gcc11/lib";

...

```


Build VMD parallel
------------------
```bash
rm -f ${VMD_ROOT}/${VMD_NAME}/LINUXAMD64/foobar
rm -f ${VMD_ROOT}/${VMD_NAME}/lib/tachyon
ln -s ${VMD_ROOT}/${VMD_NAME}/lib/tachyon.parallel ${VMD_ROOT}/${VMD_NAME}/lib/tachyon

./configure LINUXAMD64 OPENGL FLTK TK MPI NETCDF TCL

cd src
cp Makefile.sav Makefile

make
make install
make clean
```
