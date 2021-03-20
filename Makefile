all: example.ts example.min.ts README.md README.html test

clean:
	@rm -f README.* example.* test/import-test.sh

example.ts: src/deno-shebang.sh src/example.ts
	@cat src/deno-shebang.sh src/example.ts > example.ts
	@chmod +x example.ts

example.min.ts: src/deno-shebang.min.sh src/example.ts
	@cat src/deno-shebang.min.sh src/example.ts > example.min.ts
	@chmod +x example.min.ts

README.md: src/README.md src/deno-shebang.min.sh
	@awk 'NR==FNR { a[n++]=$$0; next } /deno-shebang.min.sh/ { for (i=0;i<n;++i) print a[i]; next }1' src/deno-shebang.min.sh src/README.md > README.md  # This line via https://stackoverflow.com/a/25557287 CC BY-SA 3.0

README.html: README.md
	@docker run --rm -i hugojosefson/markdown < README.md > README.html

test: test/import-test.sh
	@sh -c '[ "$$(./test/import-test.sh)" = "Hello, world!" ]'                   # Just run it
	@cd test && sh -c '[ "$$(cat import-test.sh | sh)" = "Hello, world!" ]'      # pipe through sh in correct dir
	@! sh -c '. ./test/import-test.sh' 2>/dev/null                               # pipe through sh in wrong dir should fail
	@cd test && sh -c '[ "$$(. ./import-test.sh)" = "Hello, world!" ]'           # sourcing the script in correct dir
	@! sh -c '. ./import-test.sh' 2>/dev/null                                    # sourcing the script in wrong dir should fail

test/import-test.sh: src/deno-shebang.min.sh test/import-test.ts
	@cat src/deno-shebang.min.sh test/import-test.ts > test/import-test.sh
	@chmod +x test/import-test.sh

.PHONY: all clean test
