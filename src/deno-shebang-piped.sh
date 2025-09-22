#!/bin/sh
/* 2>/dev/null

DENO_VERSION_RANGE="^2.5.2"
DENO_RUN_ARGS=""
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
  if needs_sudo && ! has_command sudo; then
    # sudo needed but not available, fall back to manual install
    return
  fi
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

uri_encode() {
    str="$1"
    len=$(printf "%s" "$str" | wc -c)
    for i in $(seq 1 $len); do
        char=$(printf "%s" "$str" | cut -c $i)
        printf '%%%02X' "'$char"
    done
}

does_deno_work() {
  deno="$1"
  [ -n "${deno}" ] && "${deno}" --version >/dev/null 2>&1
}

DENO_VERSION_RANGE_URL_ENCODED="$(uri_encode "${DENO_VERSION_RANGE}")"
DEFAULT_DENO="$(does_deno_work "$(command -v deno)" ||:)"

get_tmp_dir() {
  tmp_dir="$(
  # for each tmpfs filesystem, sort by available space. for each line, read available space and target mount point, filtering out any trailing whitespace from each variable. if the available bytes is at least 150000000, check if the mount point is a directory. if so, use it.
  if has_command findmnt; then
    findmnt -Ononoexec,noro -ttmpfs -nboAVAIL,TARGET | sort -rn | \
    while IFS=$'\n\t ' read -r avail target; do
      if [ "${avail}" -ge 150000000 ] && [ -d "${target}" ]; then
        printf "%s" "${target}"
        break
      fi
    done
  fi)"

  printf "%s" "${tmp_dir:-"${TMPDIR:-/tmp}"}"
}

is_run_from_file(){
  line2="/* 2>/dev/null"
  me="$(command -v "$0" || true)"
  ! [ -z $me ] \
  && [ -r $me ] \
  && [ "$(head -c 3 "$me")" = '#!/' ] \
  && (read x && read y && [ "$x" = "#!/bin/sh" ] && [ "$line2" != "${y%"$line2"*}" ]) < "${me}"
}

does_deno_on_path_satisfy() {
  deno eval "import{satisfies as e}from'https://deno.land/x/semver@v1.4.1/mod.ts';Deno.exit(e(Deno.version.deno,'${DENO_VERSION_RANGE}')?0:1);" >/dev/null 2>&1
}

get_satisfying_version() {
  ensure_command_installed curl
  curl -sSfL "https://semver-version.deno.dev/api/github/denoland/deno/${DENO_VERSION_RANGE_URL_ENCODED}"
}

ensure_deno_installed_and_first_on_path() {
  DENO_RANGE_DIR="$(get_tmp_dir)/deno-range-${DENO_VERSION_RANGE}/bin"
  mkdir -p "${DENO_RANGE_DIR}"
  export PATH="${DENO_RANGE_DIR}:${PATH}"
  does_deno_on_path_satisfy && return

  DENO_VERSION="$(get_satisfying_version)"
  DENO_INSTALL="$(get_tmp_dir)/deno-${DENO_VERSION}"
  ln -fs "${DENO_INSTALL}/bin/deno" "${DENO_RANGE_DIR}/deno"
  does_deno_on_path_satisfy && return

  ensure_command_installed unzip
  ensure_command_installed curl

  export DENO_INSTALL
  (
    if [ "${DENO_RUN_ARGS#*-q}" != "${DENO_RUN_ARGS}" ]; then
      exec 2>/dev/null
    fi
    curl -fsSL https://deno.land/install.sh | sh -s ${DENO_INSTALL_ARGS} "${DENO_VERSION}" | grep -iv discord >&2
  )
}

ensure_deno_installed_and_first_on_path
is_run_from_file && exec deno run ${DENO_RUN_ARGS} "$0" "$@"
exec deno run ${DENO_RUN_ARGS} - "$@" <<'//🔚'
//*/
