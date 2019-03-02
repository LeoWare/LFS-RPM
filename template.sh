#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="grub"
_version="2.02"
_sourcedir="${_package}-${_version}"
_log="$LFS_TOP/$LOGDIR/$_prgname.log"
_completed="$LFS_TOP/$LOGDIR/$_prgname.completed"

_red="\\033[1;31m"
_green="\\033[1;32m"
_yellow="\\033[1;33m"
_cyan="\\033[1;36m"
_normal="\\033[0;39m"


printf "${_green}==>${_normal} Building $_package-$_version"

[ -e $_completed ] && {
    msg ":  ${_yellow}SKIPPING${_normal}"
    exit 0
}

msg ""

# unpack sources
[ -d $_sourcedir ] && rm -rf $_sourcedir
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
cd $_sourcedir

# prep
#build2 "sed -i -e '/gets is a/d' grub-core/gnulib/stdio.in.h" $_log

#build2 "./configure \
#    --prefix=/usr \
#    --sysconfdir=/etc \
#    --disable-werror" $_log

build2 "patch -Np1 -i ../../sources/grub-2.02-gcc-8-fixes-1.patch" $_log
build2 "./configure \
    --prefix=/usr \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --libdir=/lib64 \
    --disable-werror \
    --enable-grub-mkfont=no \
    --with-bootdir=/boot \
    --with-platform=efi \
    --disable-efiemu \
    --sbindir=/sbin \
    --sysconfdir=/etc" $_log

# build
build2 "make $MKFLAGS" $_log

#build2 "make check" $_log

# install
build2 "make install" $_log

# configuration
build2 "install -m755 -dv /etc/default" $_log

cat > /etc/default/grub << "EOF"
# Begin /etc/default/grub

GRUB_DEFAULT=0
#GRUB_SAVEDEFAULT=true
GRUB_HIDDEN_TIMEOUT=
GRUB_HIDDEN_TIMEOUT_QUIET=false
GRUB_TIMEOUT=10
GRUB_DISTRIBUTOR=Cross-LFS

GRUB_CMDLINE_LINUX=""
GRUB_CMDLINE_LINUX_DEFAULT=""

#GRUB_TERMINAL=console
#GRUB_GFXMODE=640x480
#GRUB_GFXPAYLOAD_LINUX=keep

#GRUB_DISABLE_LINUX_UUID=true
#GRUB_DISABLE_LINUX_RECOVERY=true

#GRUB_INIT_TUNE="480 440 1"

#GRUB_DISABLE_OS_PROBER=true

# End /etc/default/grub
EOF

# clean up
cd ..
rm -rf $_sourcedir

# make .completed file
touch $_completed

# exit sucessfull
exit 0
