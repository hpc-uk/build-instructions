#!/bin/bash

mkdir -p $HOME/grads/supplibs
module restore -s PrgEnv-gnu
export SUPPLIBS=$HOME/grads/supplibs
export PKG_CONFIG_PATH=$SUPPLIBS/lib/pkgconfig:$PKG_CONFIG_PATH

# Install libpng
cd $HOME/tarfiles
wget http://prdownloads.sourceforge.net/libpng/libpng-1.6.37.tar.xz
if [ "$?" != 0 ]; then
   >&2 echo "Error downloading libpng-1.6.37.tar.xz"
   exit 1
fi
tar xf libpng-1.6.37.tar.xz
cd libpng-1.6.37
CC=cc ./configure --prefix=$SUPPLIBS
make
make install

# Install gdlib
cd $HOME/tarfiles
wget https://github.com/libgd/libgd/releases/download/gd-2.3.2/libgd-2.3.2.tar.gz
if [ "$?" != 0 ]; then
   >&2 echo "Error downloading libgd-2.3.2.tar.gz"
   exit 1
fi
tar xf libgd-2.3.2.tar.gz
cd libgd-2.3.2
CC=cc ./configure --prefix=$SUPPLIBS --with-png=$SUPPLIBS
make
make install

# Install pixman
cd $HOME/tarfiles
wget https://www.cairographics.org/releases/pixman-0.40.0.tar.gz
if [ "$?" != 0 ]; then
   >&2 echo "Error downloading pixman-0.40.0.tar.gz"
   exit 1
fi
tar xf pixman-0.40.0.tar.gz
cd pixman-0.40.0/
CC=cc ./configure --prefix=$SUPPLIBS
make
make install

# Install cairo
cd $HOME/tarfiles
wget https://cairographics.org/snapshots/cairo-1.17.4.tar.xz
if [ "$?" != 0 ]; then
   >&2 echo "Error downloading cairo-1.17.4.tar.xz"
   exit 1
fi
tar xf cairo-1.17.4.tar.xz
cd cairo-1.17.4
CC=cc ./configure --prefix=$SUPPLIBS --enable-xlib=yes --enable-xml=yes --enable-fc=yes --enable-ft=yes --enable-xlib-xrender=yes --enable-pthread=yes --enable-xcb=no --enable-qt=no --enable-quartz=no --enable-win32=no --enable-skia=no --enable-os2=no --enable-beos=no --enable-drm=no --enable-gl=no
make
make install

# Install ncurses
cd $HOME/tarfiles
wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.2.tar.gz
if [ "$?" != 0 ]; then
   >&2 echo "Error downloading ncurses-6.2.tar.gz"
   exit 1
fi
tar xf ncurses-6.2.tar.gz 
cd ncurses-6.2/
CC=cc CXX=CC ./configure --prefix=$SUPPLIBS --without-ada --with-shared
make
make install

# Install readlines
cd $HOME/tarfiles
wget https://ftp.gnu.org/gnu/readline/readline-8.1.tar.gz
if [ "$?" != 0 ]; then
   >&2 echo "Error downloading readline-8.1.tar.gz"
   exit 1
fi
tar xf readline-8.1.tar.gz 
cd readline-8.1/
CC=cc ./configure --prefix=$SUPPLIBS
make
make install

# LibUUID (libdap dependency)
cd $HOME/tarfiles
wget https://downloads.sourceforge.net/project/libuuid/libuuid-1.0.3.tar.gz
if [ "$?" != 0 ]; then
   >&2 echo "Error downloading libuuid-1.0.3.tar.gz"
   exit 1
fi
tar xf libuuid-1.0.3.tar.gz
cd libuuid-1.0.3/
CC=cc CXX=CC ./configure --prefix=$SUPPLIBS
make
make install

# LibXML2 (libdap dependency)
cd $HOME/tarfiles
wget https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.9.11/libxml2-v2.9.11.tar.gz
if [ "$?" != 0 ]; then
   >&2 echo "Error downloading libxml2-v2.9.11.tar.gz"
   exit 1
fi
tar xf libxml2-v2.9.11.tar.gz
cd libxml2-v2.9.11/
autoreconf -i
CC=cc ./configure --prefix=$SUPPLIBS --without-threads --without-iconv --without-iso8859x --without-lzma --without-python
make
make install

# LibDAP
cd $HOME/tarfiles
wget https://www.opendap.org/pub/source/libdap-3.18.1.tar.gz
if [ "$?" != 0 ]; then
   >&2 echo "Error downloading libdap-3.18.1.tar.gz"
   exit 1
fi
tar xf libdap-3.18.1.tar.gz
cd libdap-3.18.1
export CPPFLAGS="-I$SUPPLIBS/include"
CC=cc CXX=CC ./configure --prefix=$SUPPLIBS
make
make install

# Install udunits
cd $HOME/tarfiles
wget https://artifacts.unidata.ucar.edu/repository/downloads-udunits/udunits-1.11.7.tar.Z
if [ "$?" != 0 ]; then
   >&2 echo "Error downloading udunits-1.11.7.tar.Z"
   exit 1
fi
tar xf udunits-1.11.7.tar.Z
cd udunits-1.11.7/src
CPPFLAGS="-Df2cFortran -fPIC" CC=cc ./configure --prefix=$SUPPLIBS
make
make install

# Install grads
cd $HOME/tarfiles
wget ftp://cola.gmu.edu/grads/2.2/grads-2.2.1-src.tar.gz
if [ "$?" != 0 ]; then
   >&2 echo "Error downloading grads-2.2.1-src.tar.gz"
   exit 1
fi
tar xf grads-2.2.1-src.tar.gz
cd grads-2.2.1
module load cray-netcdf
CC=cc CXX=CC ./configure --prefix=$HOME/grads --with-udunits=$SUPPLIBS --with-netcdf=$NETCDF_DIR
module load cray-hdf5
make
make install

echo "GrADS build script has finished."

