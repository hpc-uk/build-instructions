PRFX=/work/y07/shared/apps/core/
VMD_LABEL=vmd
VMD_VERSION=1.9.3
VMD_ROOT=${PRFX}/${VMD_LABEL}
VMD_NAME=${VMD_LABEL}-${VMD_VERSION}
HDF5_VERSION=1.12.2.1
NETCDF_VERSION=4.9.0.1
TCL_VERSION=8.6.13
TCL_VERSION_MAJOR=`echo ${TCL_VERSION} | cut -d'.' -f1-2`
TK_VERSION=8.6.13
TK_VERSION_MAJOR=`echo ${TK_VERSION} | cut -d'.' -f1-2`
FLTK_VERSION=1.3.8
CPE_VERSION_MAJOR=`echo ${CRAY_CC_VERSION} | cut -d'.' -f1`
module load cray-hdf5/${HDF5_VERSION}
module load cray-netcdf/${NETCDF_VERSION}
module load tcl/${TCL_VERSION}
module load tk/${TK_VERSION}
export PLUGINDIR=${VMD_ROOT}/${VMD_NAME}/plugins
export TCLINC=-I/work/y07/shared/utils/core/tcl/${TCL_VERSION}/include
export TCLLIB=-L/work/y07/shared/utils/core/tcl/${TCL_VERSION}/lib
cd /work/y07/shared/utils/core/vmd/vmd-1.9.3/lib/surf
