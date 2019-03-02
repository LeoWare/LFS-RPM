#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="binutils"
_version="2.30"
_sourcedir="${_package}-${_version}"
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
[ -d binutils-build ] && build2 "rm -rf binutils-build" $_log
[ -d $_sourcedir ] && build2 "rm -rf $_sourcedir" $_log
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
build2 "cd $_sourcedir" $_log

# prep
build2 "install -vdm 0755 ../binutils-build" $_log
build2 "cd ../binutils-build" $_log
build2 "AR=ar AS=as \
../binutils-2.30/configure --prefix=$CROSS_TOOLS            \
             --host=$LFS_HOST \
             --target=$LFS_TARGET \
             --with-sysroot=$LFS        \
             --with-lib-path=$TOOLS/lib32:$TOOLS/lib64 \
             --disable-nls              \
             --disable-static \
             --enable-64-bit-bfd \
             --enable-gold=yes \
             --enable-plugins \
             --enable-threads \
             --disable-werror" $_log

# build
build2 "make $MKFLAGS" $_log

# case $(uname -m) in
#   x86_64) build2 "ln -sfv lib64 $TOOLS/lib" $_log ;;
# esac

# install
build2 "make install" $_log

# clean up
build2 "cd .." $_log
build2 "rm -rf binutils-build" $_log
build2 "rm -rf $_sourcedir" $_log

# make .completed file
build2 "touch $_completed" $_log

# exit sucessfully
exit 0
