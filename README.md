# deno-shebang

Make any `.ts` or `.js` file self-executable.

Uses locally installed [deno](https://deno.land/) if found and satisfies the required version. If not, downloads correct version to a temp directory and runs the script directly. Next time, it can use the same downloaded `deno` quickly.

## Requirements

- `/bin/sh` a.k.a. Korn Shell, POSIX shell
- `unzip`
- `curl`

## How to

### chmod it

Set the executable flag on the file:

```sh
chmod +x myfile.ts
```

### Copy-paste shebang file header

Copy/paste this two-liner, into the beginning of your TypeScript file:

```typescript
#!/bin/sh
/* 2>/dev/null;DENO_VERSION_RANGE="^1.8";DENO_RUN_ARGS="";set -e;V="$DENO_VERSION_RANGE";A="$DENO_RUN_ARGS";U="$(expr "$(echo "$V"|curl -Gso/dev/null -w%{url_effective} --data-urlencode @- "")" : '..\(.*\)...')";D="$(command -v deno||true)";t(){ d="$(mktemp -d)";rmdir "${d}";dirname "${d}";};f(){ m="$(command -v "$0"||true)";l="/* 2>/dev/null";! [ -z $m ]&&[ -r $m ]&&[ "$(head -c3 "$m")" = '#!/' ]&&(read x && read y &&[ "$x" = "#!/bin/sh" ]&&[ "$l" != "${y%"$l"*}" ])<"$m";};a(){ [ -n $D ];};s(){ a&&[ -x "$R/deno" ]&&[ "$R/deno" = "$D" ]&&return;deno eval "import{satisfies as e}from'https://deno.land/x/semver@v1.3.0/mod.ts';Deno.exit(e(Deno.version.deno,'$V')?0:1);">/dev/null 2>&1;};g(){ curl -sSfL "https://api.mattandre.ws/semver/github/denoland/deno/$U";};e(){ R="$(t)/deno-range-$V/bin";mkdir -p "$R";export PATH="$R:$PATH";[ -x "$R/deno" ]&&return;a&&s&&([ -L "$R/deno" ]||ln -s "$D" "$R/deno")&&return;v="$(g)";i="$(t)/deno-$v";[ -L "$R/deno" ]||ln -s "$i/bin/deno" "$R/deno";s && return;curl -fsSL https://deno.land/x/install/install.sh|DENO_INSTALL="$i" sh -s "$v">/dev/null 2>&1;};e;f&&exec deno run $A "$0" "$@";exec deno run $A - "$@"<<'//🔚';//*/
```

In `DENO_VERSION_RANGE`, you can set whatever
[semver](https://semver.org/) version of the
[Deno releases](https://github.com/denoland/deno/releases) your script
expects.

In `DENO_RUN_ARGS`, you may set any additional arguments to `deno run`,
such as `--allow-read=. --allow-network`.

## Full source code

You can view the full un-minified source code in [src/deno-shebang.sh](src/deno-shebang.sh).

## Complete examples

See [example.min.ts](example.min.ts) and [example.ts](example.ts).
