#!/bin/bash
# deal.II configuration variables

export version=8.5.1
export config_name=gnu-32-trilinos

export root_dir=$PWD
export src_dir=$root_dir/dealii-$version
export build_dir=$root_dir/build
export install_dir=/work/A99/A99/username/deal_II/$version-$config_name
export p4est_install_dir=$install_dir/p4est

export F77=ftn
export CC=cc
export FC=ftn
export CXX=CC

export CRAYPE_LINK_TYPE=dynamic
