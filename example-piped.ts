#!/bin/sh
/* 2>/dev/null

DENO_VERSION_RANGE="^1.25"
DENO_RUN_ARGS="--quiet"
# DENO_RUN_ARGS="--quiet --allow-all --unstable"  # <-- depending on what you need

set -e

has_command() {
  [ -x "$(command -v "$1" 2>&1)" ]
}

needs_sudo() {
  [ "$(id -u)" != 0 ]
}

get_package_installer() {
  any_sudo="$(needs_sudo && echo sudo)"
  if has_command brew; then
    echo "brew install"
  elif has_command apt; then
    echo "${any_sudo} apt update && ${any_sudo} DEBIAN_FRONTEND=noninteractive apt install -y"
  elif has_command yum; then
    echo "${any_sudo} yum install -y"
  elif has_command pacman; then
    echo "${any_sudo} pacman -yS --noconfirm"
  fi
}

install_package() {
  package_name="$1"
  installer="$(get_package_installer)"
  if [ -z "${installer}" ]; then
    echo "Please install '${package_name}' manually, then try again." >&2
    exit 1
  fi
  eval "set -x; ${installer} ${package_name}; set +x" >&2
}

ensure_command_installed() {
  if ! has_command "$1"; then
    install_package "$1"
  fi
}

ensure_command_installed curl
DENO_VERSION_RANGE_URL_ENCODED="$(expr "$(echo "${DENO_VERSION_RANGE}" | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "")" : '..\(.*\)...')"
DEFAULT_DENO="$(command -v deno || true)"

get_tmp_dir() {
  tmp_tmp_file="$(mktemp)"
  rm "${tmp_tmp_file}"
  dirname "${tmp_tmp_file}"
}

is_run_from_file(){
  line2="/* 2>/dev/null"
  me="$(command -v "$0" || true)"
  ! [ -z $me ] \
  && [ -r $me ] \
  && [ "$(head -c 3 "$me")" = '#!/' ] \
  && (read x && read y && [ "$x" = "#!/bin/sh" ] && [ "$line2" != "${y%"$line2"*}" ]) < "${me}"
}

is_any_deno_installed() {
  ! [ -z $DEFAULT_DENO ]
}

is_deno_version_satisfied() {
  is_any_deno_installed && [ -x "${DENO_RANGE_DIR}/deno" ] && [ "${DENO_RANGE_DIR}/deno" = "${DEFAULT_DENO}" ] && return
  deno eval "import{satisfies as e}from'https://deno.land/x/semver@v1.4.0/mod.ts';Deno.exit(e(Deno.version.deno,'${DENO_VERSION_RANGE}')?0:1);" >/dev/null 2>&1
}

get_satisfying_version() {
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

  export DENO_INSTALL
  (
    if [ "${DENO_RUN_ARGS#*-q}" != "${DENO_RUN_ARGS}" ]; then
      exec 2>/dev/null
    fi
    curl -fsSL https://deno.land/install.sh | sh -s ${DENO_INSTALL_ARGS} "${DENO_VERSION}" >&2
  )
}

ensure_deno_installed

is_run_from_file && exec "${DENO_RANGE_DIR}/deno" run ${DENO_RUN_ARGS} "$0" "$@"
exec "${DENO_RANGE_DIR}/deno" run ${DENO_RUN_ARGS} - "$@" <<'//🔚'
//*/
import { readAll } from "https://deno.land/std@0.155.0/streams/conversion.ts";

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
//🔚
