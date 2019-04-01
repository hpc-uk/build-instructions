# . download.sh
. unpack.sh
. change.sh
. env.sh &> env.log
. modules.sh &> modules.log
module list >> modules.log 2>&1
. build_p4est.sh &> build_p4est.log
mkdir -p $build_dir
cd $build_dir
# cmake on a login node to get the correct configuration
. ../configure.sh &> ../configure.log &&
# make on a serial node because it takes hours to link (Lustre problem?)
qsub ../build.pbs
cd ..
# Once deal II is built, run the tests
#qsub test.pbs
# Once the tests pass (one fails - that is normal), create a module to make using the library easier
#package.sh
