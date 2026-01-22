#!/bin/bash
# ICON-AES does not compile with Cray - incompatible NAMELIST format.
# Probably non-standard Fortran used in ICON-AES.
module switch PrgEnv-cray PrgEnv-gnu
module load cray-netcdf
# It may not be necessary to unload xalt.
module unload xalt
