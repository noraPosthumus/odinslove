odinslove: $(wildcard **/*.odin)
	odin build . -out=odinslove -collection:odinslove=src -strict-style -vet -o:speed

lib: dist/lib/wrapper.odin dist/lib/odinslove.so

dist/lib/wrapper.odin:
	mkdir -p dist/lib/ && cp src/wrapper/wrapper.odin dist/lib/ && mv dist/lib/wrapper.odin dist/lib/odinslove.odin

dist/lib/odinslove.so:
	odin build src/core -out=dist/lib/odinslove.so -build-mode:shared -collection:odinslove=src -strict-style -vet -o:speed

debug: $(wildcard **/*.odin)
	odin build . -out=odinslove.debug -collection:odinslove=src -strict-style -vet -debug

test: 
	odin test tests -collection:odinslove=src -define:ODIN_TEST_THREADS=1

clean:
	rm -f odinslove odinslove.debug && rm -rf dist

.PHONY: test clean debug lib
