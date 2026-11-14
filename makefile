odinslove: $(wildcard **/*.odin)
	odin build . -out=odinslove -collection:odinslove=src -strict-style -vet -o:speed

debug: $(wildcard **/*.odin)
	odin build . -out=odinslove.debug -collection:odinslove=src -strict-style -vet -debug

test: 
	odin test tests -collection:odinslove=src -define:ODIN_TEST_THREADS=1

clean:
	rm -f odinslove odinslove.debug

.PHONY: test clean debug
