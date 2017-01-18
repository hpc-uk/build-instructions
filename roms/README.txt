Instructions to install ROMS on Cirrus
Gavin Pringle <gavin@epcc.ed.ac.uk>
18 Jan 2017

The ROMS code can be downloaded from here: http://www.myroms.org

The following describe how to install ROMS on Cirrus.

Two lines within the makefile must be changed, namely MY_HEADER_DIR and FORT.

  MY_HEADER_DIR: all users must change the line 
MY_HEADER_DIR ?= /shared/model/ROMS/3.6/HPC_BENCHMARK/ne_atlantic/User/Include/
to something like
MY_HEADER_DIR ?= /lustre/home/z04/gavin/IrishMarine/ROMS/ne_atlantic/User/Include

FORT: all Cirrus users must change the line
        FORT ?= ifort
to
        FORT ?= mpif90

  Next, a new file called Linux-mpif90.mk was introduced into the
'Compilers' directory.  

  Finally, to make the executable oceanM, the user runs the following
commands:

module load mpt
module load intel-compilers-16
module load netcdf
make clean
make

  Finally, to submit the exectuable, I employed the following batch
script called job.pbs using the command 'qsub job.pbs'. 

 Please note
  a)change the string 'z04' to your budget
  b)select=1080 is two (number of hyperthreads per core, albeit unused) 
             times the number of cores in each node (36) 
             times the number of nodes required
  c)the code runs with 480 MPI tasks and uses 32 cores per node,
    where each node has 36 cores.

[gavin@cirrus-login0 ne_atlantic]$ cat job.pbs
#!/bin/bash 
#PBS -N roms
#PBS -l select=1080     
#PBS -l walltime=2:00:00       
#PBS -A z04
cd $PBS_O_WORKDIR
module load mpt
module load intel-compilers-16
module load hdf5-parallel
module load netcdf
export MPI_SHEPHERD=true
mpiexec_mpt -n 480 -ppn 32 ./oceanM Data/INPUT/data.in

