depends_on ("PrgEnv-gnu")
depends_on("cray-hdf5-parallel")
depends_on("cray-netcdf-hdf5parallel")
depends_on("cray-parallel-netcdf")

-- template variables ----------------------------------------------------------
local INSTALL_ROOT        = "/path/to/install"
local VERSION             = "8.6.1"
local COMPAT_VERSION      = "8.6"
local COMPILER            = "gnu"
local COMPILER_VERSION    = "9.1"
--------------------------------------------------------------------------------

local product             = "ESMF"
local PRODUCT             = "ESMF"

local PE_DIR              = pathJoin(INSTALL_ROOT, product, VERSION)


help([[
ESMF 8.6.1
]])

whatis("This modulefile defines the system paths and environment " ..
       "variables needed to use ESMF 8.6.1.")

-- environment modifications --

setenv ( "ESMF_OS"              , "Unicos"    )
setenv ( "ESMF_ABI"             , "64"        )
setenv ( "ESMF_COMM"            , "mpich"     )
setenv ( "ESMF_COMPILER"        , "gfortran"  )
setenv ( "ESMF_BOPT    "        , "O"         )
setenv ( "ESMF_OPTLEVEL"        , "2"         )

setenv ( "ESMF_NETCDF"          , "nc-config" )

setenv ( "ESMF_NETCDF_INCLUDE"  , "$CRAY_NETCDF_HDF5PARALLEL_PREFIX/include" )
setenv ( "ESMF_NETCDF_LIBPATH"  , "$CRAY_NETCDF_HDF5PARALLEL_PREFIX/lib"     )
setenv ( "ESMF_NETCDFF_INCLUDE" , "$CRAY_NETCDF_HDF5PARALLEL_PREFIX/include" )

setenv ( "PARALLEL_NETCDF_DIR"  , "$CRAY_PARALLEL_NETCDF_PREFIX" )
setenv ( "PNETCDF_ROOT"         , "path"                         )
setenv ( "ESMF_PNETCDF"         , "pnetcdf-config"               )

setenv ( "ESMF_INSTALL_PREFIX"  , PE_DIR )
setenv ( "ESMFMKFILE"           , PE_DIR .. "/lib/libO/Unicos.gfortran.64.mpich.default/esmf.mk" )
setenv ( "ESMF_LIBDIR"          , PE_DIR .. "/lib/libO/Unicos.gfortran.64.mpich.default" )
