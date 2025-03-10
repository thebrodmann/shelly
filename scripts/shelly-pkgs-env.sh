#!/usr/bin/env bash
#
# Note: Shelly apps should be sourced from your .bash_profile.
# The shebang above is just for file type detection in vim :).
#
# Usage:
#
#   source /path/to/shelly/bin/ShellyPath
#

export SHELLY_ENV=${SHELLY_ENV:-~/.shelly/env/0}

# If using the default env, ensure the dir exists.
[[ ${SHELLY_ENV} = ~/.shelly/env/0 ]] && mkdir -p "${SHELLY_ENV}"

# Save the original paths.
export SHELLY_ORIGINAL_PATH=${SHELLY_ORIGINAL_PATH:-$PATH}
export SHELLY_ORIGINAL_LD_LIBRARY_PATH=${SHELLY_ORIGINAL_LD_LIBRARY_PATH:-${LD_LIBRARY_PATH:-}}
export SHELLY_ORIGINAL_DYLD_LIBRARY_PATH=${SHELLY_ORIGINAL_DYLD_LIBRARY_PATH:-${DYLD_LIBRARY_PATH:-}}

# Clobber paths so that we don't keep prepending to them.
PATH=$SHELLY_ORIGINAL_PATH
LD_LIBRARY_PATH=$SHELLY_ORIGINAL_LD_LIBRARY_PATH
DYLD_LIBRARY_PATH=$SHELLY_ORIGINAL_DYLD_LIBRARY_PATH

if [[ -d "$SHELLY_ENV" ]]; then
  for dir in $(command ls "${SHELLY_ENV}/"); do
    dir=${SHELLY_ENV}/$dir
    if [[ -d "$dir/" ]]; then
      binDir=$dir/bin
      if [[ -d "$binDir" ]]; then
        export PATH=$binDir:$PATH
      fi

      manDir=$dir/man
      if [[ -d "$manDir" ]]; then
        export MANPATH=$manDir:$MANPATH
      fi

      libDir=$dir/lib
      if [[ -d "$libDir" ]]; then
        export LD_LIBRARY_PATH=$libDir:$LD_LIBRARY_PATH
        export DYLD_LIBRARY_PATH=$libDir:$LD_LIBRARY_PATH
      fi

      pkgConfigDir=$dir/lib/pkgconfig
      if [[ -d "$pkgConfigDir" ]]; then
        export PKG_CONFIG_PATH=$pkgConfigDir:$PKG_CONFIG_PATH
      fi
    fi
  done
fi
