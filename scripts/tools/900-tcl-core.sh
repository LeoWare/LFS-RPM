#!/bin/bash
exit 1
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="tcl"
_version="8.6.8"
_sourcedir="${_package}${_version}"
_log="$LFS_TOP/$LOGDIR/$_prgname.log"
_completed="$LFS_TOP/$LOGDIR/$_prgname.completed"

_red="\\033[1;31m"
_green="\\033[1;32m"
_yellow="\\033[1;33m"
_cyan="\\033[1;36m"
_normal="\\033[0;39m"


printf "${_green}==>${_normal} Building $_package-$_version: "

[ -e $_completed ] && {
    printf "${_yellow}SKIPPING${_normal}\n"
    exit 0
} || printf "\n"

# unpack sources
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}${_version}-src"

# cd to source dir
cd $_sourcedir

# prep

build2 "cd unix" $_log
build2 "./configure --prefix=$TOOLS" $_log

# build
build2 "make $MKFLAGS" $_log

#build2 "TZ=UTC make test" $_log

# install
build2 "make install" $_log

build2 "chmod -v u+w $TOOLS/lib/libtcl8.6.so" $_log

build2 "make install-private-headers" $_log

build2 "ln -sv tclsh8.6 $TOOLS/bin/tclsh" $_log

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfully
exit 0
