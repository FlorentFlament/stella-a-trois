main.bin: src/main.asm src/fx.asm
	dasm src/main.asm -f3 -omain.bin -lmain.lst -smain.sym -d

run: main.bin
	stella main.bin

clean:
	rm -f main.bin main.lst main.sym
