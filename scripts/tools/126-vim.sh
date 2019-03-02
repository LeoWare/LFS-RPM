#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package="vim"
_version="8.0.586"
_sourcedir="${_package}80"
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
#[ -d gcc-build ] && build2 "rm -rf gcc-build" $_log
[ -d $_sourcedir ] && build2 "rm -rf $_sourcedir" $_log
unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
build2 "cd $_sourcedir" $_log

# prep
cat > src/auto/config.cache << "EOF"
vim_cv_getcwd_broken=no
vim_cv_memmove_handles_overlap=yes
vim_cv_stat_ignores_slash=no
vim_cv_terminfo=yes
vim_cv_toupper_broken=no
vim_cv_tty_group=world
vim_cv_tgent=zero
EOF

echo '#define SYS_VIMRC_FILE "$TOOLS/etc/vimrc"' >> src/feature.h

build2 "./configure \
    --build=${LFS_HOST} \
    --host=${LFS_TARGET} \
    --prefix=$TOOLS \
    --enable-gui=no \
    --disable-gtktest \
    --disable-xim \
    --disable-gpm \
    --without-x \
    --disable-netbeans \
    --with-tlib=ncurses" $_log

# build
build2 "make $MKFLAGS " $_log

# install
build2 "make -j1 install" $_log

build2 "ln -sfv vim $TOOLS/bin/vi" $_log

cat > $TOOLS/etc/vimrc << EOF
" Begin $TOOLS/etc/vimrc

set nocompatible
set backspace=2
set ruler
set number
set mouse=a
set ts=4
set sw=4
set expandtab
syntax on

" End $TOOLS/etc/vimrc
EOF

# clean up
build2 "cd .." $_log
#build2 "rm -rf gcc-build" $_log
build2 "rm -rf $_sourcedir" $_log

# make .completed file
build2 "touch $_completed" $_log

# exit sucessfully
exit 0
