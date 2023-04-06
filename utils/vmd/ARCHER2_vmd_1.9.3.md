Instructions for compiling VMD 1.9.3 on the ARCHER2 4 Cabinet system
====================================================================

These instructions are for compiling VMD 1.9.3 (serial and parallel) on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using the CPE 15 compilers and Cray MPICH 8.

TODO: check all `${VMD_ROOT}` and `${VMD_NAME}`


Setup required modules
----------------------

```bash
CPE_VERSION_MAJOR=`echo ${CRAY_CC_VERSION} | cut -d'.' -f1`

module load cray-hdf5/${HDF5_VERSION}
module load cray-netcdf/${NETCDF_VERSION}
module load tcl/${TCL_VERSION}
module load tk/${TK_VERSION}

ln -s ${PRFX}/tk/${TK_VERSION}/lib/tk${TK_VERSION_MAJOR} ${PRFX}/tcl/${TCL_VERSION}/lib/tk${TK_VERSION_MAJOR}
```

Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
export PRFX=/work/y07/shared/utils/core
export VMD_LABEL=vmd
export VMD_VERSION=1.9.3
export VMD_ROOT=${PRFX}/${VMD_LABEL}
export VMD_NAME=${VMD_ROOT}/${VMD_LABEL}-${VMD_VERSION}
export VMDINSTALLBINDIR=${VMD_ROOT}/$VMD_VERSION-cpe${CPE_VERSION_MAJOR}/bin
export VMDINSTALLLIBRARYDIR=${VMD_ROOT}/$VMD_VERSION-cpe${CPE_VERSION_MAJOR}/lib

export HDF5_VERSION=1.12.2.1
export NETCDF_VERSION=4.9.0.1
export TCL_VERSION=8.6.13
export TCL_VERSION_MAJOR=`echo ${TCL_VERSION} | cut -d'.' -f1-2`
export TK_VERSION=8.6.13
export TK_VERSION_MAJOR=`echo ${TK_VERSION} | cut -d'.' -f1-2`
export FLTK_VERSION=1.3.8
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
  tar -xzf ${VMD_NAME}.src.tar.gz
  rm ${VMD_NAME}.src.tar.gz
else
  mkdir -p ${VMD_ROOT}/arc
  echo "Please download the VMD source archive from http://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=VMD"
  echo "into  the ${VMD_ROOT}/arc folder."
  exit
fi

cd ${VMD_NAME}
```


Build VMD plugins
-----------------

```bash
mkdir ${VMD_ROOT}/${VMD_NAME}/plugins
export PLUGINDIR=${VMD_ROOT}/${VMD_NAME}/plugins
cd ${VMD_ROOT}/plugins

export TCL_INCLUDE_DIR=/work/y07/shared/utils/core/tcl/${TCL_VERSION}/include
export TCL_LIBRARY_DIR=/work/y07/shared/utils/core/tcl/${TCL_VERSION}/lib
export TK_INCLUDE_DIR=/work/y07/shared/utils/core/tk/${TK_VERSION}/include
export TK_LIBRARY_DIR=/work/y07/shared/utils/core/tk/${TK_VERSION}/lib
export TCLINC=-I${TCL_INCLUDE_DIR}
export TCLLIB=-L${TCL_LIBRARY_DIR}
```

Add the following line to the LINUXAMD64 section in the ``Make-arch`` file.
```bash
...
LINUXAMD64:
        ...
        "TCLLDFLAGS = -ltcl8.6 -ldl"
        "NETCDFLDFLAGS = -L${NETCDF_DIR}/lib -lnetcdf " \
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
wget https://www.fltk.org/pub/fltk/${FLTK_VERSION}/fltk-${FLTK_VERSION}-source.tar.gz
tar -xvzf fltk-${FLTK_VERSION}-source.tar.gz
cd fltk-${FLTK_VERSION}
export FLTK_INSTALL_DIR=${VMD_ROOT}/fltk/${FLTK_VERSION}-cpe${CPE_VERSION_MAJOR}
./configure --prefix=${FLTK_INSTALL_DIR}
make
make install
```


Build Stride
------------

```bash
cd ${VMD_ROOT}/${VMD_NAME}/lib/stride
wget http://webclu.bio.wzw.tum.de/stride/stride.tar.gz
tar -xvzf stride.tar.gz
```

Edit the Makefile to use crayclang:

```
#FLAGS = -lm -L/usr/pub/lib -lefence -o
#CC = cc -O2 -fullwarn -TENV:large_GOT
#CC = cc -g -Wall
#CC = gcc -O2  # at least for SunOS
#CC = cc -g

#CC = cc -O2 -fullwarn

CC = cc -O2
```

Compile stride:

```bash
make
ln -s stride stride_LINUXAMD64
```


Build Surf
----------

```bash
cd ${VMD_ROOT}/${VMD_NAME}/lib/surf
tar -xvzf surf.tar.Z
```

Modify the Makefile:

```bash
CFLAGS      = -O2 -Wno-error=return-type $(FLAGS) $(INCLUDE)
```

and compile

```bash
make depend INCLUDE="-I. -I${INCLUDE_PATH_X86_64//:/ -I}"
make surf
ln -s surf surf_LINUXAMD64
```

The change of the INCLUDE variable is because `makedepend` will not look for header files in the normal places (`$CPATH`, `$C_INCLUDE_PATH`, `CPLUS_INCLUDE_PATH`), and cray clang has the header files in `$INCLUDE_PATH_X86_64`.

Build Tachyon
-------------

WEBSITE IS DOWN?

git = https://github.com/thesketh/Tachyon.git

```bash
cd ..
mv tachyon tachyon.arc
wget http://jedi.ks.uiuc.edu/~johns/raytracer/files/0.98.9/tachyon-0.98.9.tar.gz
tar -xvzf tachyon-0.98.9.tar.gz
mv tachyon-0.98.9.tar.gz ./tachyon.arc
mv tachyon tachyon.serial
cp -r tachyon.serial tachyon.parallel

cd tachyon.serial/unix
make linux-64
cd ..
ln -s ./compile/linux-64/tachyon tachyon_LINUXAMD64

cd ../tachyon.parallel/unix
```

Amend the following lines in the linux-lam-64 section of the ``Make-arch`` file.
```bash
...
linux-lam-64:
        ...
        "CFLAGS = -I/opt/cray/pe/mpich/8.1.23/ofi/crayclang/10.0/include ..."
        ...
        "LIBS = -L. -L$(LAMHOME)/lib -L/opt/cray/pe/mpich/8.1.23/ofi/crayclang/10.0/lib ..."
...
```

replace hcc with cc

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


Edit the VMD ``configure`` file as shown below
----------------------------------------------

```bash
...
# Directory where VMD startup script is installed, should be in users' paths.
$install_bin_dir="$ENV{'VMD_NAME'}/bin";

# Directory where VMD files and executables are installed
$install_library_dir="$ENV{'VMD_NAME'}/lib";
...

################ FLTK GUI
...
$fltk_dir         = $ENV{"FLTK_INSTALL_DIR"};
$fltk_include     = "-I$fltk_dir/include";
$fltk_library     = "-L$fltk_dir/lib";

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
$mpi_dir         = $ENV{"CRAY_MPICH_DIR"};
$mpi_include     = "-I$mpi_dir/include";
$mpi_library     = "-L$mpi_dir/lib";
$mpi_libs        = "-lmpich";

...

#######################
# OPTIONAL COMPONENT: NetCDF I/O Library (Used by cdfplugin)
#######################
...
$netcdf_dir         = $ENV{"NETCDF_DIR"};
$netcdf_include     = "-I$netcdf_dir/include";
$netcdf_library     = "-L$netcdf_dir/lib";
$netcdf_libs        = "-lnetcdf";

...

if ($config_arch eq "LINUXAMD64") {
  ...
  if ($config_icc) {
    # for compiling with Intel C/C++:
    $arch_cc          = "cc";
    $arch_ccpp        = "CC";
    ...
    $xlibs = "-lX11 -lXft -lXext -lXrender -lXinerama -lXcursor -lXfixes -lfontconfig";
    if (!$config_opengl_dispatch) {
      $opengl_dep_libs  = "-L/usr/lib64 -lGL $xlibs";
      $mesa_libs        = "-lMesaGL -L/usr/lib64 $xlibs";
    }
    ...
    #      $arch_lopts       .= "-static-intel ";
    ...
}

...

```


Build VMD serial
----------------

```bash
rm ${VMD_ROOT}/${VMD_NAME}/lib/tachyon
ln -s ${VMD_ROOT}/${VMD_NAME}/lib/tachyon.serial ${VMD_ROOT}/${VMD_NAME}/lib/tachyon
./configure LINUXAMD64 OPENGL FLTK TK NETCDF TCL ICC
cd src
make -j
make install
cd ..
```


Change the isnstall location
----------------------------

```bash
export VMDINSTALLBINDIR=${VMD_ROOT}/$VMD_VERSION-mpi-cpe${CPE_VERSION_MAJOR}/bin
export VMDINSTALLLIBRARYDIR=${VMD_ROOT}/$VMD_VERSION-mpi-cpe${CPE_VERSION_MAJOR}/lib
```


Build VMD parallel
------------------
```bash
rm ${VMD_NAME}/lib/tachyon
ln -s ${VMD_NAME}/lib/tachyon.parallel ${VMD_NAME}/lib/tachyon
./configure LINUXAMD64 OPENGL FLTK TK MPI NETCDF TCL ICC
cd src
make clean
make -j
make install
```
