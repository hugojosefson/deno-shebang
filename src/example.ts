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
