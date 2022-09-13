all: example.ts example.min.ts example-piped.ts example-piped.min.ts example example.min example-piped example-piped.min README.md README.html test

clean:
	@rm -f README.* example* test/import-test.sh

example.ts: src/deno-shebang.sh src/example.ts
	@cat src/deno-shebang.sh src/example.ts > example.ts
	@chmod +x example.ts

example.min.ts: src/deno-shebang.min.sh src/example.ts
	@cat src/deno-shebang.min.sh src/example.ts > example.min.ts
	@chmod +x example.min.ts

example-piped.ts: src/deno-shebang-piped.sh src/example.ts
	@cat src/deno-shebang-piped.sh src/example.ts > example-piped.ts
	@echo "//🔚" >> example-piped.ts
	@chmod +x example-piped.ts

example-piped.min.ts: src/deno-shebang-piped.min.sh src/example.ts
	@cat src/deno-shebang-piped.min.sh src/example.ts > example-piped.min.ts
	@echo "//🔚" >> example-piped.min.ts
	@chmod +x example-piped.min.ts

example: example.ts
	@cp example.ts example

example.min: example.min.ts
	@cp example.min.ts example.min

example-piped: example-piped.ts
	@cp example-piped.ts example-piped

example-piped.min: example-piped.min.ts
	@cp example-piped.min.ts example-piped.min

README.md: src/README.md src/deno-shebang.min.sh src/deno-shebang-piped.min.sh
	@awk 'NR==FNR { a[n++]=$$0; next } /deno-shebang.min.sh/       { for (i=0;i<n;++i) print a[i]; next }1' src/deno-shebang.min.sh       src/README.md   > README.md.1  # This line via https://stackoverflow.com/a/25557287 CC BY-SA 3.0
	@awk 'NR==FNR { a[n++]=$$0; next } /deno-shebang-piped.min.sh/ { for (i=0;i<n;++i) print a[i]; next }1' src/deno-shebang-piped.min.sh   ./README.md.1 > README.md    # This line via https://stackoverflow.com/a/25557287 CC BY-SA 3.0
	@rm -f README.md.1

README.html: README.md
	@docker run --rm -i hugojosefson/markdown < README.md > README.html

test: test/import-test.sh test/import-test-piped.sh
	@cd test && [ "$$(cat import-test-piped.sh | sh)" = "Hello, world!" ] # pipe through sh in correct dir
	@! (cat ./test/import-test-piped.sh | sh 2>/dev/null)                 # pipe through sh in wrong dir should fail
	@[ "$$(./test/import-test.sh)" = "Hello, world!" ]                    # Just run it
	@cd test && [ "$$(./import-test.sh)" = "Hello, world!" ]              # run the script in correct dir
	@! ./import-test.sh 2>/dev/null                                       # run the script in wrong dir should fail

test/import-test.sh: src/deno-shebang.min.sh test/import-test.ts
	@cat src/deno-shebang.min.sh test/import-test.ts > test/import-test.sh
	@chmod +x test/import-test.sh

test/import-test-piped.sh: src/deno-shebang-piped.min.sh test/import-test.ts
	@cat src/deno-shebang-piped.min.sh test/import-test.ts > test/import-test-piped.sh
	@echo "//🔚" >> test/import-test-piped.sh
	@chmod +x test/import-test-piped.sh

docker-test:
	docker build -t deno-shebang-test .
	docker run --rm -i -v "/var/run/docker.sock:/var/run/docker.sock:Z" deno-shebang-test make --always-make
	@echo "Tests were successful inside Docker."

.deno-version:
	@curl -sf https://semver-version.deno.dev/api/github/denoland/deno|sed -E 's|^v?([0-9]+.[0-9]+)\.[0-9]+|^\1|' > .deno-version

update-version-range: .deno-version src/deno-shebang.sh src/deno-shebang.min.sh src/deno-shebang-piped.sh src/deno-shebang-piped.min.sh
	@sed -E "s|DENO_VERSION_RANGE=\"[^\"]*\"|DENO_VERSION_RANGE=\"$$(cat .deno-version)\"|g" -i src/deno-shebang*.sh

maxify:
	@sed -E 's|;|\n|g' -i src/*.min.sh                                    # Split lines

minify:
	@sed -zE 's|\n|;|g' -i src/*.min.sh                                   # Join lines
	@sed -zE 's|^(#![^;]*);|\1\n|' -i src/*.min.sh                        # Add newline after shebang
	@sed -zE 's|;$$||' -i src/*.min.sh                                    # Remove trailing semicolon
	@sed -zE 's|\n*$$|\n|' -i src/*.min.sh                                # Ensure exactly 1 newline at end of file

.PHONY: all clean test docker-test update-version-range .deno-version maxify minify
