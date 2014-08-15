#
# .profile
#

prependPaths() {
  for path in "$@"; do
    [[ -d ${path} ]] && PATH=${path}:${PATH}
  done
}

sourceExists() {
  for path in "$@"; do
    [[ -e ${path} ]] && source ${path}
  done
}

homeFromBin() {
  command=$1
  bin=$(which $command)
  if [ -n "$bin" ]; then
    bin=$(RealPath $bin)
    echo $(dirname $(dirname $bin))
  fi
}

#
# Setup shelly path.
#
source ~/Projects/shelly/bin/ShellyPath
prependPaths ~/Projects/shelly/bin

#
# Homebrew
#
# Some other configuration rely on brew being in the PATH, so it must be early.
#
prependPaths /usr/local/bin /usr/local/sbin
if [ -x "$(which brew)" ]; then
  export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
  sync-env-to-plist PKG_CONFIG_PATH
fi

#
# Nix
#
sourceExists ~/.nix-profile/etc/profile.d/nix.sh

#
# Source ~/.profile.d/*
#
for file in ~/.profile.d/*; do
  sourceExists ${file}
done

#
# Add ~/bin to PATH
#
prependPaths ~/bin

#
# Explicitly call the .bashrc
#
# if running bash
if [[ -n "$BASH_VERSION" ]]; then
  sourceExists ~/.bashrc
fi

sync-env-to-plist PATH
