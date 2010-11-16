# Make sure prompt is exported to subshells.
export PS1

app_path=~/bin/app-path
[[ -f ${app_path} ]] && . ${app_path}

# MacPorts Installer addition on 2010-04-29_at_06:37:58: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

# On Mac OS seem to need to explicitly call the .bashrc
bashrc=~/.bashrc
[[ $(uname) == 'Darwin' && -f ${bashrc} ]] && . ${bashrc}

PATH=~/bin:$PATH

if [[ $(uname) == 'Darwin' ]]; then
  export JAVA_HOME=/Library/Java/Home
fi
export SCALA_HOME=~/.shelly/apps/scala
export M2_HOME=~/.shell/apps/maven
SATHER_HOME=/home/steshaw/.shelly/apps/sather

sync-env-to-plist PATH JAVA_HOME SCALA_HOME M2_HOME
