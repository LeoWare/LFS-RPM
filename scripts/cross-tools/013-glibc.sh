#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="glibc"
_version="2.27"
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
[ -d glibc-build ] && build2 "rm -rf glibc-build" $_log
[ -d $_sourcedir ] && build2 "rm -rf $_sourcedir" $_log
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
build2 "cd $_sourcedir" $_log

# prep
build2 "install -vdm 0755 ../glibc-build" $_log
build2 "cd ../glibc-build" $_log
build2 "BUILD_CC=\"gcc\" CC=\"${LFS_TARGET}-gcc ${BUILD64}\" \
AR=\"${LFS_TARGET}-ar\" RANLIB=\"${LFS_TARGET}-ranlib\" \
../glibc-2.27/configure                             \
      --prefix=$TOOLS                    \
      --host=$LFS_TARGET                    \
      --build=$LFS_HOST \
      --libdir=$TOOLS/lib64 \
      --enable-kernel=3.2             \
      --with-headers=$TOOLS/include      \
      --with-binutils=$CROSS_TOOLS/bin \
      libc_cv_slibdir=$TOOLS/lib64 \
      libc_cv_forced_unwind=yes          \
      libc_cv_c_cleanup=yes" $_log

# build
build2 "make $MKFLAGS" $_log

# install
build2 "make install" $_log

# clean up
build2 "cd .." $_log
build2 "rm -rf glibc-build" $_log
build2 "rm -rf $_sourcedir" $_log

# make .completed file
build2 "touch $_completed" $_log

# exit sucessfully
exit 0
