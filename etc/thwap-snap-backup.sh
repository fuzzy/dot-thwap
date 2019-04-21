# Thwap backup configuration, start with the base dir
THWAP_BKUP=/backup/${USER}

# and our tar snapshot stuff
THWAP_SNAPS=${THWAP_BKUP}/snaps
THWAP_SNAPS_ARGS="--warning=no-file-ignored --warning=no-file-changed"
THWAP_SNAPS_ARGS="${THWAP_SNAPS_ARGS} --exclude=${HOME}/work/build"
THWAP_SNAPS_ARGS="${THWAP_SNAPS_ARGS} --exclude=${HOME}/work/build"
THWAP_SNAPS_ARGS="${THWAP_SNAPS_ARGS} --exclude=${HOME}/disk-images"
THWAP_SNAPS_ARGS="${THWAP_SNAPS_ARGS} --exclude=${HOME}/vms"
THWAP_SNAPS_ARGS="${THWAP_SNAPS_ARGS} -c ${HOME}/"
THWAP_SNAPS_COMP_T="xz"
THWAP_SNAPS_COMP="pxz"
THWAP_SNAPS_HISTORY=8
THWAP_SNAPS_DATE=$(date +%F_%T)
THWAP_SNAPS_CURRENT="$(hostname -s)__$(uname -s)__$(uname -m)__${USER}__${THWAP_SNAPS_DATE}.tar"
