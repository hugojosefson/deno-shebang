# deno-shebang

Universally self-executable TypeScript/JavaScript file.

Uses [deno](https://deno.land/), even if deno is not installed.

##  Requirements

- `/bin/sh` a.k.a. Korn Shell
- `unzip`
- `curl`

## Copy-paste shebang file header

Copy/paste this into the beginning of your TypeScript file:

```typescript
#!/bin/sh
/* 2>/dev/null

DENO_VERSION_RANGE="^1.8"
# DENO_RUN_ARGS="--allow-all --unstable"  # <-- depending on what you need

set -e;V="$DENO_VERSION_RANGE";A="$DENO_RUN_ARGS";U="$(expr "$(echo "$V"|curl -Gso/dev/null -w%{url_effective} --data-urlencode @- "")" : '..\(.*\)...')";D="$(command -v deno||true)";t(){ d="$(mktemp -d)";rmdir "${d}";dirname "${d}";};f(){ m="$(command -v "$0"||true)";! [ -z $m ]&&[ -r $m ]&&[ "$(head -c3 "$m")" = '#!/' ]&&[ "$(head -c24 "$m")" = '#!/bin/sh
/* 2>/dev/null' ];};a(){ [ -n $D ];};s(){ a&&[ -x "$R/deno" ]&&[ "$R/deno" = "$D" ]&&return;deno eval "import{satisfies as e}from'https://deno.land/x/semver@v1.3.0/mod.ts';Deno.exit(e(Deno.version.deno,'$V')?0:1);">/dev/null 2>&1;};g(){ curl -sSfL "https://api.mattandre.ws/semver/github/denoland/deno/$U";};e(){ R="$(t)/deno-range-$V/bin";mkdir -p "$R";export PATH="$R:$PATH";[ -x "$R/deno" ]&&return;a&&s&&([ -L "$R/deno" ]||ln -s "$D" "$R/deno")&&return;v="$(g)";i="$(t)/deno-$v";[ -L "$R/deno" ]||ln -s "$i/bin/deno" "$R/deno";s && return;curl -fsSL https://deno.land/x/install/install.sh|DENO_INSTALL="$i" sh -s "$v">/dev/null 2>&1;};e;f&&exec deno run $A "$0" "$@";exec deno run $A - "$@"<<'//🔚'
//*/
```

Or, if you prefer it legible:

```sh
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
```

## Complete example

See [example.ts](example.ts).
