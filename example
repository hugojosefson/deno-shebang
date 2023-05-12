#!/bin/sh
/* 2>/dev/null

DENO_VERSION_RANGE="^1.33.3"
DENO_RUN_ARGS="--quiet"
# DENO_RUN_ARGS="--quiet --allow-all --unstable"  # <-- depending on what you need

set -e

has_command() {
  [ -x "$(command -v "$1" 2>&1)" ]
}

needs_sudo() {
  [ "$(id -u)" != 0 ]
}

get_package_install_command() {
  package_name="$1"
  # shellcheck disable=SC2015
  any_sudo="$(needs_sudo && echo sudo || true)"
  if has_command brew; then
    echo "brew install ${package_name}"
  elif has_command apt; then
    echo "(${any_sudo} apt update && ${any_sudo} DEBIAN_FRONTEND=noninteractive apt install -y ${package_name})"
  elif has_command yum; then
    echo "${any_sudo} yum install -y ${package_name}"
  elif has_command pacman; then
    echo "${any_sudo} pacman -yS --noconfirm ${package_name}"
  elif has_command opkg-install; then
    echo "${any_sudo} opkg-install ${package_name}"
  fi
}

install_package() {
  package_name="$1"
  installer="$(get_package_install_command "${package_name}")"
  if [ -z "${installer}" ]; then
    echo "Please install '${package_name}' manually, then try again." >&2
    exit 1
  fi
  eval "saved_opts=\"\$(set +o)\"; set -x; ${installer} >&2; set +x; eval \"\${saved_opts}\"" >&2
}

ensure_command_installed() {
  if ! has_command "$1"; then
    install_package "$1"
  fi
}

DENO_VERSION_RANGE_URL_ENCODED="$(printf "%s" "${DENO_VERSION_RANGE}" | xxd -p | tr -d '\n' | sed 's/\(..\)/%\1/g')"
DEFAULT_DENO="$(command -v deno || true)"

get_tmp_dir() {
  tmp_tmp_file="$(mktemp)"
  rm "${tmp_tmp_file}"
  dirname "${tmp_tmp_file}"
}

is_any_deno_installed() {
  [ -n "${DEFAULT_DENO}" ]
}

is_deno_version_satisfied() {
  is_any_deno_installed && [ -x "${DENO_RANGE_DIR}/deno" ] && [ "${DENO_RANGE_DIR}/deno" = "${DEFAULT_DENO}" ] && return
  deno eval "import{satisfies as e}from'https://deno.land/x/semver@v1.4.1/mod.ts';Deno.exit(e(Deno.version.deno,'${DENO_VERSION_RANGE}')?0:1);" >/dev/null 2>&1
}

get_satisfying_version() {
  ensure_command_installed curl
  curl -sSfL "https://semver-version.deno.dev/api/github/denoland/deno/${DENO_VERSION_RANGE_URL_ENCODED}"
}

ensure_deno_installed() {
  DENO_RANGE_DIR="$(get_tmp_dir)/deno-range-${DENO_VERSION_RANGE}/bin"
  mkdir -p "${DENO_RANGE_DIR}"
  export PATH="${DENO_RANGE_DIR}:${PATH}"

  [ -x "${DENO_RANGE_DIR}/deno" ] && return
  is_any_deno_installed && is_deno_version_satisfied && ([ -L "${DENO_RANGE_DIR}/deno" ] || ln -s "${DEFAULT_DENO}" "${DENO_RANGE_DIR}/deno") && return

  DENO_VERSION="$(get_satisfying_version)"
  DENO_INSTALL="$(get_tmp_dir)/deno-${DENO_VERSION}"
  [ -L "${DENO_RANGE_DIR}/deno" ] || ln -s "${DENO_INSTALL}/bin/deno" "${DENO_RANGE_DIR}/deno"

  is_deno_version_satisfied && return

  ensure_command_installed unzip
  ensure_command_installed curl

  export DENO_INSTALL
  (
    if [ "${DENO_RUN_ARGS#*-q}" != "${DENO_RUN_ARGS}" ]; then
      exec 2>/dev/null
    fi
    curl -fsSL https://deno.land/install.sh | sh -s ${DENO_INSTALL_ARGS} "${DENO_VERSION}" >&2
  )
}

ensure_deno_installed

exec "${DENO_RANGE_DIR}/deno" run ${DENO_RUN_ARGS} "$0" "$@"
//*/
import { readAll } from "https://deno.land/std@0.187.0/streams/read_all.ts";

console.log(
  `This 🦕 is deno ${Deno.version.deno}, called with args:\n${
    JSON.stringify(Deno.args, null, 2)
  }`,
);

if (Deno.isatty(Deno.stdin.rid)) {
  console.log("Type some text, then on a separate empty line, press ctrl+d.");
}
const stdin = new TextDecoder().decode(await readAll(Deno.stdin));
console.log(JSON.stringify({ stdin }, null, 2));
