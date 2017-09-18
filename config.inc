##############################
# Editable variables follow

# Where to build LFS
LFS=/mnt/lfs

# Where to build BLFS
BLFS=/mnt/blfs

# Where to build the toolchain
TOOLS=/tools

# Where build system lives
PARENT="/home/samuel/LFS-RPM"

# Get the number of processors on this host for make
MKFLAGS="-j $(getconf _NPROCESSORS_ONLN)"	

##############################
# Edit partition and mnt_point for the correct values.
# Failing to do so will cause you grief as in overwriting your host system.
# You have been warned!

# Device to which to install the completed system
# The LFS Partition
DEVICE=/dev/sdb1

# Filesystem type
FILESYSTEM=ext4

# Name of the log file
LOGFILE="$(date +%Y-%m-%d).log"

# User account with which to build
USER=lfs
