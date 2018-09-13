# Instructions for compiling OASIS for ARCHER

Follow the ```README``` in the top level directory. In the following only specific choices for the runs on ARCHER are shown, the complete content of the ```README``` is NOT reproduced here.

We are using ```HadGEM3-GC31_benchmark.tar```. Note that
* XIOS needs to call the oasis libraries
* UM calls oasis, but not XIOS
* NEMO calls both oasis + XIOS

## The ```setvar```-file:

````
# Needed to be able to load modules in batch jobs
. /etc/bash.bashrc.local 2> /dev/null

export UMDIR=/work/z01/z01/elena/OASIS_Benchamrk/HadGEM3-GC31_benchmark
export PATH=$UMDIR/code/fcm/bin:$UMDIR/bin:$PATH
export TARGET_MC=cce
````

## Build the gcom library

Edit ```compile_gcom.job``` to the appropriate directory:

````
#!/bin/ksh
#
#PBS -N gcom_compile
#PBS -l select=serial=true:ncpus=4
#PBS -l walltime=00:20:00
#PBS -j oe
#PBS -W umask=0022
#PBS -A z19-cse

cd /work/z01/z01/elena/OASIS_Benchamrk/HadGEM3-GC31_benchmark

. setvars

module list

cd code/gcom6.1

fcm make --new -v -j 4 -f fcm-make2.cfg || exit

cp build/lib/libgcom.a $UMDIR/lib
cp build/include/*.mod $UMDIR/include
````
And submit.

## Build oasis library

Edit ```compile_oasis.job``` to cd to the appropriate directory

````
#!/bin/ksh
#
#PBS -N oasis_compile
#PBS -l select=serial=true:ncpus=1
#PBS -l walltime=00:20:00
#PBS -j oe
#PBS -W umask=0022
#PBS -A z19-cse

cd /work/z01/z01/elena/OASIS_Benchamrk/HadGEM3-GC31_benchmark

. setvars

module load cray-hdf5-parallel/1.8.13
module load cray-netcdf-hdf5parallel/4.3.2
module list

OASIS_SRC_DIR=$UMDIR/code/oasis3-mct/extract/oa3mct
OASIS_MAKE_FILE_NAME="make.cray_xc40_mo"

cd $OASIS_SRC_DIR/util/make_dir

cat << EOF > make.inc
PRISMHOME = $OASIS_SRC_DIR
include \$(PRISMHOME)/util/make_dir/$OASIS_MAKE_FILE_NAME
EOF

make -f TopMakefileOasis3 || exit

cd ../../crayxc40
cp lib/* $UMDIR/lib
cp build/lib/psmile.MPI1/*.mod $UMDIR/include
````
and submit.

## Build XIOS library/executable

Edit ```compile_xios.job```:

````
#!/bin/ksh
#
#PBS -N xios_compile
#PBS -l select=serial=true:ncpus=4
#PBS -l walltime=06:00:00
#PBS -j oe
#PBS -W umask=0022
#PBS -A z19-cse

cd /work/z01/z01/elena/OASIS_Benchamrk/HadGEM3-GC31_benchmark

. setvars

module load cray-hdf5-parallel/1.8.13
module load cray-netcdf-hdf5parallel/4.3.2
module list

SYSTEM_NAME="UKMO_CRAY_XC40"
NCPUS=4

cd code/XIOS
export TMPDIR=/work/z01/z01/elena/OASIS/HadGEM3-GC31_benchmark/tmp
lfs setstripe -c 1 /work/z01/z01/elena/OASIS/HadGEM3-GC31_benchmark/tmp/

. ./mk_arch_files.sh $SYSTEM_NAME
cp arch-$SYSTEM_NAME.* extract/xios/arch

cd extract/xios

./make_xios --arch $SYSTEM_NAME --use_oasis oasis3_mct  --job $NCPUS || exit

cp lib/* $UMDIR/lib
cp inc/*.mod $UMDIR/include
cp bin/xios_server.exe $UMDIR/bin
````

* If you want to start from scratch, make sure the directories ```XIOS/extract/xios/tmp``` and  ```XIOS/extract/xios/obj``` are empty before submitting the batch job. That's usually not the case, if the library gets re-compiled.
* In ```extract/xios/bld.cfg``` replace ```-I/${PWD}``` with the full PATH, it doesn't resolve otherwise.
* Set a temporary directory in the batch script`.
* Use striping on the temporary directory.
* It might be necessary to specify a longer walltime.

## Build nemo executable

Edit ```compile_nemo.job```:

````
#!/bin/ksh
#
#PBS -N nemo_compile
#PBS -l select=serial=true:ncpus=4
#PBS -l walltime=01:00:00
#PBS -j oe
#PBS -W umask=0022
#PBS -A z19-cse

cd /work/z01/z01/elena/OASIS_Benchamrk/HadGEM3-GC31_benchmark

. setvars

module load cray-hdf5-parallel/1.8.13
module load cray-netcdf-hdf5parallel/4.3.2
module list

# Executable needs recompiling if processor decomposition changes
export NEMO_IPROC=12
export NEMO_JPROC=18

export CICE_COL=1440
export CICE_ROW=1205
export CICE_BLKX=$(( (CICE_COL + NEMO_IPROC - 1)/NEMO_IPROC ))
export CICE_BLKY=$(( (CICE_ROW + NEMO_JPROC - 1)/NEMO_JPROC ))
export CICE_MAXBK=1

cd code/nemo

fcm make --new -v -j 4 -f fcm-make2.cfg || exit

cd build-ocean/bin
cp nemo-cice.exe nemo-cice-${NEMO_IPROC}x${NEMO_JPROC}.exe
````
## Build um executable
Edit ```compile_um.job```:

````
#!/bin/ksh
#
#PBS -N um_compile
#PBS -l select=serial=true:ncpus=4
#PBS -l walltime=06:00:00
#PBS -j oe
#PBS -W umask=0022
#PBS -A z19-cse

cd /work/z01/z01/elena/OASIS_Benchamrk/HadGEM3-GC31_benchmark

. setvars

module load cray-hdf5-parallel/1.8.13
module load cray-netcdf-hdf5parallel/4.3.2
module list

cd code/um

fcm make --new -v -j 4 -f fcm-make2.cfg
````




