console.log(
  `This 🦕 is deno ${Deno.version.deno}, called with args:\n${
    JSON.stringify(Deno.args, null, 2)
  }`,
);

const stdin = new TextDecoder().decode(await Deno.readAll(Deno.stdin));
console.log(JSON.stringify({ stdin }, null, 2));
