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
build2 "cd $_sourcedir" $_log

# unpack "${PWD}" "mpfr-4.0.1"
# unpack "${PWD}" "gmp-6.1.2"
# unpack "${PWD}" "mpc-1.1.0"

# build2 "ln -sfv mpfr-4.0.1 mpfr" $_log
# build2 "ln -sfv gmp-6.1.2 gmp" $_log
# build2 "ln -sfv mpc-1.1.0 mpc" $_log

# prep

build2 "patch -Np1 -i ../../sources/gcc-7.3.0-specs-1.patch" $_log
build2 "patch -Np1 -i ../../sources/gcc-7.3.0-isl-0.20-includes-1.patch" $_log

for file in gcc/config/{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e "s@/lib\(64\)\?\(32\)\?/ld@${TOOLS}&@g" \
      -e "s@/usr@${TOOLS}@g" $file.orig > $file
  echo "
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 \"${TOOLS}/lib64/\"
#define STANDARD_STARTFILE_PREFIX_2 \"\"
" >> $file
  touch $file.orig
done

build2 "install -vdm 0755 $TOOLS/include" $_log
build2 "touch $TOOLS/include/limits.h" $_log

# case $(uname -m) in
#   x86_64)
#     sed -e '/m64=/s/lib64/lib/' \
#         -i.orig gcc/config/i386/t-linux64
#  ;;
# esac

build2 "install -vdm 0755 ../gcc-build" $_log
build2 "cd ../gcc-build" $_log
build2 "AR=ar \
LDFLAGS=\"-Wl,-rpath,$CROSS_TOOLS/lib\" \
../gcc-7.3.0/configure \
    --build=$LFS_HOST \
    --host=$LFS_HOST \
    --target=$LFS_TARGET                      \
    --prefix=$CROSS_TOOLS                     \
    --with-glibc-version=2.27                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --with-local-prefix=$TOOLS                     \
    --with-native-system-header-dir=$TOOLS/include \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libmpx                               \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --disable-libcilkrts \
    --enable-languages=c,c++ \
    --with-multilib-list=m32,m64 \
    --enable-targets=x86_64-pc-linux-gnu,i686-pc-linux-gnu \
    --enable-linker-build-id \
    --enable-__cxa_atexit \
    --with-mpfr=$CROSS_TOOLS \
    --with-gmp=$CROSS_TOOLS \
    --with-mpc=$CROSS_TOOLS \
    --with-isl=$CROSS_TOOLS" $_log

# build
build2 "make $MKFLAGS all-gcc all-target-libgcc" $_log


# install
build2 "make install-gcc install-target-libgcc" $_log

# clean up
build2 "cd .." $_log
build2 "rm -rf gcc-build" $_log
build2 "rm -rf $_sourcedir" $_log

# make .completed file
build2 "touch $_completed" $_log

# exit sucessfully
exit 0
