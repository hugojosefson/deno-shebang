# deno-shebang

Make any `.ts` or `.js` file truly self-executable.

Uses any locally installed [deno](https://deno.land/) if it can find it,
and if it satisfies the required version.

Otherwise, downloads correct version to a temp directory and runs the
script directly using that. Next time, it can use the same downloaded
`deno` quickly.

## Requirements

- `/bin/sh` a.k.a. Korn Shell, POSIX shell
- `unzip`
- `curl`

## How to use

### Step 1: Copy-paste shebang file header

Copy/paste this two-liner, into the beginning of your TypeScript file:

```typescript
#!/bin/sh
/* 2>/dev/null;DENO_VERSION_RANGE="^1.8";DENO_RUN_ARGS="";: "Via https://github.com/hugojosefson/deno-shebang CC BY 4.0";set -e;V="$DENO_VERSION_RANGE";A="$DENO_RUN_ARGS";U="$(expr "$(echo "$V"|curl -Gso/dev/null -w%{url_effective} --data-urlencode @- "")" : '..\(.*\)...')";D="$(command -v deno||true)";t(){ d="$(mktemp -d)";rmdir "${d}";dirname "${d}";};f(){ m="$(command -v "$0"||true)";l="/* 2>/dev/null";! [ -z $m ]&&[ -r $m ]&&[ "$(head -c3 "$m")" = '#!/' ]&&(read x && read y &&[ "$x" = "#!/bin/sh" ]&&[ "$l" != "${y%"$l"*}" ])<"$m";};a(){ [ -n $D ];};s(){ a&&[ -x "$R/deno" ]&&[ "$R/deno" = "$D" ]&&return;deno eval "import{satisfies as e}from'https://deno.land/x/semver@v1.3.0/mod.ts';Deno.exit(e(Deno.version.deno,'$V')?0:1);">/dev/null 2>&1;};g(){ curl -sSfL "https://api.mattandre.ws/semver/github/denoland/deno/$U";};e(){ R="$(t)/deno-range-$V/bin";mkdir -p "$R";export PATH="$R:$PATH";[ -x "$R/deno" ]&&return;a&&s&&([ -L "$R/deno" ]||ln -s "$D" "$R/deno")&&return;v="$(g)";i="$(t)/deno-$v";[ -L "$R/deno" ]||ln -s "$i/bin/deno" "$R/deno";s && return;curl -fsSL https://deno.land/x/install/install.sh|DENO_INSTALL="$i" sh -s "$v">/dev/null 2>&1;};e;f&&exec deno run $A "$0" "$@";exec deno run $A - "$@"<<'//🔚';//*/
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

At this point, it doesn't even need to be named `.ts`. You can remove
the extension, or name it something else.

## Configuration

In `DENO_VERSION_RANGE`, you can change to whatever
[semver](https://semver.org/) range of the
[Deno releases](https://github.com/denoland/deno/releases) your script
expects.

In `DENO_RUN_ARGS`, you may set any additional arguments to `deno run`,
such as `--allow-read=. --allow-network`.

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

If you want, you can run the script directly from its server using
`curl` and `sh`:

```sh
curl -s https://example.com/myscript.ts | sh
```

However, then you can't read from `stdin` like above. That's because
`deno` will be reading the script from `stdin`.

### curl | sh + arguments

When piping the script through `sh`, you can still use command-line
arguments. You just have to prefix them to `sh` with `-s --` like this:

```sh
curl -s https://example.com/myscript.ts | sh -s -- -i inputfile.txt -o outputfile.txt
```

## Full source code

You can view the full un-minified source code in
[src/deno-shebang.sh](src/deno-shebang.sh).

## Complete examples

See [example.min.ts](example.min.ts) and [example.ts](example.ts).

## License

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img
alt="Creative Commons License" style="border-width:0"
src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>

This project is licensed under <a rel="license"
href="http://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a>.

When you copy-paste the shebang two-liner, the license applies only to
that, and not anything else in your files. It already contains all the
details for compliance, wherever you paste it, so there is no need for
additional mentions, comments, nor LICENSE files. You are free to
license your work however you like, even commercially.

The two-line shebang and its license make no claim to any other code in
your files. As long as you copy-paste the shebang as-is, you're fine.
