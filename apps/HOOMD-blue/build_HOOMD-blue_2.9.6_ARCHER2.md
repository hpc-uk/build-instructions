# Building HOOMD-blue 2.9.6 for ARCHER2

These instructions describe how to build [HOOMD-blue]() 2.9.6 for use
on [ARCHER2]().

The HOOMD-blue developers recommend building the software within a Docker 
container and then using the resultant Docker contianer image to generate a
Singularity container image for use on HPC systems. To do this you will need 
an installation of Docker on a system where you have root/administrator access.
The Docker installation needs to have access to at least 8 GB of memory in order
to successfully build the Docker container image.

## Download required files for build process

You need to download the following files from the HOOMD-blue developers to be
able to build the container image:

* [requirements.txt]
* [requirements-source.txt]
* [requirements-mpi.txt]

These should all be placed in the same directory which we will refer to as `$BUILD_ROOT`
through the remainder of these instructions. 

## Create the Dockerfile

You should create a Dockerfile in the `$BUILD_ROOT` directory with the following contents

```
FROM ubuntu:20.04

ARG GIT_SHA
ARG GIT_BRANCH
ARG CONFIGURATION
ARG TAG

ENV GLOTZERLAB_SOFTWARE_GIT_SHA=${GIT_SHA} \
    GLOTZERLAB_SOFTWARE_GIT_BRANCH=${GIT_BRANCH} \
    GLOTZERLAB_SOFTWARE_CONFIGURATION=${CONFIGURATION} \
    GLOTZERLAB_SOFTWARE_TAG=${TAG}

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  clang-9 \
  cmake \
  curl \
  ffmpeg \
  git \
  hwloc \
  libboost-dev \
  libcereal-dev \
  libclang-9-dev \
  libclang-cpp9 \
  libedit-dev \
  libtbb-dev \
  libeigen3-dev \
  libevent-dev \
  libhwloc-dev \
  libqhull-dev \
  libsqlite3-dev \
  llvm-9-dev \
  pybind11-dev \
  python3.9 \
  python3.9-dev \
  python3.9-venv \
  python3.9-distutils \
  zlib1g-dev \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*


# put clang on the path
ENV PATH=$PATH:/usr/lib/llvm-9/bin

# Link python3.9 to python3 in user path
RUN rm -f /usr/bin/python3 && ln -s "$(which python3.9)" /usr/bin/python3

# prevent python from loading packages from outside the container
# default empty pythonpath
ENV PYTHONPATH=/ignore/pythonpath
# disable user site directories (https://docs.python.org/3/library/site.html#module-site)
RUN sed -i -e 's/ENABLE_USER_SITE = None/ENABLE_USER_SITE = False/g' `python3 -c 'import site; print(site.__file__)'`

# mount points for filesystems on clusters
RUN mkdir -p /nfs \
    mkdir -p /oasis \
    mkdir -p /scratch \
    mkdir -p /work \
    mkdir -p /projects \
    mkdir -p /home1

# make a python virtual environment to install packages into
# many pip installable packages clobber scripts that ubuntu provides in bin/ and result
# in broken packages
ENV PATH=/opt/glotzerlab/bin:$PATH \
    CMAKE_PREFIX_PATH=/opt/glotzerlab/bin \
    LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}

RUN python3 -m venv /opt/glotzerlab \
    && /opt/glotzerlab/bin/python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Install the requirements files
COPY requirements*.txt /

RUN apt-get update && apt-get install -y --no-install-recommends \
  byacc \
  flex \
  libfabric-dev \
  libibverbs-dev \
  && rm -rf /var/lib/apt/lists/*

RUN curl -sSLO http://www.mpich.org/static/downloads/3.4.2/mpich-3.4.2.tar.gz \
   && tar -xzf mpich-3.4.2.tar.gz -C /root \
   && cd /root/mpich-3.4.2 \
   && ./configure --prefix=/usr --with-device=ch3:nemesis:ofi --disable-fortran \
   && make install \
   && rm -rf /root/mpich-3.4.2 \
   && rm /mpich-3.4.2.tar.gz

RUN curl -sSLO http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-5.4.1.tar.gz \
   && tar -xzf osu-micro-benchmarks-5.4.1.tar.gz -C /root \
   && cd /root/osu-micro-benchmarks-5.4.1 \
   && ./configure --prefix=/opt/osu-micro-benchmarks CC=`which mpicc` CXX=`which mpicxx` \
   && cd mpi \
   && make install \
   && rm -rf /root/osu-micro-benchmarks-5.4.1 \
   && rm /osu-micro-benchmarks-5.4.1.tar.gz

RUN /opt/glotzerlab/bin/python3 -m pip install --no-cache-dir --no-binary mpi4py -r requirements-mpi.txt

RUN export CFLAGS="-march=znver2 -mmmx -msse -msse2 -msse3 -mssse3 -msse4a -mcx16 -msahf -mmovbe -maes -msha -mpclmul -mpopcnt -mabm -mfma -mbmi -mbmi2 -mwbnoinvd -mavx -mavx2 -msse4.2 -msse4.1 -mlzcnt -mrdrnd -mf16c -mfsgsbase -mrdseed -mprfchw -madx -mfxsr -mxsave -mxsaveopt -mclflushopt -mxsavec -mxsaves -mclwb -mmwaitx -mclzero -mrdpid --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=512 -mtune=znver2" CXXFLAGS="-march=znver2 -mmmx -msse -msse2 -msse3 -mssse3 -msse4a -mcx16 -msahf -mmovbe -maes -msha -mpclmul -mpopcnt -mabm -mfma -mbmi -mbmi2 -mwbnoinvd -mavx -mavx2 -msse4.2 -msse4.1 -mlzcnt -mrdrnd -mf16c -mfsgsbase -mrdseed -mprfchw -madx -mfxsr -mxsave -mxsaveopt -mclflushopt -mxsavec -mxsaves -mclwb -mmwaitx -mclzero -mrdpid --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=512 -mtune=znver2" \
    && python3 -m pip install -r requirements-source.txt \
    && python3 -m pip cache purge

# build select packages from source with machine specific flags
RUN export CFLAGS="-march=znver2 -mmmx -msse -msse2 -msse3 -mssse3 -msse4a -mcx16 -msahf -mmovbe -maes -msha -mpclmul -mpopcnt -mabm -mfma -mbmi -mbmi2 -mwbnoinvd -mavx -mavx2 -msse4.2 -msse4.1 -mlzcnt -mrdrnd -mf16c -mfsgsbase -mrdseed -mprfchw -madx -mfxsr -mxsave -mxsaveopt -mclflushopt -mxsavec -mxsaves -mclwb -mmwaitx -mclzero -mrdpid --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=512 -mtune=znver2" CXXFLAGS="-march=znver2 -mmmx -msse -msse2 -msse3 -mssse3 -msse4a -mcx16 -msahf -mmovbe -maes -msha -mpclmul -mpopcnt -mabm -mfma -mbmi -mbmi2 -mwbnoinvd -mavx -mavx2 -msse4.2 -msse4.1 -mlzcnt -mrdrnd -mf16c -mfsgsbase -mrdseed -mprfchw -madx -mfxsr -mxsave -mxsaveopt -mclflushopt -mxsavec -mxsaves -mclwb -mmwaitx -mclzero -mrdpid --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=512 -mtune=znver2" \
    && python3 -m pip install --no-build-isolation --no-binary freud-analysis,gsd -r requirements.txt \
    && python3 -m pip cache purge


RUN git clone --recursive --branch v2.9.6 --depth 1 https://github.com/glotzerlab/hoomd-blue hoomd \
    && cd hoomd \
    && mkdir -p build \
    && cd build \
    && export CFLAGS="-march=znver2 -mmmx -msse -msse2 -msse3 -mssse3 -msse4a -mcx16 -msahf -mmovbe -maes -msha -mpclmul -mpopcnt -mabm -mfma -mbmi -mbmi2 -mwbnoinvd -mavx -mavx2 -msse4.2 -msse4.1 -mlzcnt -mrdrnd -mf16c -mfsgsbase -mrdseed -mprfchw -madx -mfxsr -mxsave -mxsaveopt -mclflushopt -mxsavec -mxsaves -mclwb -mmwaitx -mclzero -mrdpid --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=512 -mtune=znver2" CXXFLAGS="-march=znver2 -mmmx -msse -msse2 -msse3 -mssse3 -msse4a -mcx16 -msahf -mmovbe -maes -msha -mpclmul -mpopcnt -mabm -mfma -mbmi -mbmi2 -mwbnoinvd -mavx -mavx2 -msse4.2 -msse4.1 -mlzcnt -mrdrnd -mf16c -mfsgsbase -mrdseed -mprfchw -madx -mfxsr -mxsave -mxsaveopt -mclflushopt -mxsavec -mxsaves -mclwb -mmwaitx -mclzero -mrdpid --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=512 -mtune=znver2" \
    && cmake ../ -DPYTHON_EXECUTABLE="`which python3`" -DBUILD_JIT=ON -DENABLE_CUDA=off -DENABLE_MPI=on -DENABLE_TBB=on -DBUILD_TESTING=off -DENABLE_MPI_CUDA=off -DCMAKE_INSTALL_PREFIX=`python3 -c "import site; print(site.getsitepackages()[0])"` \
    && make install -j4 \
    && cd ../../ \
    && rm -rf hoomd \
    || exit 1

# setup self test
RUN mkdir /test
COPY test/* /test/

# configure unprivileged user
RUN useradd --create-home --shell /bin/bash glotzerlab-software \
    && chown glotzerlab-software:glotzerlab-software -R /test \
    && chmod o+rX -R /test \
    && chmod o+rX `python3 -c "import site; print(site.getsitepackages()[0])"`/flow/templates/*

USER glotzerlab-software:glotzerlab-software
```

## Build the Docker container image

Use the following commands to build the Docker container image (remember
to put your Docker Hub username in place of "yourdhusername"):

```
cd $BUILD_ROOT
docker build --platform linux/amd64 --tag yourdhusername/hoomd:2.9.6 .
```

This build will likely take several hours.

## Push the Docker container image to Docker Hub

Once the container image has been built, you can then push it to the Docker Hub with
the command:

```
docker push yourdhusername/hoomd:2.9.6
```

Pushing the contianer image to the Docker Hub simplifies the process of producing a 
Singularity container image on ARCHER2.

## Convert the Docker container image to Singularity

Now, log into ARCHER2 and produce a Singularity image file from the Docker container
image on Docker Hub with:

```
auser@ln01:~> singularity build hoomd-blue-2.9.6.sif docker://yourdhusername/hoomd:2.9.6
```

