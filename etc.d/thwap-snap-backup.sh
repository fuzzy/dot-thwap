# Thwap backup configuration, start with the base dir
THWAP_BKUP=/backup/${USER}

# and our tar snapshot stuff
THWAP_SNAPS=${THWAP_BKUP}/snaps
THWAP_SNAPS_ARGS="-f- -c ${HOME}/"
THWAP_SNAPS_COMP="pxz -e -9"
THWAP_SNAPS_EXT="txz"
THWAP_SNAPS_HISTORY=3
THWAP_SNAPS_CURRENT="$(hostname -s)--${USER}--$(date +%s).${THWAP_SNAPS_EXT}"
