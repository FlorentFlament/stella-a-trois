INCDIRS=include generated zik src
DFLAGS=$(patsubst %,-I%,$(INCDIRS)) -f3 -d

# asm files
SRC=$(wildcard src/*.asm)
ZIK=$(wildcard zik/*.asm)

GEN=$(patsubst %,generated/%, \
fx_turn_tables.asm \
fx_turn_data.asm \
fx_text_font.asm \
gfx_top.asm \
gfx_bottom.asm \
)

main.bin: src/main.asm $(SRC) $(ZIK) $(GEN)
	dasm $< -o$@ -lmain.lst -smain.sym $(DFLAGS)

generated:
	mkdir generated

venv: venv/bin/activate

venv/bin/activate: tools/requirements.txt
	test -d venv || virtualenv venv -p $(shell which python3)
	. venv/bin/activate; pip install -Ur $<
	touch venv/bin/activate

generated/fx_turn_tables.asm: venv generated
	. venv/bin/activate;\
	python tools/costables.py > $@

generated/fx_turn_data.asm: venv generated
	. venv/bin/activate;\
	python tools/png2fx.py fx_pics/karmeliet-16x43.png karmeliet > $@;\
	python tools/png2fx.py fx_pics/duvel-12x46.png duvel >> $@;\

generated/fx_text_font.asm: venv generated
	. venv/bin/activate;\
	python tools/pngfont.py fx_pics/glafont/ > $@

generated/gfx_top.asm: venv generated
	. venv/bin/activate;\
	python tools/png2hrpf.py fx_pics/stella_07_top_40x50.png gfx_top > $@

generated/gfx_bottom.asm: venv generated
	. venv/bin/activate;\
	python tools/png2hrpf.py fx_pics/stella_07_bottom_40x34.png gfx_bottom > $@

run: main.bin
	stella $<

clean:
	rm -f main.bin main.lst main.sym
	rm -rf venv generated
