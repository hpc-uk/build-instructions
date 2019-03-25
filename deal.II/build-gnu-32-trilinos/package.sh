#!/bin/bash

. env.sh
. modules.sh
cd $build_dir

mkdir -p $build_dir/
mkdir -p $build_dir/modulefiles
mkdir -p $build_dir/modulefiles/deal_II

export modulefiles=$build_dir/modulefiles
full_version=$version-$config_name

# .version file
echo '#%Module' > $modulefiles/deal_II/.version
echo 'set ModulesVersion "'$full_version'"' >> $modulefiles/deal_II/.version

export modulefile=$modulefiles/deal_II/$full_version

cat >> $modulefile <<EOF
#%Module
#
# Module deal_II
#

# the prereqs and conflicts are tested before environment is changed,
# so they can be safely placed anywhere in a modulefile
conflict deal_II

setenv CRAYPE_LINK_TYPE dynamic

# need PrgEnv-gnu
if {[is-loaded PrgEnv-gnu]} {
} elseif {[is-loaded PrgEnv-cray]} {
    puts stderr "WARNING: swapping from PrgEnv-cray to PrgEnv-gnu"
    module swap PrgEnv-cray PrgEnv-gnu
} elseif {[is-loaded PrgEnv-intel]} {
    puts stderr "WARNING: swapping from PrgEnv-intel to PrgEnv-gnu"
    module swap PrgEnv-intel PrgEnv-gnu
} else {
    module load PrgEnv-gnu
}

module switch gcc/5.3.0

module unload cmake
module load cmake

# deal.II's own Boost should be used.
module unload boost-serial
module unload boost

# optional modules
module unload cray-hdf5-parallel
module load cray-hdf5-parallel
module unload cray-netcdf-hdf5parallel
module load cray-netcdf-hdf5parallel
module unload cray-tpsl
module load cray-tpsl
module unload cray-trilinos
module load cray-trilinos

proc ModulesHelp { } {
    puts stderr "deal_II"
    puts stderr {=======

What it is: A C++ software library supporting the creation of finite
element codes and an open community of users and developers.

Mission: To provide well-documented tools to build finite element
codes for a broad variety of PDEs, from laptops to supercomputers.

Vision: To create an open, inclusive, participatory community
providing users and developers with a state-of-the-art, comprehensive
software library that constitutes the go-to solution for all finite
element problems

Website: https://www.dealii.org/

Built on ARCHER with Gnu compilers as a shared library, in 32 bit
index mode with the bindings for Trilinos, METIS, and HDF5.

Note this module sets CRAYPE_LINK_TYPE=dynamic to force use of shared
libraries.

Installed on DD MMM 2018 by Aaaaaaaa Bbbbbbbb
}
}

module-whatis "C++ software library supporting the creation of finite element codes"

EOF

echo "prepend-path LD_LIBRARY_PATH {$install_dir/lib}" >> $modulefile
echo "prepend-path PATH {$install_dir/p4est/FAST/bin}" >> $modulefile

echo "setenv DEAL_II_DIR $install_dir" >> $modulefile

if [[ $USER == 'cse' ]] ; then
    sudo -u packmods mkdir -p /home/y07/y07/packmods/modulefiles-archer/deal_II
    sudo -u packmods cp $modulefile /home/y07/y07/packmods/modulefiles-archer/deal_II
    # Uncomment the following line to update the default version
#    sudo -u packmods cp $modulefiles/deal_II/.version /home/y07/y07/packmods/modulefiles-archer/deal_II/
fi
