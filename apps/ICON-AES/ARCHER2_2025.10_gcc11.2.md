# ICON Model Build Instructions on ARCHER2

These instructions describe how to build `libfyaml` and the `ICON model (release-2025.10-public)` on ARCHER2 using the GNU Programming Environment and
GCC 11.2.0.

---

## 1. Environment

These instructions assume a standard ARCHER2 environment.

### 1.1 Modules

```bash
module load PrgEnv-gnu
module load gcc/11.2.0
module load cray-python
module load cray-hdf5 cray-netcdf libxml2
```

### 1.2 Working directory

```bash
cd ${HOME/home/work}
```

All software will be built in this directory tree.

### 1.3 Python environment

Creating a python virtual environment for bundled packages with ICON model to be
available during runtime.

```bash
python -m venv --system-site-packages venv
source venv/bin/activate
pip install cython==3.2.4 jinja2
```

---

## 2. Build libfyaml (v0.9.3)

ICON requires `libfyaml`, which is not provided as a system module on ARCHER2.

### 2.1 Download and unpack

```bash
wget https://github.com/pantoniou/libfyaml/releases/download/v0.9.3/libfyaml-0.9.3.tar.gz
tar xzvf libfyaml-0.9.3.tar.gz
```

### 2.2 Configure and build

```bash
cd ${HOME/home/work}/libfyaml-0.9.3

export LIBFYAML_ROOT=${HOME/home/work}/libfyaml-0.9.3
mkdir ${LIBFYAML_ROOT}/build

autoreconf -f -i

${LIBFYAML_ROOT}/configure \
  CC=cc CXX=CC FC=ftn \
  --prefix=${LIBFYAML_ROOT}/build

make -j8
make install
```

This installs libfyaml under:

```
${LIBFYAML_ROOT}/build
```

---

## 3. Build ICON Model (release-2025.10-public)

### 3.1 Obtain source code

```bash
cd ${HOME/home/work}

git clone -b release-2025.10-public --recursive \
  https://gitlab.dkrz.de/icon/icon-model.git
```

### 3.2 Configure and build

```bash
cd ${HOME/home/work}/icon-model

export ICON_MODEL_ROOT=${HOME/home/work}/icon-model
mkdir ${ICON_MODEL_ROOT}/build

autoreconf -f -i
```

The following include paths are required for HDF5, NetCDF, MPI, libxml2, and libfyaml:

```bash
export ICON_INCLUDES="-I${HDF5_DIR}/include/ \
  -I${NETCDF_DIR}/include/ \
  -I${CRAY_MPICH_DIR}/include/ \
  -I${LIBXML2_DIR}/include/ \
  -I${LIBFYAML_ROOT}/build/include/"
```

Configure step

```bash
${ICON_MODEL_ROOT}/configure \
  CC=cc CXX=CC FC=ftn F77=ftn \
  LDFLAGS="-L${HDF5_DIR}/lib/ \
    -L${NETCDF_DIR}/lib/ \
    -L${CRAY_MPICH_DIR}/lib/ \
    -L${LIBXML2_DIR}/lib/ \
    -L${LIBFYAML_ROOT}/build/lib/ \
    -Wl,-rpath,${LIBFYAML_ROOT}/build/lib" \
  LIBS='-lnetcdff -lnetcdf -lhdf5 -lmpifort -lmpi -lxml2 -lfyaml' \
  FCFLAGS="${ICON_INCLUDES} -cpp -std=gnu -fmodule-private -fimplicit-none -fmax-identifier-length=63 \
    -ffree-line-length-132 -O3 -ffast-math -D__LOOP_EXCHANGE -fallow-argument-mismatch" \
  CFLAGS="${ICON_INCLUDES} -std=gnu99 -O2 -DHAVE_LIBNETCDF -DHAVE_NETCDF4 -D__XE6__ -DgFortran" \
  CPPFLAGS="${ICON_INCLUDES}" \
  MPI_LAUNCH="srun" \
  MPIROOT="${CRAY_MPICH_DIR}" \
  --enable-bundled-python \
  --enable-openmp \
  --disable-mpi-checks \
  --prefix="${ICON_MODEL_ROOT}/build"
```

Build and install ICON

```bash
make -j8
make install
```

The ICON executables and supporting files will be installed under:

```
${ICON_MODEL_ROOT}/build
```

---

## 4. Notes

- These instructions assume the compiler wrappers (`cc`, `ftn` and `CC`) are
  used throughout.
- The build enables `OpenMP` support.
