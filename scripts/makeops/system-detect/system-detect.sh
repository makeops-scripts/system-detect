#!/bin/sh -e

# Detect *nix operating system info.
#
# Usage:
#   $ eval "$(./system-detect.sh)"
#   $ env | grep ^SYSTEM_

# ==============================================================================

# Set defalut values
SYSTEM_NAME=$(uname)
SYSTEM_DIST=
SYSTEM_DIST_BASED_ON=
SYSTEM_PSEUDO_NAME=
SYSTEM_VERSION=
SYSTEM_ARCH=$(uname -m)
SYSTEM_ARCH_NAME= # Can be "i386" or "amd64" or "arm64"
SYSTEM_KERNEL=$(uname -r)
SYSTEM_CONTAINER="false"

# Detect if macOS
if uname -s | grep -iq "darwin"; then

  SYSTEM_NAME="unix"
  SYSTEM_DIST="macos"
  SYSTEM_DIST_BASED_ON="bsd"
  [ "$(sw_vers -productVersion | grep -c 10.10)" -gt 0 ] && SYSTEM_PSEUDO_NAME="Yosemite"
  [ "$(sw_vers -productVersion | grep -c 10.11)" -gt 0 ] && SYSTEM_PSEUDO_NAME="El Capitan"
  [ "$(sw_vers -productVersion | grep -c 10.12)" -gt 0 ] && SYSTEM_PSEUDO_NAME="Sierra"
  [ "$(sw_vers -productVersion | grep -c 10.13)" -gt 0 ] && SYSTEM_PSEUDO_NAME="High Sierra"
  [ "$(sw_vers -productVersion | grep -c 10.14)" -gt 0 ] && SYSTEM_PSEUDO_NAME="Mojave"
  [ "$(sw_vers -productVersion | grep -c 10.15)" -gt 0 ] && SYSTEM_PSEUDO_NAME="Catalina"
  [ "$(sw_vers -productVersion | grep -c 11.)" -gt 0 ] && SYSTEM_PSEUDO_NAME="Big Sur"
  [ "$(sw_vers -productVersion | grep -c 12.)" -gt 0 ] && SYSTEM_PSEUDO_NAME="Monterey"
  SYSTEM_VERSION=$(sw_vers -productVersion)
  SYSTEM_ARCH_NAME="i386"
  [ "$(uname -m | grep -c x86_64)" -gt 0 ] && SYSTEM_ARCH_NAME="amd64"
  [ "$(uname -m | grep -c arm)" -gt 0 ] && SYSTEM_ARCH_NAME="arm64"

# Detect if Debian family
elif [ -f /etc/debian_version ]; then

  id="$(grep "^ID=" /etc/os-release | awk -F= '{ print $2 }')"
  SYSTEM_DIST="$id"
  if [ "$SYSTEM_DIST" = "debian" ]; then
    SYSTEM_PSEUDO_NAME=$(grep "^VERSION=" /etc/os-release | awk -F= '{ print $2 }' | grep -oEi '[a-z]+')
    SYSTEM_VERSION=$(cat /etc/debian_version)
  elif [ "$SYSTEM_DIST" = "ubuntu" ]; then
    SYSTEM_PSEUDO_NAME=$(grep '^DISTRIB_CODENAME' /etc/lsb-release | awk -F= '{ print $2 }')
    SYSTEM_VERSION=$(grep '^DISTRIB_RELEASE' /etc/lsb-release | awk -F= '{ print $2 }')
  elif [ "$SYSTEM_DIST" = "kali" ]; then
    SYSTEM_PSEUDO_NAME=$(grep "^PRETTY_NAME=" /etc/os-release | awk -F= '{ print $2 }' | sed s/\"//g | awk '{print $NF}')
    SYSTEM_VERSION=$(grep "^VERSION=" /etc/os-release | awk -F= '{ print $2 }' | sed s/\"//g)
  fi
  SYSTEM_DIST_BASED_ON="debian"
  SYSTEM_ARCH_NAME="i386"
  uname -m | grep -q 64 && SYSTEM_ARCH_NAME="amd64"
  { uname -m | grep -q "arm[_]*64" || uname -m | grep -q "aarch64"; } && SYSTEM_ARCH_NAME="arm64"

# Detect if RedHat family
elif [ -f /etc/redhat-release ]; then

  SYSTEM_DIST=$(sed s/\ release.*// /etc/redhat-release | tr "[:upper:]" "[:lower:]")
  echo "$SYSTEM_DIST" | grep -q "red" && SYSTEM_DIST="redhat"
  echo "$SYSTEM_DIST" | grep -q "centos" && SYSTEM_DIST="centos"
  SYSTEM_DIST_BASED_ON="redhat"
  SYSTEM_PSEUDO_NAME=$(sed s/.*\(// /etc/redhat-release | sed s/\)//)
  SYSTEM_VERSION=$(sed s/.*release\ // /etc/redhat-release | sed s/\ .*//)
  SYSTEM_ARCH_NAME="i386"
  uname -m | grep -q 64 && SYSTEM_ARCH_NAME="amd64"
  { uname -m | grep -q "arm[_]*64" || uname -m | grep -q "aarch64"; } && SYSTEM_ARCH_NAME="arm64"

# Detect if Alpine
elif which apk > /dev/null 2>&1; then

  SYSTEM_DIST="alpine"
  SYSTEM_DIST_BASED_ON="alpine"
  SYSTEM_PSEUDO_NAME=
  SYSTEM_VERSION=$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' /etc/alpine-release)
  SYSTEM_ARCH_NAME="i386"
  uname -m | grep -q 64 && SYSTEM_ARCH_NAME="amd64"
  { uname -m | grep -q "arm[_]*64" || uname -m | grep -q "aarch64"; } && SYSTEM_ARCH_NAME="arm64"

# Detect if Busybox
elif which busybox > /dev/null 2>&1; then

  SYSTEM_DIST="busybox"
  SYSTEM_DIST_BASED_ON="busybox"
  SYSTEM_PSEUDO_NAME=
  SYSTEM_VERSION=$(busybox | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  SYSTEM_ARCH_NAME="i386"
  uname -m | grep -q 64 && SYSTEM_ARCH_NAME="amd64"
  { uname -m | grep -q "arm[_]*64" || uname -m | grep -q "aarch64"; } && SYSTEM_ARCH_NAME="arm64"

fi

# Detect if inside Docker
if grep -qi docker /proc/1/cgroup 2> /dev/null || head -n 1 /proc/1/sched 2> /dev/null | grep -q sh; then
  SYSTEM_CONTAINER="true"
fi

# Print variables exports
echo "export SYSTEM_NAME=$(echo "$SYSTEM_NAME" | tr "[:upper:]" "[:lower:]" | tr " " "_")"
echo "export SYSTEM_DIST=$(echo "$SYSTEM_DIST" | tr "[:upper:]" "[:lower:]" | tr " " "_")"
echo "export SYSTEM_DIST_BASED_ON=$(echo "$SYSTEM_DIST_BASED_ON" | tr "[:upper:]" "[:lower:]" | tr " " "_")"
echo "export SYSTEM_PSEUDO_NAME=$(echo "$SYSTEM_PSEUDO_NAME" | tr "[:upper:]" "[:lower:]" | tr " " "_")"
echo "export SYSTEM_VERSION=$(echo "$SYSTEM_VERSION" | tr "[:upper:]" "[:lower:]" | tr " " "_")"
echo "export SYSTEM_ARCH=$(echo "$SYSTEM_ARCH" | tr "[:upper:]" "[:lower:]" | tr " " "_")"
echo "export SYSTEM_ARCH_NAME=$(echo "$SYSTEM_ARCH_NAME" | tr "[:upper:]" "[:lower:]" | tr " " "_")"
echo "export SYSTEM_KERNEL=$(echo "$SYSTEM_KERNEL" | tr "[:upper:]" "[:lower:]" | tr " " "_")"
echo "export SYSTEM_CONTAINER=$(echo "$SYSTEM_CONTAINER" | tr "[:upper:]" "[:lower:]" | tr " " "_")"