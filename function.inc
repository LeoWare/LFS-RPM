# Common support functions

# Give an error message and exit with a non-zero status
die() {
    local _red="\\033[1;31m"
    local _normal="\\033[0;39m"
    [ -n "$*" ] && {
        printf "${_red}$*${_normal}\n"
        printf "$*\n" >> ${LOGFILE}
    }
    exit 1
}

# Check if we are the root user. if not, exit.
check_root() {
    [ $EUID -eq 0 ] || die "${PRGNAME}: Must be root. Exiting."
}

# Make sure we have all our environment variables set
check_environment() {
    [ -z ${LFS} ] && die "${PRGNAME}: LFS not set: FAILURE"
    [ -z ${TOOLS} ] && die "${PRGNAME}: TOOLS not set: FAILURE"
    [ -z ${CROSS_TOOLS} ] && die "${PRGNAME}: CROSS_TOOLS not set: FAILURE"
    [ -z ${HOST_TOP} ] && die "${PRGNAME}: HOST_TOP not set: FAILURE"
    [ -z ${LFS_TOP} ] && die "${PRGNAME}: LFS_TOP not set: FAILURE"
    [ -z ${CLFS_HOST} ] && die "${PRGNAME}: CLFS_HOST not set: FAILURE"
    [ -z ${CLFS_TARGET} ] && die "${PRGNAME}: CLFS_HOST not set: FAILURE"
    [ -z ${CLFS_TARGET32} ] && die "${PRGNAME}: CLFS_HOST not set: FAILURE"
    [ -z ${LFS_USER} ] && die "${PRGNAME}: LFS_USER not set: FAILURE"
    [ -z ${DEVICE} ] && die "${PRGNAME}: DEVICE not set: FAILURE"
    [ -z ${BOOT_DEVICE} ] && die "${PRGNAME}: BOOT_DEVICE not set: FAILURE"
    [ -z ${FILESYSTEM} ] && die "${PRGNAME}: FILESYSTEM not set: FAILURE"
    return 0
}

msg() {
    printf "%s\n" "${1}"
    printf "%s\n" "${1}" >> ${LOGFILE}

}

msg_line() {
    printf "%s" "${1}"
    printf "%s" "${1}" >> ${LOGFILE}
}

msg_failure() {
    local _red="\\033[1;31m"
    local _normal="\\033[0;39m"
    local _msg=""
    if [[ $# -ne 0 ]]; then 
        _msg="${*}"
    else
        _msg="FAILURE"
    fi
    printf "${_red}%s${_normal}\n" "${_msg}"
    printf "%s" "${_msg}" >> $LOGFILE
    exit 2
}

msg_warning() {
    local _yellow="\\033[1;33m"
    local _normal="\\033[0;39m"
    local _msg=""
    if [[ $# -ne 0 ]]; then 
        _msg="${*}"
    else
        _msg="WARNING"
    fi
    printf "${_yellow}%s${_normal}\n" "${_msg}"
    printf "%s\n" "${_msg}" >> $LOGFILE
    return 0
}

msg_success() {
    local _green="\\033[1;32m"
    local _normal="\\033[0;39m"
    #local _msg=""
    if [ $# -ne 0 ]; then 
        local _msg="${*}"
    else
        local _msg="SUCCESS"
    fi
    printf "${_green}%s${_normal}\n" "${_msg}"
    printf "%s\n" "${_msg}" >> $LOGFILE
    return 0
}

msg_section() {
    local _red="\\033[1;31m"
    local _green="\\033[1;32m"
    local _normal="\\033[0;39m"

    local _msg="${1}"
    printf "\n${_red}###        ${_green}%s${_red}        ###${_normal}\n\n" "${_msg}"
    printf "\n###        %s        ###\n\n" "${_msg}" >> ${LOGFILE}
}

end_run() {
    local _green="\\033[1;32m"
    local _normal="\\033[0;39m"
    printf "${_green}%s${_normal}\n" "Run Complete" >> ${LOGFILE}
    return
}

build() {
    local _cyan="\\033[1;36m"
    local _normal="\\033[0;39m"
    # $1 = message 
    # $2 = command
    # $3 = log file
    local _msg="${1}"
    local _cmd="${2}"
    local _logfile="${3}"
    if [ "/dev/null" == "${_logfile}" ]; then
        printf "$_normal  $_cyan->$_normal %s: " "$_msg"
        eval ${_cmd} >> ${_logfile} 2>&1 && msg_success || msg_failure 
    else
        printf "$_normal  $_cyan->$_normal %s: " "$_msg"
        printf "\n  -> %s\n\n" "${_msg}" >> ${_logfile} 2>&1
        eval ${_cmd} >> ${_logfile} 2>&1 && msg_success || msg_failure 
        fi
    return 0
}

build2() {
    local _cyan="\\033[1;36m"
    local _normal="\\033[0;39m"
    # $1 = command
    # $2 = log file
    local _msg="${1}"
    local _cmd="${1}"
    local _logfile="${2}"
    if [ "/dev/null" == "${_logfile}" ]; then
        printf "$_normal  $_cyan->$_normal %s: " "$_msg"
        eval ${_cmd} >> ${_logfile} 2>&1 && msg_success || msg_failure 
    else
        printf "$_normal  $_cyan->$_normal %s: " "$_msg"
        printf "\n  -> %s\n\n" "${_msg}" >> ${_logfile} 2>&1
        eval ${_cmd} >> ${_logfile} 2>&1  && msg_success || msg_failure 
        fi
    return 0
}

unpack() {
    # $1 = directory
    # $2 = source package name. I'll find the suffix thank you
    local _dir=${1%%/$BUILDDIR*} # remove BUILD from path
    local i=${2}
    local p=$(echo ${_dir}/$SOURCESDIR/${i}*.tar.*)
    msg_line "  Unpacking: ${i}: "
    [ -e ${p} ] || die " File not found ${p}: FAILURE"
    tar xf ${p} && msg_success || msg_failure
    return 0
}

build_toolchain() {
    su --login $LFS_USER <<- EOF
        umask 002
        cd ~
        source ~/.bashrc
        cd ${LFS}${LFS_TOP}
        pwd
        ./toolchain.sh
EOF
    return 0
}

build_bootfiles() {
    su --login $LFS_USER <<- EOF
        umask 002
        cd ~
        source ~/.bashrc
        cd ${LFS}${LFS_TOP}
        pwd
        ./bootfiles.sh
EOF
    return 0
}

# this function is called in the host context
build_filesystem() {
    local _logfile="${LOGDIR}/filesystem.log"
    mkdir -pv ${LFS}/{bin,boot,dev,{etc/,}opt,home,lib{,64},mnt}
    mkdir -pv ${LFS}/{proc,media/{floppy,cdrom},run/{,shm},sbin,srv,sys}
    mkdir -pv ${LFS}/var/{lock,log,mail,spool}
    mkdir -pv ${LFS}/var/{opt,cache,lib{,64}/{misc,locate},local}
    install -dv ${LFS}/root -m 0750
    install -dv ${LFS}{/var,}/tmp -m 1777
    ln -sv ../run ${LFS}/var/run
    mkdir -pv ${LFS}/usr/{,local/}{bin,include,lib{,64},sbin,src}
    mkdir -pv ${LFS}/usr/{,local/}share/{doc,info,locale,man}
    mkdir -pv ${LFS}/usr/{,local/}share/{misc,terminfo,zoneinfo}
    mkdir -pv ${LFS}/usr/{,local/}share/man/man{1..8}
    install -dv ${LFS}/usr/lib/locale
    ln -sv ../lib/locale ${LFS}/usr/lib64
    mkdir -pv ${LFS}/usr/local/games
    mkdir -pv ${LFS}/usr/share/games

    [ -e ${LFS}/dev/console ]   || build "mknod -m 600 ${LFS}/dev/console c 5 1" "mknod -m 600 ${LFS}/dev/console c 5 1" "${_logfile}"
    [ -e ${LFS}/dev/null ]      || build "mknod -m 666 ${LFS}/dev/null c 1 3" "mknod -m 666 ${LFS}/dev/null c 1 3" "${_logfile}"

    ln -sv /tools/bin/{bash,cat,echo,grep,pwd,stty} ${LFS}/bin
    ln -sv /tools/bin/file ${LFS}/usr/bin
    ln -sv /tools/lib/libgcc_s.so{,.1} ${LFS}/usr/lib
    ln -sv /tools/lib64/libgcc_s.so{,.1} ${LFS}/usr/lib64
    ln -sv /tools/lib/libstd* ${LFS}/usr/lib
    ln -sv /tools/lib64/libstd* ${LFS}/usr/lib64
    ln -sv bash ${LFS}/bin/sh

    cat >> ${LFS}/root/.bash_profile <<- EOF
        export BUILD32="${BUILD32}"
        export BUILD64="${BUILD64}"
        export CLFS_TARGET32="${CLFS_TARGET32}"
EOF

    cat > ${LFS}/etc/passwd <<- "EOF"
        root:x:0:0:root:/root:/bin/bash
        bin:x:1:1:bin:/dev/null:/bin/false
        adm:x:3:16:adm:/var/adm:/bin/false
        daemon:x:6:6:Daemon User:/dev/null:/bin/false
        lp:x:10:9:lp:/var/spool/lp:/bin/false
        messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
        mail:x:30:30:mail:/var/mail:/bin/false 
        systemd-bus-proxy:x:72:72:systemd Bus Proxy:/:/bin/false
        systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/bin/false
        systemd-journal-remote:x:74:74:systemd Journal Remote:/:/bin/false
        systemd-journal-upload:x:75:75:systemd Journal Upload:/:/bin/false
        systemd-network:x:76:76:systemd Network Management:/:/bin/false
        systemd-resolve:x:77:77:systemd Resolver:/:/bin/false
        systemd-timesync:x:78:78:systemd Time Synchronization:/:/bin/false
        systemd-coredump:x:79:79:systemd Core Dumper:/:/bin/false
        nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

    cat > ${LFS}/etc/group <<- "EOF"
        root:x:0:
        bin:x:1:daemon
        sys:x:2:
        kmem:x:3:
        tape:x:4:
        tty:x:5:
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
        console:x:17:
        messagebus:x:18:
        systemd-journal:x:23:
        input:x:24:
        mail:x:34:
        kvm:x:61:
        systemd-bus-proxy:x:72:
        systemd-journal-gateway:x:73:
        systemd-journal-remote:x:74:
        systemd-journal-upload:x:75:
        systemd-network:x:76:
        systemd-resolve:x:77:
        systemd-timesync:x:78:
        systemd-coredump:x:79:
        nogroup:x:99:
        users:x:999:
EOF

    touch ${LOGDIR}/filesystem.completed
    return 0
}

mount_kernel_vfs() {
    if ! mountpoint ${LFS}/dev  >/dev/null 2>&1; then mount -v -o bind /dev ${LFS}/dev; fi
    if ! mountpoint ${LFS}/dev/pts  >/dev/null 2>&1; then mount -vt devpts -o gid=5,mode=620 devpts ${LFS}/dev/pts; fi
    if ! mountpoint ${LFS}/proc >/dev/null 2>&1; then mount -vt proc proc ${LFS}/proc; fi
    if ! mountpoint ${LFS}/sys  >/dev/null 2>&1; then mount -vt sysfs sysfs ${LFS}/sys; fi
    if ! mountpoint ${LFS}/run  >/dev/null 2>&1; then mount -vt tmpfs tmpfs ${LFS}/run; fi
    if [ -h ${LFS}/dev/shm ]; then mkdir -pv ${LFS}/$(readlink ${LFS}/dev/shm); fi
    return 0
}

umount_kernel_vfs() {
    if mountpoint ${LFS}/run    >/dev/null 2>&1; then umount ${LFS}/run; fi
    if mountpoint ${LFS}/sys    >/dev/null 2>&1; then umount ${LFS}/sys; fi
    if mountpoint ${LFS}/proc   >/dev/null 2>&1; then umount ${LFS}/proc; fi
    if mountpoint ${LFS}/dev/pts    >/dev/null 2>&1; then umount ${LFS}/dev/pts; fi
    if mountpoint ${LFS}/dev    >/dev/null 2>&1; then umount ${LFS}/dev; fi
    return 0
}

build_shell() {
    chroot "${LFS}" /tools/bin/env -i \
        HOME=/root TERM="$TERM" PS1='(LFS chroot) \u:\w\$ ' \
        PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin:/cross-tools/bin:/cross-tools/sbin \
        LFS_TOP="${LFS_TOP}" \
        BUILDLOG="${LOGFILE}" \
        /tools/bin/bash --login +h -c "cd ${LFS_TOP} && pwd && $LFS_TOP/build-shell.sh"
        return 0
}

# vim: set number syntax=sh ts=4 sw=4:
