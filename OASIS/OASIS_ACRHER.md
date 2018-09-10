# Instructions for compiling OASIS for ARCHER

Follow the ```README``` in the top level directory.

## The ```setvar```-file:

````
# Needed to be able to load modules in batch jobs
. /etc/bash.bashrc.local 2> /dev/null

export UMDIR=/work/z01/z01/elena/OASIS_Benchamrk/HadGEM3-GC31_benchmark
export PATH=$UMDIR/code/fcm/bin:$UMDIR/bin:$PATH
export TARGET_MC=cce
````

## Setup correct modules

## Confgire and build
