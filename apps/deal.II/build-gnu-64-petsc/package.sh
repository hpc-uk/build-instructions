module load craypkg-gen

mkdir $build_dir/pkg-tmp
craypkg-gen -p $install_dir
craypkg-gen -m $install_dir -o $build_dir/pkg-tmp

module unload craypkg-gen

export modulefiles=$build_dir/pkg-tmp/modulefiles

full_version=$version-$config_name

# .version file
echo '#%Module' > $modulefiles/deal_II/.version
echo 'set ModulesVersion "'$full_version'"' >> $modulefiles/deal_II/.version

export modulefile=$modulefiles/deal_II/$full_version

function ForceMod() {
    mod=$1
    ver=$2
cat >> $modulefile <<EOF
if {[is-loaded $mod/$ver]} {
    # do nothing
} elseif {[is-loaded $mod]} {
    # swap
    puts stderr "WARNING: swapping from $mod to $mod/$ver"
    module swap $mod $mod/$ver
} else {
    puts stderr "WARNING: loading $mod/$ver"
    module load $mod/$ver
}
EOF
}

cat >> $modulefile <<EOF
# the prereqs and conflicts are tested before environment is changed,
# so they can be safely placed anywhere in a modulefile
conflict deal_II

setenv CRAYPE_LINK_TYPE dynamic

# need more recent MPICH to support parallel HDF5
EOF
ForceMod cray-mpich 7.3.2
cat >> $modulefile <<EOF
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
EOF
ForceMod cmake 3.5.2
ForceMod boost-serial 1.60
ForceMod cray-hdf5-parallel 1.10.0.1
ForceMod cray-tpsl-64 16.12.1
ForceMod cray-petsc-64 3.6.3.0

cat >> $modulefile <<EOF
proc ModulesHelp { } {
    puts stderr "deal_II"
    puts stderr {=====

What it is: A C++ software library supporting the creation of finite
element codes and an open community of users and developers.

Mission: To provide well-documented tools to build finite element
codes for a broad variety of PDEs, from laptops to supercomputers.

Vision: To create an open, inclusive, participatory community
providing users and developers with a state-of-the-art, comprehensive
software library that constitutes the go-to solution for all finite
element problems

Website: https://www.dealii.org/

Built on ARCHER with Gnu compilers as a shared library, in 64 bit
index mode with the bindings for PETSc, METIS, HDF5 and threading with
TBB.

Note this module sets CRAYPE_LINK_TYPE=dynamic to force use of shared
libraries.

Installed in April 2017 by Rupert Nash <r.nash@epcc.ed.ac.uk>
}
}

module-whatis "C++ software library supporting the creation of finite element codes"

EOF

echo "setenv DEAL_II_DIR $install_dir" >> $modulefile

if [[ $USER == 'cse' ]] ; then
    sudo -u packmods mkdir -p /home/y07/y07/packmods/modulefiles-archer/deal_II
    sudo -u packmods cp $modulefile /home/y07/y07/packmods/modulefiles-archer/deal_II
    # Uncomment the following line to update the default version
    sudo -u packmods cp $modulefiles/deal_II/.version /home/y07/y07/packmods/modulefiles-archer/deal_II/
fi

