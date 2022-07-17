#!/bin/sh
/* 2>/dev/null

DENO_VERSION_RANGE="^1.20"
DENO_RUN_ARGS="--quiet"
# DENO_RUN_ARGS="--quiet --allow-all --unstable"  # <-- depending on what you need

set -e

DENO_VERSION_RANGE_URL_ENCODED="$(expr "$(echo "${DENO_VERSION_RANGE}" | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "")" : '..\(.*\)...')"
DEFAULT_DENO="$(command -v deno || true)"

get_tmp_dir(){
  tmp_tmp_file="$(mktemp)"
  rm "${tmp_tmp_file}"
  dirname "${tmp_tmp_file}"
}

is_any_deno_installed() {
  ! [ -z $DEFAULT_DENO ]
}

is_deno_version_satisfied(){
  is_any_deno_installed && [ -x "${DENO_RANGE_DIR}/deno" ] && [ "${DENO_RANGE_DIR}/deno" = "${DEFAULT_DENO}" ] && return
  deno eval "import{satisfies as e}from'https://deno.land/x/semver@v1.4.0/mod.ts';Deno.exit(e(Deno.version.deno,'${DENO_VERSION_RANGE}')?0:1);" >/dev/null 2>&1
}

get_satisfying_version(){
  curl -sSfL "https://semver-version.deno.dev/api/github/denoland/deno/${DENO_VERSION_RANGE_URL_ENCODED}"
}

ensure_deno_installed(){
  DENO_RANGE_DIR="$(get_tmp_dir)/deno-range-${DENO_VERSION_RANGE}/bin"
  mkdir -p "${DENO_RANGE_DIR}"
  export PATH="${DENO_RANGE_DIR}:${PATH}"

  [ -x "${DENO_RANGE_DIR}/deno" ] && return
  is_any_deno_installed && is_deno_version_satisfied && ([ -L "${DENO_RANGE_DIR}/deno" ] || ln -s "${DEFAULT_DENO}" "${DENO_RANGE_DIR}/deno") && return

  DENO_VERSION="$(get_satisfying_version)"
  DENO_INSTALL="$(get_tmp_dir)/deno-${DENO_VERSION}"
  [ -L "${DENO_RANGE_DIR}/deno" ] || ln -s "${DENO_INSTALL}/bin/deno" "${DENO_RANGE_DIR}/deno"

  is_deno_version_satisfied && return

  export DENO_INSTALL
  (
    if [ "${DENO_RUN_ARGS#*-q}" != "${DENO_RUN_ARGS}" ]; then
      exec 2>/dev/null
    fi
    curl -fsSL https://deno.land/install.sh | sh -s ${DENO_INSTALL_ARGS} "${DENO_VERSION}" >&2
  )
}

ensure_deno_installed

exec deno run ${DENO_RUN_ARGS} "$0" "$@"
//*/
