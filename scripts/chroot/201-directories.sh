#!/bin/bash
set -o errexit  # exit if error
set -o nounset  # exit if variable not initalized
set +h          # disable hashall

source $TOPDIR/config.inc
source $TOPDIR/function.inc
_prgname=${0##*/}   # script name minus the path

_package=""
_version=""
_sourcedir="${_package}-${_version}"
_log="$LFS_TOP/$LOGDIR/$_prgname.log"
_completed="$LFS_TOP/$LOGDIR/$_prgname.completed"

_red="\\033[1;31m"
_green="\\033[1;32m"
_yellow="\\033[1;33m"
_cyan="\\033[1;36m"
_normal="\\033[0;39m"


printf "${_green}==>${_normal} Create directories and symlinks: "

[ -e $_completed ] && {
    printf "${_yellow}SKIPPING${_normal}\n"
    exit 0
} || printf "\n"

# unpack sources
#[ -d gcc-build ] && build2 "rm -rf gcc-build" $_log
#[ -d $_sourcedir ] && build2 "rm -rf $_sourcedir" $_log
#unpack "${PWD}" "${_package}-${_version}"

# cd to source dir
#build2 "cd $_sourcedir" $_log

# prep

# build

# install
# directories
mkdir -pv $LFS/{bin,boot,dev,{etc/,}opt,home,lib{,32,64},mnt}
mkdir -pv $LFS/{proc,media/{floppy,cdrom},run/{,shm},sbin,srv,sys}
mkdir -pv $LFS/var/{lock,log,mail,spool}
mkdir -pv $LFS/var/{opt,cache,lib{,32,64}/{misc,locate},local}
install -dv $LFS/root -m 0750
install -dv $LFS{/var,}/tmp -m 1777
ln -sfv ../run $LFS/var/run
mkdir -pv $LFS/usr/{,local/}{bin,include,lib{,32,64},sbin,src}
mkdir -pv $LFS/usr/{,local/}share/{doc,info,locale,man}
mkdir -pv $LFS/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv $LFS/usr/{,local/}share/man/man{1..8}
install -dv $LFS/usr/lib/locale
ln -sfv ../lib/locale $LFS/usr/lib64

# symlinks
ln -sfv $TOOLS/bin/{bash,cat,echo,grep,pwd,stty} $LFS/bin
ln -sfv $TOOLS/bin/file $LFS/usr/bin
ln -sfv $TOOLS/lib32/libgcc_s.so{,.1} $LFS/usr/lib32
ln -sfv $TOOLS/lib64/libgcc_s.so{,.1} $LFS/usr/lib64
ln -sfv $TOOLS/lib32/libstd* $LFS/usr/lib32
ln -sfv $TOOLS/lib64/libstd* $LFS/usr/lib64
ln -sfv bash $LFS/bin/sh


# /root/.bash_profile
cat >> ${LFS}/root/.bash_profile << EOF
export BUILD32="${BUILD32}"
export BUILD64="${BUILD64}"
export LFS_TARGET="${LFS_TARGET}"
export LFS_TARGET32="${LFS_TARGET32}"
EOF

cat > $LFS/etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:/bin:/bin/false
daemon:x:2:6:/sbin:/bin/false
messagebus:x:27:27:D-Bus Message Daemon User:/dev/null:/bin/false
systemd-bus-proxy:x:71:72:systemd Bus Proxy:/:/bin/false
systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/bin/false
systemd-journal-remote:x:74:74:systemd Journal Remote:/:/bin/false
systemd-journal-upload:x:75:75:systemd Journal Upload:/:/bin/false
systemd-network:x:76:76:systemd Network Management:/:/bin/false
systemd-resolve:x:77:77:systemd Resolver:/:/bin/false
systemd-timesync:x:78:78:systemd Time Synchronization:/:/bin/false
systemd-coredump:x:79:79:systemd Core Dumper:/:/bin/false
nobody:x:65534:65533:Unprivileged User:/dev/null:/bin/false
EOF

cat > $LFS/etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:5:
tape:x:4:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
mail:x:30:
messagebus:x:27:
nogroup:x:65533:
systemd-bus-proxy:x:72:
systemd-journal:x:28:
systemd-journal-gateway:x:73:
systemd-journal-remote:x:74:
systemd-journal-upload:x:75:
systemd-network:x:76:
systemd-resolve:x:77:
systemd-timesync:x:78:
systemd-coredump:x:79:
wheel:x:39:
EOF

cat > $LFS/etc/hostname << "EOF"
leoware
EOF

# clean up
#build2 "cd .." $_log
#build2 "rm -rf gcc-build" $_log
#build2 "rm -rf $_sourcedir" $_log

# make .completed file
build2 "touch $_completed" $_log

# exit sucessfully
exit 0
