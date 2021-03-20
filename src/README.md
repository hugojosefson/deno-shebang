# deno-shebang

Make TypeScript/JavaScript files truly self-executable.

## What?!

By putting this two line
[shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) header in a
Deno-compatible `.ts` or `.js` file, you make it self-executable.

It automatically downloads a correct version of the single
[deno](https://deno.land/) executable if needed, to a temp directory,
and runs the script directly using that.

However, if it finds `deno` already installed, and its version is
satisfactory, it uses that instead **without downloading deno at all**.
For example from a previous run, or from an otherwise installed `deno`
by the user.


## Requirements

These are the only things you need to run a script that has this
shebang:

- `/bin/sh` a.k.a. Korn Shell, POSIX shell
- `curl`
- `unzip`

As you can see, ~~deno~~ needs NOT be installed.

## How to use

### Step 1: Copy-paste shebang file header

Copy/paste this two-liner, into the beginning of your TypeScript file:

```typescript
'@@src/deno-shebang.min.sh'
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
