odinslove: $(wildcard **/*.odin)
	odin build src -out=odinslove

test: 
	odin test tests -define:ODIN_TEST_THREADS=1
