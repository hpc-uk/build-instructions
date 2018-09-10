# Instructions for compiling OASIS for ARCHER

Follow the ```README``` in the top level directory. In the following only specific choices for the runs on ARCHER are shown, the complete content of the ```README``` is NOT reproduced here.

We are using ```HadGEM3-GC31_benchmark.tar```.

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

* Make sure the directories ```XIOS/extract/xios/tmp``` and ```XIOS/extract/xios/obj``` are empty before submitting the batch job. That's usually not the case, if the library gets re-compiled.
* In ```extract/xios/bld.cfg``` replace ```-I/${PWD}``` with the full PATH, it doesn't resolve otherwise.
* Set a temporary directory in the batch script`.
* Use striping on the temporary directory.

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

## Run HadGEN3-G31 coupled model

The batch script ```run/coupled_run.job```:

````#!/bin/bash
#PBS -N coupled_run
#PBS -l walltime=01:00:00
#PBS -l select=337
#PBS -q standard
#PBS -j n
#PBS -W umask=0022
#PBS -A z19-cse

cd /work/z01/z01/elena/OASIS_Benchamrk/HadGEM3-GC31_benchmark

. setvars

module load python-compute/2.7.6
module list

export PATH=$UMDIR/code/um/build-atmos/bin:$PATH

# INPUT/OUTPUT directories paths relative to run directory
export INPUT=../input
export OUTPUT=../output

export DATAM=$OUTPUT/History_Data

# Model executables
export ATMOS_EXEC=$UMDIR/code/um/build-atmos/bin/um-atmos.exe
export OCEAN_EXEC=$UMDIR/code/nemo/build-ocean/bin/nemo-cice.exe
export XIOS_EXEC=$UMDIR/bin/xios_server.exe

# Model executables processor decompositions
export UM_ATM_NPROCX=38
export UM_ATM_NPROCY=47
export FLUME_IOS_NPROC=6
export NEMO_IPROC=12
export NEMO_JPROC=18
export XIOS_NPROC=8

# Node usage information
export OMPTHR_ATM=4    # Number of OMP threads for atmos model
export OMPTHR_OCN=1    # Number of OMP threads for ocean model
export APPN=24         # Maximum number of processes per node for atmos model
export OPPN=24         # Maximum number of processes per node for ocean model
export XPPN=2          # Maximum number of processes per node for XIOS
export AHYPERTHREADS=1 # Number of hyperthreads for atmos model
export OHYPERTHREADS=1 # Number of hyperthreads for ocean model
export NUPN=2          # Number of numa nodes per node

# Calculate total number of processes used by each model
export UM_ATM_NPROC=$(( UM_ATM_NPROCX*UM_ATM_NPROCY + FLUME_IOS_NPROC ))
export NEMO_NPROC=$(( NEMO_IPROC*NEMO_JPROC ))

# Calculate total number of nodes used by each model
export ATMOS_NODES=$(( (UM_ATM_NPROC*OMPTHR_ATM + APPN*AHYPERTHREADS - 1)/(APPN*AHYPERTHREADS) ))
export OCEAN_NODES=$(( (NEMO_NPROC*OMPTHR_OCN + OPPN*OHYPERTHREADS - 1)/(OPPN*OHYPERTHREADS) ))
export XIOS_NODES=$(( (XIOS_NPROC + XPPN - 1)/XPPN ))

# Calculate number of processes per numa node used by each model
export ATMOS_PPNU=$(( (UM_ATM_NPROC + ATMOS_NODES*NUPN - 1)/(ATMOS_NODES*NUPN) ))
export OCEAN_PPNU=$(( (NEMO_NPROC + OCEAN_NODES*NUPN - 1)/(OCEAN_NODES*NUPN) ))
export XIOS_PPNU=$(( (XIOS_NPROC + XIOS_NODES*NUPN - 1)/(XIOS_NODES*NUPN) ))

echo ""
echo "       Unified Model:"
echo "       $UM_ATM_NPROC atmosphere model processes"
echo "       $FLUME_IOS_NPROC IO server processes"
echo "       $OMPTHR_ATM OpenMP threads per process"
echo "       $AHYPERTHREADS threads per core"
echo "       $ATMOS_PPNU processes per numa node"
echo "       $((NUPN*ATMOS_PPNU)) processes per node"
echo "       $ATMOS_NODES nodes"
echo ""
echo "       NEMO ocean Model:"
echo "       $NEMO_NPROC ocean model processes"
echo "       $OMPTHR_OCN OpenMP threads per process"
echo "       $OHYPERTHREADS threads per core"
echo "       $OCEAN_PPNU processes per numa node"
echo "       $((NUPN*OCEAN_PPNU)) processes per node"
echo "       $OCEAN_NODES nodes"
echo ""
echo "       XIOS IO server:"
echo "       $XIOS_NPROC IO server processes"
echo "       1 OpenMP thread per process"
echo "       1 thread per core"
echo "       $XIOS_PPNU processes per numa node"
echo "       $((NUPN*XIOS_PPNU)) processes per node"
echo "       $XIOS_NODES nodes"
echo ""
echo "       Total number of nodes used: $((ATMOS_NODES+OCEAN_NODES+XIOS_NODES))"
echo ""

# Command to launch coupled job
export ATMOS_LAUNCHER="aprun"
export LAUNCH_MPI_ATMOS="-ss -n $UM_ATM_NPROC -N $((NUPN*ATMOS_PPNU)) -S $ATMOS_PPNU -d $OMPTHR_ATM -j $AHYPERTHREADS env OMP_NUM_THREADS=$OMPTHR_ATM env HYPERTHREAD
S=$AHYPERTHREADS"
export LAUNCH_MPI_OCEAN="-ss -n $NEMO_NPROC   -N $((NUPN*OCEAN_PPNU)) -S $OCEAN_PPNU -d $OMPTHR_OCN -j $OHYPERTHREADS env OMP_NUM_THREADS=$OMPTHR_OCN env HYPERTHREAD
S=$OHYPERTHREADS"
export LAUNCH_MPI_XIOS=" -ss -n $XIOS_NPROC   -N $((NUPN*XIOS_PPNU))  -S $XIOS_PPNU  -d 1           -j 1              env OMP_NUM_THREADS=1           env HYPERTHREAD
S=1"

export COUPLED_PLATFORM=XC40
export COUPLER=oasis3_mct

export L_OCN_PASS_TRC=true
export NEMO_RESTARTFROMONE=0
export NEMO_NL=namelist_cfg
export NEMO_VERSION=304
export NEMO_START=$INPUT/aj997o_19600101_restart.nc
export NEMO_ICEBERGS_START=$INPUT/aj997o_icebergs_19600101_restart.nc
export TOP_START=

export CICE_GRID=$INPUT/CICE_grid_orca025ext_nemo_dist.nc
export CICE_KMT=$INPUT/CICE_kmt_eorca025_v2.2_nemo_dist.nc
export CICE_START=$INPUT/aj997i.restart.1960-01-01-00000.nc
export CICE_NPROC=$NEMO_NPROC

export RMP_DIR=$INPUT

# Printed output level, one of PrStatus_Min,PrStatus_Normal,PrStatus_Oper,PrStatus_Diag
export PRINT_STATUS=PrStatus_Diag
export STASHMASTER=$INPUT/ctldata/STASHmaster
export ENS_MEMBER=0
export SPECTRAL_FILE_DIR=$INPUT/ctldata/cmip6spectral1950
export HISTORY=$DATAM/atmos.xhist

# MPI/OMP variables
export MPICH_MAX_THREAD_SAFETY="multiple"
export MPICH_NEMESIS_ASYNC_PROGRESS="mc"
export MPICH_GNI_MAX_EAGER_MSG_SIZE="65536"
export MPICH_GNI_MAX_VSHORT_MSG_SIZE="8192"
export OMP_STACKSIZE="2G"

echo "Current path:"
echo $PWD
cd run

GC3-coupled
````

