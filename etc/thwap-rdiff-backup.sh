# backup directory, remember, a single user can be on many hosts
# so let's keep things separated nicely.
THWAP_RDIFF_DIR=/backup/${USER}/rdiff/$(hostname -s)

# And setup our rdiff-backup args
THWAP_RDIFF_ARGS="--verify -b"
THWAP_RDIFF_ARGS="${THWAP_RDIFF_ARGS} --exclude ${HOME}/.thwap/library"
THWAP_RDIFF_ARGS="${THWAP_RDIFF_ARGS} --exclude ${HOME}/work/build"
THWAP_RDIFF_ARGS="${THWAP_RDIFF_ARGS} --exclude ${HOME}/disk-images"

# Finally our retention period.
# As a note this, should be readable by rdiff-backup as it will
# be applied directly to the -r option. I've set it to 14 days.
THWAP_RDIFF_RETENTION="14D"
