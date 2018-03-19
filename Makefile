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

TURNED_SHAPES_A=$(patsubst fx_pics/turned_shapes/%.png, \
			   generated/turned_shapes/%.asm, \
		           $(wildcard fx_pics/turned_shapes/*.png))

main.bin: src/main.asm $(SRC) $(ZIK) $(GEN)
	dasm $< -o$@ -lmain.lst -smain.sym $(DFLAGS)

generated:
	mkdir generated

generated/turned_shapes: generated
	mkdir -p generated/turned_shapes

venv: venv/bin/activate

venv/bin/activate: tools/requirements.txt
	test -d venv || virtualenv venv -p $(shell which python3)
	. venv/bin/activate; pip install -Ur $<
	touch venv/bin/activate

generated/turned_shapes/%.asm: fx_pics/turned_shapes/%.png generated/turned_shapes
	. venv/bin/activate;\
	python tools/png2fx.py $< $(patsubst fx_pics/turned_shapes/%.png,%,$<) > $@

generated/fx_turn_tables.asm: venv generated
	. venv/bin/activate;\
	python tools/costables.py > $@

generated/fx_turn_data.asm: venv generated $(TURNED_SHAPES_A)
	cat $(TURNED_SHAPES_A) > $@

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
