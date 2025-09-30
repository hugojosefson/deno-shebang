# deno-shebang

Make TypeScript/JavaScript files truly standalone self-executable.

## What?!

Put this two line [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) header
in a Deno-compatible `.ts` or `.js` file, to make it standalone self-executable:

```typescript
#!/bin/sh
// 2>/dev/null;DENO_VERSION_RANGE="^2.5.2";DENO_RUN_ARGS="";set -e;V="$DENO_VERSION_RANGE";A="$DENO_RUN_ARGS";h(){ [ -x "$(command -v "$1" 2>&1)" ];};g(){ u="$([ "$(id -u)" != 0 ]&&echo sudo||:)";if h brew;then echo "brew install $1";elif h apt;then echo "($u apt update && $u DEBIAN_FRONTEND=noninteractive apt install -y $1)";elif h yum;then echo "$u yum install -y $1";elif h pacman;then echo "$u pacman -yS --noconfirm $1";elif h opkg-install;then echo "$u opkg-install $1";fi;};p(){ q="$(g "$1")";if [ -z "$q" ];then echo "Please install '$1' manually, then try again.">&2;exit 1;fi;eval "o=\"\$(set +o)\";set -x;$q;set +x;eval \"\$o\"">&2;};f(){ h "$1"||p "$1";};w(){ [ -n "$1" ] && "$1" -V >/dev/null 2>&1;};U="$(l=$(printf "%s" "$V"|wc -c);for i in $(seq 1 $l);do c=$(printf "%s" "$V"|cut -c $i);printf '%%%02X' "'$c";done)";D="$(w "$(command -v deno||:)"||:)";t(){ i="$(if h findmnt;then findmnt -Ononoexec,noro -ttmpfs -nboAVAIL,TARGET|sort -rn|while IFS=$'\n\t ' read -r a m;do [ "$a" -ge 150000000 ]&&[ -d "$m" ]&&printf %s "$m"&&break||:;done;fi)";printf %s "${i:-"${TMPDIR:-/tmp}"}";};s(){ deno eval "import{satisfies as e}from'https://deno.land/x/semver@v1.4.1/mod.ts';Deno.exit(e(Deno.version.deno,'$V')?0:1);">/dev/null 2>&1;};e(){ R="$(t)/deno-range-$V/bin";mkdir -p "$R";export PATH="$R:$PATH";s&&return;f curl;v="$(curl -sSfL "https://semver-version.deno.dev/api/github/denoland/deno/$U")";i="$(t)/deno-$v";ln -sf "$i/bin/deno" "$R/deno";s && return;f unzip;([ "${A#*-q}" != "$A" ]&&exec 2>/dev/null;curl -fsSL https://deno.land/install.sh|DENO_INSTALL="$i" sh -s $DENO_INSTALL_ARGS "$v"|grep -iv discord>&2);};e;exec deno run $A "$0" "$@"
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
// 2>/dev/null;DENO_VERSION_RANGE="^2.5.2";DENO_RUN_ARGS="";set -e;V="$DENO_VERSION_RANGE";A="$DENO_RUN_ARGS";h(){ [ -x "$(command -v "$1" 2>&1)" ];};g(){ u="$([ "$(id -u)" != 0 ]&&echo sudo||:)";if h brew;then echo "brew install $1";elif h apt;then echo "($u apt update && $u DEBIAN_FRONTEND=noninteractive apt install -y $1)";elif h yum;then echo "$u yum install -y $1";elif h pacman;then echo "$u pacman -yS --noconfirm $1";elif h opkg-install;then echo "$u opkg-install $1";fi;};p(){ q="$(g "$1")";if [ -z "$q" ];then echo "Please install '$1' manually, then try again.">&2;exit 1;fi;eval "o=\"\$(set +o)\";set -x;$q;set +x;eval \"\$o\"">&2;};f(){ h "$1"||p "$1";};w(){ [ -n "$1" ] && "$1" -V >/dev/null 2>&1;};U="$(l=$(printf "%s" "$V"|wc -c);for i in $(seq 1 $l);do c=$(printf "%s" "$V"|cut -c $i);printf '%%%02X' "'$c";done)";D="$(w "$(command -v deno||:)"||:)";t(){ i="$(if h findmnt;then findmnt -Ononoexec,noro -ttmpfs -nboAVAIL,TARGET|sort -rn|while IFS=$'\n\t ' read -r a m;do [ "$a" -ge 150000000 ]&&[ -d "$m" ]&&printf %s "$m"&&break||:;done;fi)";printf %s "${i:-"${TMPDIR:-/tmp}"}";};s(){ deno eval "import{satisfies as e}from'https://deno.land/x/semver@v1.4.1/mod.ts';Deno.exit(e(Deno.version.deno,'$V')?0:1);">/dev/null 2>&1;};e(){ R="$(t)/deno-range-$V/bin";mkdir -p "$R";export PATH="$R:$PATH";s&&return;f curl;v="$(curl -sSfL "https://semver-version.deno.dev/api/github/denoland/deno/$U")";i="$(t)/deno-$v";ln -sf "$i/bin/deno" "$R/deno";s && return;f unzip;([ "${A#*-q}" != "$A" ]&&exec 2>/dev/null;curl -fsSL https://deno.land/install.sh|DENO_INSTALL="$i" sh -s $DENO_INSTALL_ARGS "$v"|grep -iv discord>&2);};e;exec deno run $A "$0" "$@"
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
// 2>/dev/null;DENO_VERSION_RANGE="^2.5.2";DENO_RUN_ARGS="";set -e;V="$DENO_VERSION_RANGE";A="$DENO_RUN_ARGS";h(){ [ -x "$(command -v "$1" 2>&1)" ];};g(){ u="$([ "$(id -u)" != 0 ]&&echo sudo||:)";if h brew;then echo "brew install $1";elif h apt;then echo "($u apt update && $u DEBIAN_FRONTEND=noninteractive apt install -y $1)";elif h yum;then echo "$u yum install -y $1";elif h pacman;then echo "$u pacman -yS --noconfirm $1";elif h opkg-install;then echo "$u opkg-install $1";fi;};p(){ q="$(g "$1")";if [ -z "$q" ];then echo "Please install '$1' manually, then try again.">&2;exit 1;fi;eval "o=\"\$(set +o)\";set -x;$q;set +x;eval \"\$o\"">&2;};f(){ h "$1"||p "$1";};w(){ [ -n "$1" ] && "$1" -V >/dev/null 2>&1;};U="$(l=$(printf "%s" "$V"|wc -c);for i in $(seq 1 $l);do c=$(printf "%s" "$V"|cut -c $i);printf '%%%02X' "'$c";done)";D="$(w "$(command -v deno||:)"||:)";t(){ i="$(if h findmnt;then findmnt -Ononoexec,noro -ttmpfs -nboAVAIL,TARGET|sort -rn|while IFS=$'\n\t ' read -r a m;do [ "$a" -ge 150000000 ]&&[ -d "$m" ]&&printf %s "$m"&&break||:;done;fi)";printf %s "${i:-"${TMPDIR:-/tmp}"}";};z(){ m="$(command -v "$0"||true)";l="/* 2>/dev/null";! [ -z "$m" ]&&[ -r "$m" ]&&[ "$(head -c3 "$m")" = '#!/' ]&&(read x && read y &&[ "$x" = "#!/bin/sh" ]&&[ "$l" != "${y%"$l"*}" ])<"$m";};s(){ deno eval "import{satisfies as e}from'https://deno.land/x/semver@v1.4.1/mod.ts';Deno.exit(e(Deno.version.deno,'$V')?0:1);">/dev/null 2>&1;};e(){ R="$(t)/deno-range-$V/bin";mkdir -p "$R";export PATH="$R:$PATH";s&&return;f curl;v="$(curl -sSfL "https://semver-version.deno.dev/api/github/denoland/deno/$U")";i="$(t)/deno-$v";ln -sf "$i/bin/deno" "$R/deno";s && return;f unzip;([ "${A#*-q}" != "$A" ]&&exec 2>/dev/null;curl -fsSL https://deno.land/install.sh|DENO_INSTALL="$i" sh -s $DENO_INSTALL_ARGS "$v"|grep -iv discord>&2);};e;z&&exec deno run $A "$0" "$@";exec deno run $A - "$@"<<'//🔚'
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
