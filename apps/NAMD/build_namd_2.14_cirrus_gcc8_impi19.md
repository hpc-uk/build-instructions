Instructions for compiling NAMD 2.14 for Cirrus (CPU and GPU)
=============================================================

These instructions are for compiling NAMD 2.14 for Cirrus CPU (SGI ICE XA, Broadwell) and for Cirrus GPU (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
NAMD_LABEL=namd
NAMD_LABEL_CAPS=`echo ${NAMD_LABEL} | tr [a-z] [A-Z]`
NAMD_VERSION=2.14
NAMD_ROOT=${PRFX}/${NAMD_LABEL}
NAMD_NAME=${NAMD_LABEL}-${NAMD_VERSION}
NAMD_ARCHIVE=${NAMD_LABEL_CAPS}_${NAMD_VERSION}_Source
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Download and unpack NAMD
------------------------

Next, download the NAMD 2.14 source from: http://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=NAMD
and transfer to the Cirrus system at the path indicated by `$NAMD_ROOT/arc`.

Unpack the source.

```bash
cd ${NAMD_ROOT} 
cp ${NAMD_ROOT}/arc/${NAMD_ARCHIVE}.tar.gz ${NAMD_ROOT}/
tar -xzf ${NAMD_ARCHIVE}.tar.gz
rm ${NAMD_ARCHIVE}.tar.gz
mv ${NAMD_ARCHIVE} ${NAMD_NAME}
```


Load the GCC, MPI and FFTW modules
----------------------------------

```bash
GNU_VERSION=8.2.0
IMPI_VERSION=19.0.0.117
FFTW_VERSION=3.3.9

GNU_VERSION_MAJOR=`echo ${GNU_VERSION} | cut -d'.' -f1`
IMPI_VERSION_MAJOR=`echo ${IMPI_VERSION} | cut -d'.' -f1`

module load gcc/${GNU_VERSION}
module load intel-mpi-${IMPI_VERSION_MAJOR}/${IMPI_VERSION}
module load fftw/${FFTW_VERSION}-impi${IMPI_VERSION_MAJOR}-gcc${GNU_VERSION_MAJOR}
```


Download, build and install TCL
-------------------------------

```bash
TCL_LABEL=tcl
TCL_VERSION=8.5.9
TCL_ROOT=${NAMD_ROOT}/${TCL_LABEL}
TCL_NAME=${TCL_LABEL}-${TCL_VERSION}
TCL_ARCHIVE=${TCL_LABEL}${TCL_VERSION}-src
TCL_BASEDIR=${TCL_ROOT}/${TCL_VERSION}

mkdir -p ${TCL_ROOT}
cd ${TCL_ROOT}

wget http://www.ks.uiuc.edu/Research/${NAMD_LABEL}/libraries/${TCL_ARCHIVE}.tar.gz
tar -xzf ${TCL_ARCHIVE}.tar.gz
rm ${TCL_ARCHIVE}.tar.gz
mv ${TCL_LABEL}${TCL_VERSION} ${TCL_NAME}

cd ${TCL_NAME}/unix
export FC=gfortran CC=gcc CXX=g++

./configure --enable-threads --prefix=${TCL_ROOT}/${TCL_VERSION}
make
make test
make install
```


Build and install various flavours of Charm++ suitable for CPU and GPU
----------------------------------------------------------------------

```bash
cd ${NAMD_ROOT}/${NAMD_NAME}

NAMD_CHARM_NAME=charm-6.10.2
tar -xf ${NAMD_CHARM_NAME}.tar

cd ${NAMD_CHARM_NAME}

# MPI (with and without SMP), CPU
./build charm++ mpi-linux-x86_64 gcc smp --incdir=${I_MPI_ROOT}/intel64/include --libdir=${I_MPI_ROOT}/intel64/lib --libdir=${I_MPI_ROOT}/intel64/lib/release --libdir=${I_MPI_ROOT}/intel64/libfabric/lib --with-production
./build charm++ mpi-linux-x86_64 gcc --incdir=${I_MPI_ROOT}/intel64/include --libdir=${I_MPI_ROOT}/intel64/lib --libdir=${I_MPI_ROOT}/intel64/lib/release --libdir=${I_MPI_ROOT}/intel64/libfabric/lib --with-production

# verbs (with SMP), GPU
./build charm++ verbs-linux-x86_64 gcc smp --with-production
```


Build and install NAMD for each Charm++ flavour
-----------------------------------------------

```bash
NV_HPCSDK_ROOT=/lustre/sw/nvidia/hpcsdk-212/Linux_x86_64/21.2

FFTW_CPU_OPTIONS="--with-fftw3 --fftw-prefix /lustre/sw/fftw/3.3.9-impi19-gcc8"
FFTW_GPU_OPTIONS="--with-fftw3 --fftw-prefix ${NV_HPCSDK_ROOT}/math_libs/11.2/targets/x86_64-linux"

CUDA_CPU_OPTIONS="--without-cuda"
CUDA_GPU_OPTIONS="--with-cuda --cuda-prefix ${NV_HPCSDK_ROOT}/cuda/11.2"

declare -a FFTW_OPTIONS=("${FFTW_CPU_OPTIONS}" "${FFTW_CPU_OPTIONS}" "${FFTW_GPU_OPTIONS}")
declare -a CUDA_OPTIONS=("${CUDA_CPU_OPTIONS}" "${CUDA_CPU_OPTIONS}" "${CUDA_GPU_OPTIONS}")

declare -a NAMD_VERSION_LABEL=("${NAMD_VERSION}" "${NAMD_VERSION}-nosmp" "${NAMD_VERSION}-gpu")

declare -a CHARM_FLAVOUR=("mpi-linux-x86_64-smp-gcc" "mpi-linux-x86_64-gcc" "verbs-linux-x86_64-smp-gcc")
NUM_CHARM_FLAVOURS=${#CHARM_FLAVOUR[@]}

sed -i "s:CUDALIB=-L\$(CUDADIR)/lib64 -lcufft_static -lculibos -lcudart_static -lrt:CUDALIB=-L\$(CUDADIR)/lib64 -lcufft -lculibos -lcudart -lrt:g" \
    ${NAMD_ROOT}/${NAMD_NAME}/arch/Linux-x86_64.cuda

for (( i=0; i<${NUM_CHARM_FLAVOURS}; i++ )); do
  cd ${NAMD_ROOT}/${NAMD_NAME}

  ./config Linux-x86_64-g++ --charm-arch ${CHARM_FLAVOUR[$i]} \
      --with-tcl --tcl-prefix ${TCL_BASEDIR} \
      ${FFTW_OPTIONS[$i]} ${CUDA_OPTIONS[$i]}

  cd ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
  gmake

  NAMD_INSTALL_PATH=${NAMD_ROOT}/${NAMD_VERSION_LABEL[$i]}
  rm -rf ${NAMD_INSTALL_PATH}
  mkdir -p ${NAMD_INSTALL_PATH}
  cd ${NAMD_INSTALL_PATH}

  cp -r ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++ bin
  cd bin
  rm .rootdir
  ln -s ${NAMD_ROOT}/${NAMD_NAME} .rootdir

  rm -rf ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
done
```

The `namd2` executables exist in the `${NAMD_ROOT}/${NAMD_VERSION_LABEL[$i]}/bin` directories.