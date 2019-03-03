#!/bin/sh

# Thwap backup configuration, start with the base dir
THWAP_BKUP=/backup/${USER}/rdiff/$(hostname -s)

# then let's setup the rdiff-backup work
THWAP_RDIFF=${THWAP_BKUP}/rdiff
THWAP_RDIFF_ARGS="--verify -b" # --print-statistics"

rdiff-backup ${THWAP_RDIFF_ARGS} ${HOME}/ ${THWAP_RDIFF}/
rdiff-backup --remove-older-than 30D ${THWAP_RDIFF}
