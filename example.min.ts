#!/bin/sh
/* 2>/dev/null; set -e

DENO_VERSION_RANGE="^1.8"
# DENO_ARGS="--allow-all --unstable"

DENO_VERSION_RANGE_URL_ENCODED="$(expr "$(echo "${DENO_VERSION_RANGE}" | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "")" : '..\(.*\)...')"

get_tmp_dir(){
  tmp_tmp_dir="$(mktemp -d)"
  rmdir "${tmp_tmp_dir}"
  dirname "${tmp_tmp_dir}"
}

is_any_deno_installed() {
  command -v deno >/dev/null
}

is_deno_version_satisfied(){
  is_any_deno_installed && [ -x "${DENO_RANGE_SYMLINK}/bin/deno" ] && [ "${DENO_RANGE_SYMLINK}/bin/deno" = "$(command -v deno)" ] && return
  deno eval "import{satisfies as e}from'https://deno.land/x/semver@v1.3.0/mod.ts';Deno.exit(e(Deno.version.deno,'${DENO_VERSION_RANGE}')?0:1);" >/dev/null 2>&1
}

get_satisfying_version(){
  curl -sSfL "https://api.mattandre.ws/semver/github/denoland/deno/${DENO_VERSION_RANGE_URL_ENCODED}"
}

ensure_deno_installed(){
  if is_any_deno_installed; then
    if is_deno_version_satisfied; then
      return
    fi
  fi

  DENO_RANGE_SYMLINK="$(get_tmp_dir)/deno-range-${DENO_VERSION_RANGE}"
  export PATH="${DENO_RANGE_SYMLINK}/bin:${PATH}"

  is_deno_version_satisfied && return

  DENO_VERSION="$(get_satisfying_version)"
  DENO_INSTALL="$(get_tmp_dir)/deno-${DENO_VERSION}"
  [ -L "${DENO_RANGE_SYMLINK}" ] || ln -s "${DENO_INSTALL}" "${DENO_RANGE_SYMLINK}"

  is_deno_version_satisfied && return

  export DENO_INSTALL
  curl -fsSL https://deno.land/x/install/install.sh | sh -s "${DENO_VERSION}" >/dev/null 2>&1
}

ensure_deno_installed
exec deno run ${DENO_ARGS} "$0" "$@"
*/

console.log(`🦕: This is deno ${Deno.version.deno}.`)
