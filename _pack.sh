#!/bin/sh -x

# Copyright 2014-2017 Viktor Szakats <https://github.com/vszakats>
# See LICENSE.md

cd "$(dirname "$0")" || exit

# Detect host OS
case "$(uname)" in
  *_NT*)   os='win';;
  Linux*)  os='linux';;
  Darwin*) os='mac';;
  *BSD)    os='bsd';;
esac

_cdo="$(pwd)"

_fn="${_DST}/BUILD-README.txt"
cat << EOF > "${_fn}"
Visit the project page for details about these builds and the list of changes:

   ${_URL}
EOF
unix2dos -k "${_fn}"
touch -c -r "$1" "${_fn}"

_fn="${_DST}/BUILD-HOMEPAGE.url"
cat << EOF > "${_fn}"
[InternetShortcut]
URL=${_URL}
EOF
unix2dos -k "${_fn}"
touch -c -r "$1" "${_fn}"

find "${_DST}" -depth -type d -exec touch -c -r "$1" '{}' \;

(
  cd "${_DST}/.." || exit
  case "${os}" in
    win) find "${_BAS}" -exec attrib +A -R {} \;
  esac
  (
    cd "${_BAS}" || exit
    zip -q -9 -X -r - * > "${_cdo}/${_BAS}.zip"
  )
  touch -c -r "$1" "${_cdo}/${_BAS}.zip"
)

rm -f -r "${_DST:?}"
