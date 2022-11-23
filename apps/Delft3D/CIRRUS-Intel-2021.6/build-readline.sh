#!/usr/bin/env bash

set -e

module load oneapi
module load compiler/latest
module load gcc

module list

export prefix=$(pwd)/install

wget http://git.savannah.gnu.org/cgit/readline.git/snapshot/readline-8.1.tar.gz
tar -xf readline-8.1.tar.gz
cd readline-8.1

./configure --prefix=${prefix}/readline


make
make check
make install
