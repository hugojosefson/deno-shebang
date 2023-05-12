#!/usr/bin/env -S deno test --allow-run --allow-read --allow-net=semver-version.deno.dev --fail-fast --parallel
import { run } from "https://deno.land/x/run_simple@2.1.0/mod.ts";
import { assertEquals } from "https://deno.land/std@0.187.0/testing/asserts.ts";

async function fetchText(url: string): Promise<string> {
  const res = await fetch(url);
  const text = await res.text();
  return text;
}

async function getLatestVersion(repo: string, versionRange: string) {
  return (await fetchText(
    `https://semver-version.deno.dev/api/github/${repo}/${
      encodeURIComponent(versionRange)
    }`,
  )).replace("v", "");
}

const args = ["--hello=world", "--hola", "mundo"];
const stdin = "hej\n";

function getExpected(expectedVersion: string) {
  return [
    `This 🦕 is deno ${expectedVersion}, called with args:`,
    JSON.stringify(args, null, 2),
    JSON.stringify({ stdin }, null, 2),
  ].join("\n");
}

function runStepInParallel(
  t: Deno.TestContext,
  testStep: Deno.TestStepDefinition,
): Promise<boolean> {
  return t.step({
    ...testStep,
    sanitizeExit: false,
    sanitizeOps: false,
    sanitizeResources: false,
  });
}

async function runStepsInParallel(
  t: Deno.TestContext,
  testSteps: Deno.TestStepDefinition[],
): Promise<boolean> {
  const stepsRunning = testSteps.map((testStep) =>
    runStepInParallel(t, testStep)
  );
  const rans = await Promise.all(stepsRunning);
  const somethingRan = rans.some((ran) => ran);
  return somethingRan;
}

const scripts = [
  "./example",
  "./example.min",
  "./example.ts",
  "./example.min.ts",
];

const images = [
  "docker.io/amazonlinux",
  "docker.io/archlinux",
  "docker.io/debian:stable",
  "docker.io/debian:stable-slim",
  "docker.io/fedora",
  "docker.io/manjarolinux/base",
  "docker.io/node",
  "docker.io/node:lts",
  "docker.io/ubuntu",
  "quay.io/centos/centos:stream",
];

Deno.test("non-docker", async (t) => {
  await runStepsInParallel(
    t,
    scripts.map((script) => ({
      name: script,
      fn: async () => {
        const actual = await run([script, ...args], { stdin });
        assertEquals(actual, getExpected(Deno.version.deno));
      },
    })),
  );
});

Deno.test("docker", async (t) => {
  const denoVersionRange = await Deno.readTextFile("./.deno-version");
  const denoVersion = await getLatestVersion(
    "denoland/deno",
    denoVersionRange,
  );
  console.log({
    denoVersionRange,
    denoVersion,
  });
  await runStepsInParallel(
    t,
    images.map((image) => {
      return ({
        name: image,
        fn: async (t) => {
          const command = ["docker", "pull", image];
          await t.step({
            name: command.join(" "),
            fn: async () => {
              await run(command);
            },
          });

          const scriptsToTest = scripts.filter((script) =>
            !script.endsWith(".ts")
          );
          await runStepsInParallel(
            t,
            scriptsToTest.map((script) => {
              const command = [
                "docker",
                "run",
                "--rm",
                "-i",
                "--init",
                "-v",
                `${Deno.cwd()}:/app:ro`,
                "-w",
                "/app",
                image,
                script,
                ...args,
              ];
              return ({
                name: command.join(" "),
                fn: async () => {
                  const actual = await run(command, { stdin });
                  assertEquals(actual, getExpected(denoVersion));
                },
              });
            }),
          );
        },
      });
    }),
  );
});
