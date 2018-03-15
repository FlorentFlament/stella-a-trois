INCDIRS=include generated zik src
DFLAGS=$(patsubst %,-I%,$(INCDIRS)) -f3 -d

main.bin: src/main.asm src/fx.asm
	dasm $< -o$@ -lmain.lst -smain.sym $(DFLAGS)

run: main.bin
	stella $<

clean:
	rm -f main.bin main.lst main.sym
