#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="gcc"
_version="7.3.0"
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
[ -d gcc-build ] && build2 "rm -rf gcc-build" $_log
[ -d $_sourcedir ] && build2 "rm -rf $_sourcedir" $_log
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# unpack "${PWD}" "mpfr-4.0.1"
# unpack "${PWD}" "gmp-6.1.2"
# unpack "${PWD}" "mpc-1.1.0"

# build2 "ln -sfv mpfr-4.0.1 mpfr" $_log
# build2 "ln -sfv gmp-6.1.2 gmp" $_log
# build2 "ln -sfv mpc-1.1.0 mpc" $_log

# prep

build2 "patch -Np1 -i ../../sources/gcc-7.3.0-specs-1.patch" $_log
build2 "patch -Np1 -i ../../sources/gcc-7.3.0-isl-0.20-includes-1.patch" $_log

#build2 "cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
#  `dirname \$(\$LFS_TARGET-gcc -print-libgcc-file-name)`/include-fixed/limits.h" $_log

for file in gcc/config/{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e "s@/lib\(64\)\?\(32\)\?/ld@$TOOLS&@g" \
      -e "s@/usr@$TOOLS@g" $file.orig > $file
  echo "
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 \"${TOOLS}/lib64/\"
#define STANDARD_STARTFILE_PREFIX_2 \"\"
" >> $file
  touch $file.orig
done


build2 "cp -v gcc/Makefile.in{,.orig}" $_log
build2 "sed 's@\./fixinc\.sh@-c true@' gcc/Makefile.in.orig > gcc/Makefile.in" $_log


build2 "install -vdm 0755 ../gcc-build" $_log
build2 "cd ../gcc-build" $_log
build2 "../$_package-$_version/configure \
    --prefix=$TOOLS \
    --build=${LFS_HOST} \
    --host=${LFS_TARGET} \
    --target=${LFS_TARGET} \
    --with-local-prefix=$TOOLS \
    --enable-languages=c,c++ \
    --with-system-zlib \
    --with-native-system-header-dir=$TOOLS/include \
    --disable-libssp \
    --enable-install-libiberty \
    --with-multilib-list=m32,m64 \
    --enable-targets=x86_64-pc-linux-gnu,i686-pc-linux-gnu \
    --enable-linker-build-id \
    --enable-__cxa_atexit" $_log

# build
build2 "make $MKFLAGS AS_FOR_TARGET=\"${AS}\" \
    LD_FOR_TARGET=\"${LD}\"" $_log

# install
build2 "make install" $_log

#build2 "ln -sv gcc $TOOLS/bin/cc" $_log

# clean up
build2 "cd .." $_log
build2 "rm -rf gcc-build" $_log
build2 "rm -rf $_sourcedir" $_log

# make .completed file
build2 "touch $_completed" $_log

# exit sucessfully
exit 0
