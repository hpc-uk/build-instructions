#!/bin/bash
sed -e "s#%CRAY_LIBSCI_PREFIX_DIR%#$CRAY_LIBSCI_PREFIX_DIR#g; s#%libsci_libs%#sci_gnu_51_mp#g" site.cfg-libsci.template > site.cfg-libsci
