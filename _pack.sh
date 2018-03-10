#!/bin/sh -x

# Copyright 2014-2018 Viktor Szakats <https://github.com/vszakats>
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

create_pack() {
  arch_ext="$2"
  (
    cd "${_DST}/.." || exit
    case "${os}" in
      win) find "${_BAS}" -exec attrib +A -R {} \;
    esac
    rm -f "${_cdo}/${_BAS}${arch_ext}"
    if [ "${arch_ext}" = '.zip' ]; then
    (
      cd "${_BAS}" || exit
      zip -q -9 -X -r "${_cdo}/${_BAS}${arch_ext}" -- *
    )
    elif [ "${arch_ext}" = '.tar.xz' ]; then
    (
      cd "${_BAS}" || exit
      tar -c ./* | xz > "${_cdo}/${_BAS}${arch_ext}"
    )
    elif [ "${arch_ext}" = '.7z' ]; then
      # NOTE: add -stl option after updating to 15.12 or upper
      7z a -bd -r -mx "${_cdo}/${_BAS}${arch_ext}" "${_BAS}/*" > /dev/null
    fi
    touch -c -r "$1" "${_cdo}/${_BAS}${arch_ext}"
  )
}

create_pack "$1" '.tar.xz'
create_pack "$1" '.zip'
create_pack "$1" '.7z'  # compatibility with curl download page

rm -f -r "${_DST:?}"
