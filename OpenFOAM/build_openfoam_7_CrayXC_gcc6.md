# Building OpenFOAM v7 on Cray XC30 (ARCHER) using GCC 6.3.0

## Download OpenFOAM and Third Party v7

The download options can be found at:

https://openfoam.org/download/7-source/

Extract both repositories and rename the directories to:

* `OpenFOAM-7`
* `ThirdParty-7`

## Modify the source for Cray XC

### OpenFOAM

Assuming you are in the `OpenFOAM-7` directory:

#### Modify `etc/bashrc`

Change 

```bash
export WM_ARCH_OPTION=64
```

to:

```bash
export WM_ARCH_OPTION=cray
```
Change

```bash
WM_MPLIB=SYSTEMOPENMPI
```

to

```bash
WM_MPLIB=CRAYMPICH
```

Replace these lines:

```bash
[ ${BASH_SOURCE:-$0} ] && \
export FOAM_INST_DIR=$(cd $(dirname ${BASH_SOURCE:-$0})/../.. && pwd -P) || \
export FOAM_INST_DIR=$HOME/$WM_PROJECT
```

with

```bash
export FOAM_INST_DIR=/work/path/to/dir/above_OpenFOAM-7
```

#### Modify `etc/config.sh/settings`

Add `cray` option to the architecture section (since we set `WM_ARCH_OPTION=cray`). The final fragment should
look like:

```bash
Linux)
    WM_ARCH=linux

    # Compiler specifics
    case `uname -m` in
        i686)
            export WM_ARCH_OPTION=32
            export WM_CC='gcc'
            export WM_CXX='g++'
            export WM_CFLAGS='-fPIC'
            export WM_CXXFLAGS='-fPIC -std=c++0x'
            export WM_LDFLAGS=
        ;;

    x86_64)
        case "$WM_ARCH_OPTION" in
        32)
            export WM_COMPILER_ARCH=64
            export WM_CC='gcc'
            export WM_CXX='g++'
            export WM_CFLAGS='-m32 -fPIC'
            export WM_CXXFLAGS='-m32 -fPIC -std=c++0x'
            export WM_LDFLAGS='-m32'
            ;;
        64)
            WM_ARCH=linux64
            export WM_COMPILER_LIB_ARCH=64
            export WM_CC='gcc'
            export WM_CXX='g++'
            export WM_CFLAGS='-m64 -fPIC'
            export WM_CXXFLAGS='-m64 -fPIC -std=c++0x'
            export WM_LDFLAGS='-m64'
            ;;
        cray)
            WM_ARCH=crayxc
            export WM_COMPILER_LIB_ARCH=64
            export WM_CC='cc'
            export WM_CXX='CC'
            export WM_CFLAGS='-fPIC'
            export WM_CXXFLAGS='-fPIC'
            ;;
        *)
```

#### Modify `etc/config.sh/mpi`

Add `CRAYMPICH` option (since we set `WM_MPLIB=CRAYMPICH` ). Final fragment should look like:

```bash
case "$WM_MPLIB" in
SYSTEMOPENMPI)
    # Use the system installed openmpi, get library directory via mpicc
    export FOAM_MPI=openmpi-system

    # Undefine OPAL_PREFIX if set to one of the paths on foamOldDirs
    if [ -z "$($foamClean "$OPAL_PREFIX" "$foamOldDirs")" ]
    then
        unset OPAL_PREFIX
    fi

    libDir=`mpicc --showme:link | sed -e 's/.*-L\([^ ]*\).*/\1/'`

    # Bit of a hack: strip off 'lib' and hope this is the path to openmpi
    # include files and libraries.
    export MPI_ARCH_PATH="${libDir%/*}"

    _foamAddLib     $libDir
    unset libDir
    ;;

CRAYMPICH)
    export FOAM_MPI=mpich2
    export MPI_ARCH_PATH=$MPICH_DIR
    ;;
```

#### Create and modify `wmake/rules`

Create `crayxcGcc` folder under `wmake` (since we set `WM_ARCH=crayxc` in `settings` and
`WM_COMPILER=Gcc` in `bashrc`) by copying `linux64Gcc` folder:

```bash
cp -r  wmake/rules/linux64Gcc wmake/rules/crayxcGcc
```

Modify `wmake/rules/crayxcGcc/c` to:

```bash
SUFFIXES += .c

cWARN        = -Wall

cc          = cc -m64

include $(DEFAULT_RULES)/c$(WM_COMPILE_OPTION)

cFLAGS      = $(GFLAGS) $(cWARN) $(cOPT) $(cDBUG) $(LIB_HEADER_DIRS) -fPIC

ctoo        = $(WM_SCHEDULER) $(cc) $(cFLAGS) -c $< -o $@

LINK_LIBS   = $(cDBUG)

LINKLIBSO   = $(cc) -shared
LINKEXE     = $(cc) -Xlinker --add-needed -Xlinker -z -Xlinker nodefs
```

Modify `wmake/rules/crayxcGcc/c++` to:

```bash
SUFFIXES += .C

c++WARN     = -Wall -Wextra -Wold-style-cast -Wnon-virtual-dtor -Wno-unused-parameter -Wno-invalid-offsetof

# Suppress some warnings for flex++ and CGAL
c++LESSWARN = -Wno-old-style-cast -Wno-unused-local-typedefs -Wno-array-bounds

CC          = CC -std=c++11 -m64

include $(DEFAULT_RULES)/c++$(WM_COMPILE_OPTION)

ptFLAGS     = -DNoRepository -ftemplate-depth-100

c++FLAGS    = $(GFLAGS) $(c++WARN) $(c++OPT) $(c++DBUG) $(ptFLAGS) $(LIB_HEADER_DIRS) -fPIC

Ctoo        = $(WM_SCHEDULER) $(CC) $(c++FLAGS) -c $< -o $@
cxxtoo      = $(Ctoo)
cctoo       = $(Ctoo)
cpptoo      = $(Ctoo)

LINK_LIBS   = $(c++DBUG)

LINKLIBSO   = $(CC) $(c++FLAGS) -shared -Xlinker --add-needed -Xlinker --no-as-needed
LINKEXE     = $(CC) $(c++FLAGS) -Xlinker --add-needed -Xlinker --no-as-needed
```

Create `wmake/rules/crayxcGcc/mplibCRAYMPICH` file containing:

```bash
PFLAGS = -DMPICH_SKIP_MPICXX
PINC =
PLIBS =
```

### ThirdParty

Assuming you are in the `ThirdParty-7` directory:

#### Modify scotch build

Change `etc/wmakeFiles/scotch/Makefile.inc.i686_pc_linux2.shlib-OpenFOAM` to:

```bash
EXE =
LIB = .so
OBJ = .o
MAKE = make
AR = cc -v
ARFLAGS = -shared -o
CAT = cat
CCS = cc
CCP = cc
CCD = cc
CFLAGS = -O3 -DCOMMON_FILE_COMPRESS_GZ -DCOMMON_RANDOM_FIXED_SEED -DSCOTCH_RENAME -Drestrict=__restrict
CLIBFLAGS = -shared -fPIC
LDFLAGS = -lz -lm -lrt
CP = cp
LEX = flex -Pscotchyy -olex.yy.c
LN = ln
MKDIR = mkdir
MV = mv
RANLIB = echo
YACC = bison -pscotchyy -y -b y
```

## Compile OpenFOAM

### Setup compile environment

Load the required modules

```bash
module swap PrgEnv-cray PrgEnv-gnu
module add cmake
module add boost
```

and set the required environment variables

```bash
export CRAYPE_LINK_TYPE=dynamic
export CRAY_ADD_RPATH=yes
```

### Build OpenFOAM

Build with:

```bash
cd OpenFOAM-7
./Allwmake
```

Note that the compile takes a long time (9h+) and so we usually use a batch job running
on the ARCHER compile nodes (`ppn` queue). The compile script we use is:

```bash
#!/bin/bash --login
#
#PBS -N FOAMcompile
#PBS -l select=1
#PBS -l walltime=24:0:0
#PBS -A z19-cse

cd $PBS_O_WORKDIR

module swap PrgEnv-cray PrgEnv-gnu
module add cmake
module add boost
module list

export CRAYPE_LINK_TYPE=dynamic
export CRAY_ADD_RPATH=yes

source etc/bashrc

./Allwmake > openfoam-build.log 2> openfoam-err.log
```

## Testing OpenFOAM

We use the following script to minimally test that the OpenFOAM compilation has produced
working binaries. This job is submitted from the directory containing the OpenFOAM-6 and
ThirdParth-6 directories.

```bash
#!/bin/bash --login
#
#PBS -N OpenFOAMTest
#PBS -l select=4
#PBS -l walltime=00:20:00
#PBS -A z19-cse

cd $PBS_O_WORKDIR

# Submit from the directory containing OpenFOAM-6 and
# ThirdParty-7

# These variables have standard OpenFOAM names but are only used in
# this script.
WM_PROJECT=OpenFOAM
WM_PROJECT_VERSION=7

source $WM_PROJECT-$WM_PROJECT_VERSION/etc/bashrc

# Full test of icoFoam cavity
mkdir -p test-icoFoam-${WM_PROJECT_VERSION}
cp -pr $FOAM_TUTORIALS/incompressible/icoFoam/cavity/cavity test-icoFoam-${WM_PROJECT_VERSION}
cd test-icoFoam-${WM_PROJECT_VERSION}/cavity
aprun -n 1 blockMesh > test-blockMesh.log 2>&1
cp $PBS_O_WORKDIR/decomposeParDict system
aprun -n 1 decomposePar > test-decomposePar.log 2>&1
aprun -n 16 -N 4 -S 2 icoFoam -parallel > test-icoFoam.log 2>&1
```

The `decomposeParDict` file needed for this test is placed in the same directory and
contains:

```
/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  2.1.1                                 |
|   \\  /    A nd           | Web:      www.OpenFOAM.org                      |
|    \\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
    version     2.0;
    format      ascii;
    class       dictionary;
    location    "system";
    object      decomposeParDict;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
 
numberOfSubdomains 16;
 
method          simple;
 
simpleCoeffs
{
    n               ( 4 4 1 );
    delta           0.001;
}
 
distributed     no;
 
roots           ( );
 
 
// ************************************************************************* //
```
