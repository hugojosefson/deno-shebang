# deno-shebang

Make TypeScript/JavaScript files truly standalone self-executable.

## What?!

Put this two line [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) header
in a Deno-compatible `.ts` or `.js` file, to make it standalone self-executable:

```typescript
#!/bin/sh
/* 2>/dev/null

DENO_VERSION_RANGE="^2.5.1"
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

does_deno_on_path_satisfy() {
  deno eval "import { satisfies as s } from 'https://deno.land/x/semver@v1.4.1/mod.ts'; Deno.exit(s(Deno.version.deno,'${DENO_VERSION_RANGE}')?0:1);" >/dev/null 2>&1
}

get_satisfying_version() {
  ensure_command_installed curl
  curl -sSfL "https://semver-version.deno.dev/api/github/denoland/deno/${DENO_VERSION_RANGE_URL_ENCODED}" 2>/dev/null || echo 2.5.1
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
exec deno run ${DENO_RUN_ARGS} "$0" "$@"
//*/
```

It automatically downloads a correct version of the single
[deno](https://deno.land/) executable if needed, to a temp directory, and runs
the script directly using that.

However, if it finds `deno` already installed, and its version is satisfactory,
it uses that instead **without downloading deno at all**. For example from a
previous run, or from an otherwise installed `deno` by the user.

## Requirements

These are the only things you need, to run a script that has this shebang:

- `/bin/sh` a.k.a. Bourne shell, POSIX shell
- `curl`
- `unzip`

As you can see, ~~deno~~ needs NOT be installed.

## How to use

### Step 1: Copy-paste shebang file header

Copy/paste this two-liner, into the beginning of your TypeScript file:

```typescript
#!/bin/sh
/* 2>/dev/null

DENO_VERSION_RANGE="^2.5.1"
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

does_deno_on_path_satisfy() {
  deno eval "import { satisfies as s } from 'https://deno.land/x/semver@v1.4.1/mod.ts'; Deno.exit(s(Deno.version.deno,'${DENO_VERSION_RANGE}')?0:1);" >/dev/null 2>&1
}

get_satisfying_version() {
  ensure_command_installed curl
  curl -sSfL "https://semver-version.deno.dev/api/github/denoland/deno/${DENO_VERSION_RANGE_URL_ENCODED}" 2>/dev/null || echo 2.5.1
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
exec deno run ${DENO_RUN_ARGS} "$0" "$@"
//*/
```

### Step 2: `chmod` it

Set the executable flag on the file:

```sh
chmod +x myscript.ts
```

### Step 3: Run it!

```sh
./myscript.ts
```

At this point, it doesn't even need to be named `.ts`. You can remove the
extension, or name it something else.

## Configuration

In `DENO_VERSION_RANGE`, you can change to whatever
[Semantic Versioning range](https://devhints.io/semver) of the
[Deno releases](https://github.com/denoland/deno/releases) your script expects.

In `DENO_RUN_ARGS`, you may set any additional arguments to `deno run`, such as
`--allow-read=. --allow-network`.

## Features

### Read from stdin

Your script can read from `stdin`, and it will work fine.

For example:

```sh
cat inputfile.txt | ./myscript.ts
```

### Arguments

Your script is free to access command-line arguments.

```sh
./myscript.ts --help
./myscript.ts -i inputfile.txt -o outputfile.txt
```

### curl | sh

There is an extended variant of this shebang, which will also let you pipe your
script into `sh`:

```typescript
#!/bin/sh
/* 2>/dev/null

DENO_VERSION_RANGE="^2.5.1"
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
  path="$(command -v "$0" 2>/dev/null || true)" || return 1
  [ -n "$path" ] && [ -r "$path" ] || return 1
  {
    IFS= read -r first || return 1
    IFS= read -r second || return 1
  } < "$path"
  [ "$first" = "#!/bin/sh" ] || return 1
  case "$second" in
    '/*'* ) return 0 ;;
  esac
  return 1
}

does_deno_on_path_satisfy() {
  deno eval "import { satisfies as s } from 'https://deno.land/x/semver@v1.4.1/mod.ts'; Deno.exit(s(Deno.version.deno,'${DENO_VERSION_RANGE}')?0:1);" >/dev/null 2>&1
}

get_satisfying_version() {
  ensure_command_installed curl
  curl -sSfL "https://semver-version.deno.dev/api/github/denoland/deno/${DENO_VERSION_RANGE_URL_ENCODED}" 2>/dev/null || echo 2.5.1
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
```

Using this, you can run both run the script normally from a file, or directly
from the internet using `curl` and `sh`:

```sh
curl -s https://example.com/myscript.ts | sh
```

However, piping the script into `sh`, you can no longer read from `stdin` like
above. That's because `deno` will be reading the script from `stdin` instead.

### curl | sh + arguments

When piping the script through `sh`, you can still use command-line arguments.
You just have to prefix them to `sh` with `-s --` like this:

```sh
curl -s https://example.com/myscript.ts | sh -s -- -i inputfile.txt -o outputfile.txt
```

## Full source code

You can view the full un-minified source code in:

- [src/deno-shebang.sh](src/deno-shebang.sh)
- [src/deno-shebang-piped.sh](src/deno-shebang-piped.sh)

## Complete examples

- [example.ts](example.ts)
- [example.min.ts](example.min.ts)
- [example-piped.ts](example-piped.ts)
- [example-piped.min.ts](example-piped.min.ts)

## License

CC0-1.0

<p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/hugojosefson/deno-shebang">deno-shebang</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://www.hugojosefson.com">Hugo Josefson</a> is marked with <a href="http://creativecommons.org/publicdomain/zero/1.0?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC0 1.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/zero.svg?ref=chooser-v1"></a></p>
