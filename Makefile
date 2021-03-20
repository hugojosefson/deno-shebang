all: README.md example.ts example.min.ts

clean:
	rm README.md example.ts example.min.ts

example.ts: src/deno-shebang.sh src/example.ts
	cat src/deno-shebang.sh src/example.ts > example.ts

example.min.ts: src/deno-shebang.min.sh src/example.ts
	cat src/deno-shebang.min.sh src/example.ts > example.min.ts

README.md: src/README.md src/deno-shebang.min.sh
	awk 'NR==FNR { a[n++]=$$0; next } /deno-shebang.min.sh/ { for (i=0;i<n;++i) print a[i]; next }1' src/deno-shebang.min.sh src/README.md > README.md

.PHONY: all clean
