#!/usr/bin/env sh
#
# auto-install dependency packages using the systems package manager.
# this assumes you are running as root or are using sudo
#

USER="$(stat --format=%U .)"
apt-get install -y --force-yes clang llvm-dev libxml2-dev uuid-dev \
  libssl-dev bash patch make tar xz-utils bzip2 gzip sed cpio libbz2-dev \
  zlib1g-dev
