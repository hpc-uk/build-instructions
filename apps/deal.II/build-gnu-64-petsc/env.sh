# deal.II configuration variables
version=8.4.1
config_name=gnu-petsc-64

root_dir=/home/y07/y07/cse/deal_II/$version
src_dir=$root_dir/dealii-$version
build_dir=$root_dir/build-$config_name
install_dir=$WORK/deal_II/$version-$config_name

export CRAYPE_LINK_TYPE=dynamic
