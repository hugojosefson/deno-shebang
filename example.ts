#!/bin/sh
/* 2>/dev/null; set -e

DENO_VERSION_RANGE="^1.8"
# DENO_ARGS="--allow-all --unstable"

DENO_VERSION_RANGE_URL_ENCODED="$(expr "$(echo "${DENO_VERSION_RANGE}" | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "")" : '..\(.*\)...')"
DEFAULT_DENO="$(command -v deno || true)"

get_tmp_dir(){
  tmp_tmp_dir="$(mktemp -d)"
  rmdir "${tmp_tmp_dir}"
  dirname "${tmp_tmp_dir}"
}

is_run_from_file(){
  me="$(command -v "$0" || true)"
  ! [ -z $me ] && [ -r $me ] && [ "$(head -c 3 "$me")" = '#!/' ] && [ "$(head -c 24 "$me")" = '#!/bin/sh
/* 2>/dev/null' ]
}

is_any_deno_installed() {
  ! [ -z $DEFAULT_DENO ]
}

is_deno_version_satisfied(){
  is_any_deno_installed && [ -x "${DENO_RANGE_DIR}/deno" ] && [ "${DENO_RANGE_DIR}/deno" = "${DEFAULT_DENO}" ] && return
  deno eval "import{satisfies as e}from'https://deno.land/x/semver@v1.3.0/mod.ts';Deno.exit(e(Deno.version.deno,'${DENO_VERSION_RANGE}')?0:1);" >/dev/null 2>&1
}

get_satisfying_version(){
  curl -sSfL "https://api.mattandre.ws/semver/github/denoland/deno/${DENO_VERSION_RANGE_URL_ENCODED}"
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
  curl -fsSL https://deno.land/x/install/install.sh | sh -s "${DENO_VERSION}" >/dev/null 2>&1
}

ensure_deno_installed

is_run_from_file && exec deno run ${DENO_ARGS} "$0" "$@"
exec deno run ${DENO_ARGS} - "$@" <<'//🔚'
//*/

console.log(`This 🦕 is deno ${Deno.version.deno}, called with args:\n${JSON.stringify(Deno.args, null, 2)}`)

const stdin = new TextDecoder().decode(await Deno.readAll(Deno.stdin));
console.log(JSON.stringify({stdin}, null, 2))