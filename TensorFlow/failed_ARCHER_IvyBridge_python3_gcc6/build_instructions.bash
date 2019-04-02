#!/bin/bash

# The current installation of Tensorflow on Archer is commit
# 88633a8ebbd0fada4ae73f11410939a3f0d818d8, which is between 1.2.1 and
# 1.3.0-rc0.  No version of Tensorflow from 1.4.1 to 1.13.1 will build
# on Archer.

# =======================================
# Run this script in a directory on /home
# Running on /work is too slow.
# =======================================

# === Setup ===

# Perform all steps on a serial/post-processing node to avoid
# overloading login nodes.  Needed or you will get JVM memory errors
# during builds.
ssh espp2

build=/home/z01/shared/Q1176696
install=/work/z01/shared/Q1176696

(
    cd $build
    
    # Set up module and build environments
    module load wget
    # python-compute/3.6.0_gcc6.1.0 switches to PrgEnv-gnu and unloads
    # xalt.  Use python3 and pip3, not python and pip.
    module load python-compute/3.6.0_gcc6.1.0
    module load numpy
    module load mpi4py
    module load java
    export JAVA_VERSION=1.8
    export CC=gcc
    export CXX=g++
    export FC=gfortran
    
    # Set installation directory for custom software.  This should be a
    # path in your /work space.
    export INSTALL_DIR=$install
    
    # /tmp is periodically cleaned on ARCHER nodes.  This will
    # occasionally cause compiles to fail.  Create custom temp dir to work
    # around this.
    rm -rf tmp
    mkdir tmp
    export TMPDIR=$PWD/tmp
    
    # === Building Prerequisites ===
    
    # First, we need a newer version of sed than is available on ARCHER.
    wget http://ftp.gnu.org/gnu/sed/sed-4.7.tar.xz
    tar xf sed-4.7.tar.xz
    (
	cd sed-4.7
	./configure --prefix=$INSTALL_DIR &> configure.log
	make &> make.log
	make install &> install.log
    )
    # Add INSTALL_DIR to path so we use the new version of sed over the
    # default.
    PATH=$INSTALL_DIR/bin:$PATH
    
    # Then, install Bazel.  Hard to believe it is possible to have a build
    # system worse than CMake, but Bazel is it!
    
    # Bazel 0.19.0 or 0.21.0 is needed for Tensorflow - thanks
    # Tensorflow for not telling us this on your web page.
    #
    # Bazel 0.19.0 builds and works for Tensorflow.
    #
    # Bazel 0.21.0 does not build:  an 'env -' is used, so the
    # enviroment is empty and LD_LIBRARY_PATH is unset, so the GCC
    # 6.1.0 libstdc++ is not found, and the system libstdc++ is too
    # old.  What complete rubbish Bazel is.
    #
    # Bazel 0.22.0 does not work for Tensorflow.
    #
    # Bazel 0.23.2 does not work for Tensorflow (or even build?).
    #
    # Bazel 0.24.0 needs pthread_setname_np which is available in glibc
    # 2.12 and Archer has glibc 2.11.3
    wget https://github.com/bazelbuild/bazel/releases/download/0.19.0/bazel-0.19.0-dist.zip
    mkdir bazel-0.19.0-dist
    (
	cd bazel-0.19.0-dist
	unzip -q ../bazel-0.19.0-dist.zip
	
	# https://docs.bazel.build/versions/master/install-compile-source.html#bootstrap-bazel
	
	# Compile Bazel and copy resulting binary to install directory.
	env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh &> compile.log
	cp output/bazel $INSTALL_DIR/bin
    )
    
    # === Building TensorFlow ===
    
    # Build tensorflow from source (required to work around pip
    # version GLIBC error).  With reference to:
    # https://www.tensorflow.org/install/source
    
    #
    # Tensorflow 1.4.1 needs Bazel 0.4.5 or 0.5.4
    #
    # Tensorflow 1.5.1 and 1.6.0 fail with
    # Illegal ambiguous match on configurable attribute
    #
    # Tensorflow 1.7.1, 1.8.0, 1.9.0, 1.10.1, 1.11.0, 1.12.0, 1.13.1 need pthread_setname_np which is
    # available in glibc 2.12 and Archer has glibc 2.11.3
    wget https://github.com/tensorflow/tensorflow/archive/v1.5.1.tar.gz
    tar xf v1.5.1.tar.gz
    (
	cd tensorflow-1.5.1
	
	# install requirements
	pip3 install --upgrade --prefix=$INSTALL_DIR mock &> mock.log
	pip3 install --upgrade --prefix=$INSTALL_DIR keras_applications==1.0.6 --no-deps &> keras_applications.log
	pip3 install --upgrade --prefix=$INSTALL_DIR keras_preprocessing==1.0.5 --no-deps &> keras_preprocessing.log
	PYTHONPATH=$INSTALL_DIR/lib/python3.6/site-packages:$PYTHONPATH
	
	# Bazel needs its own temp dir not on NFS, i.e., not in /home
	# space, but try this to speed things up.
	export TEST_TMPDIR=$TMPDIR
	
	# Tensorflow configure needs told to use python3
	export PYTHON_BIN_PATH=$(which python3)

	# Get current MPI path and remember for future configure step.
	# Should be:
	#
	# /opt/cray/mpt/7.5.5/gni/mpich-gnu/5.1
	#
	# or similar.
	echo MPICH_DIR = $MPICH_DIR
	export MPI_HOME=$MPICH_DIR
	
	# The configure script (badly written) is expecting to find
	# libmpi.so but we have libmpich.so.  Edit script.
	sed -i -e 's#lib/libmpi.so#lib/libmpich.so#g' configure.py

	# Even worse, in 1.13.1 it edits a Bazel file
	# sed_in_place('third_party/mpi/mpi.bzl',
	#              'MPI_LIB_IS_OPENMPI=True',
        #              'MPI_LIB_IS_OPENMPI=False')
	# but third_party/mpi/mpi.bzl contains
	# MPI_LIB_IS_OPENMPI = True
	# This is obviously not tested.
	
	# Configure the installation - yes, you have to do this
	# interactively.
	#
	# Ensure path "$INSTALL_DIR/lib/python3.6/site-packages" is
	# chosen for "Please input the desired Python library path to
	# use".
	#
	# Do not build with jemalloc, Google Cloud Platform, Hadoop
	# File System support, Amazon AWS Platform, Apache Kafka
	# Platform.
	#
	# Enable MPI build.
	#
	# Use -march=corei7-avx for the optimisation, for the compute
	# nodes.
	#
	# Select all defaults for everything else (Return at each prompt).
	./configure
	
	# Build a TensorFlow pip package.  Use --batch to not have an
	# unconnected process - these are killed off.
	bazel --batch build --config=opt --cxxopt=-D_GLIBCXX_USE_CXX11_ABI=0 //tensorflow/tools/pip_package:build_pip_package &> build.log
	./bazel-bin/tensorflow/tools/pip_package/build_pip_package $TMPDIR/tensorflow_pkg &> build_pip_package.log
	pip3 install --prefix=$INSTALL_DIR $TMPDIR/tensorflow_pkg/tensorflow-version-tags.whl &> pip3_install.log

	# It is unknown if the following fixes are needed
	#
	## Add env=ctx.configuration.default_shell_env, to the
	## ctx.action section in bazel's protobuf.bzl.  Needed to work
	## around "GLIBCXX_3.4.18 not found" error.  See:
	## https://github.com/bazelbuild/bazel/issues/2515#issuecomment-280637265
	## and:
	## https://gist.github.com/taylorpaul/3e4e405ffad1be8355bf742fa24b41f0
	## NOTE: Will need to try and fail the bazel build step before
	## this file is generated
	#your_favourite_editor bazel-tensorflow/external/protobuf/protobuf.bzl
	#
	#bazel --batch build --config=opt --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" --incompatible_remove_native_http_archive=false --incompatible_static_name_resolution //tensorflow/tools/pip_package:build_pip_package
    )
)
