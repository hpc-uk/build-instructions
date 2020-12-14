#!/usr/bin/env bash

set -e

# Modules required at build time

module -s restore /etc/cray-pe.d/PrgEnv-gnu

# Modules required at compile time and at run time

module list
