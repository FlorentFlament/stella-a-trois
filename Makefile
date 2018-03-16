INCDIRS=include generated zik src
DFLAGS=$(patsubst %,-I%,$(INCDIRS)) -f3 -d
SRC=$(shell find . -name *.asm)

main.bin: src/main.asm $(SRC)
	dasm $< -o$@ -lmain.lst -smain.sym $(DFLAGS)

run: main.bin
	stella $<

clean:
	rm -f main.bin main.lst main.sym
