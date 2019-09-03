#!/bin/bash

# Use the system gcc, since glibc is so close to the system.
module unload gcc

glibc_dir=$PWD
rm -rf bin etc include lib libexec sbin share STDIN.*
(
    cd glibc-2.16.0
    mkdir build
    (
	cd build
	../configure --prefix=$glibc_dir --enable-kernel=2.6.5 &> configure.log
	make &> make.log
	make install &> install.log
    )
)

# I'm not sure if the ld.so.cache generated on the login node will be
# correct or complete for use on the MOM node (which is the same as
# that used on the compute node).
$glibc_dir/sbin/ldconfig -f /etc/ld.so.conf -C $glibc_dir/etc/login.ld.so.cache
qsub -W block=true -l select=1,walltime=00:20:00 -A z19-cse -q short -- /bin/bash -c "$glibc_dir/sbin/ldconfig -f /etc/ld.so.conf -C $glibc_dir/etc/mom.ld.so.cache"
# Copy into $glibc_dir/etc/ld.so.cache, the usual place.
#cp -p $glibc_dir/etc/login.ld.so.cache $glibc_dir/etc/ld.so.cache
cp -p $glibc_dir/etc/mom.ld.so.cache $glibc_dir/etc/ld.so.cache
