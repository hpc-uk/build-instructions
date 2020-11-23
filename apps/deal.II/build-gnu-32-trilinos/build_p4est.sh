#!/bin/bash
export F77=ftn
export CC=cc
export FC=ftn
export CXX=CC
# Set FCLIBS to blank (not an empty string) to prevent all the
# compiler wrapper's libraries being found and then added
# (incorrectly) to the link line.  Configuration tools trying to be
# too clever as usual.
export FCLIBS=' '
sh ./p4est-setup.sh p4est-1.1.tar.gz $p4est_install_dir
