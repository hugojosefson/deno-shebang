#!/bin/sh
// 2>/dev/null; . "$(dirname "$0")/../src/deno-shebang.min.sh"

import whom from './mod.ts'
console.log(`Hello, ${whom}!`)
