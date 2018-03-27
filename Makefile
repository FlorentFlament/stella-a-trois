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

TURNPDIR=fx_pics/turned_shapes
TURNADIR=generated/turned_shapes

TURNSHAPES=$(patsubst $(TURNPDIR)/%.png, \
			$(TURNADIR)/%.asm, \
			$(wildcard $(TURNPDIR)/*.png))

MDGEN=mkdir -p generated
MDTUR=mkdir -p generated/turned_shapes
VENV=. venv/bin/activate;

main.bin: src/main.asm $(SRC) $(ZIK) $(GEN)
	dasm $< -o$@ -lmain.lst -smain.sym $(DFLAGS)

venv: venv/bin/activate

venv/bin/activate: tools/requirements.txt
	test -d venv || virtualenv venv -p $(shell which python3)
	. venv/bin/activate; pip install -Ur $<
	touch venv/bin/activate

$(TURNADIR)/%.asm: $(TURNPDIR)/%.png
	$(MDTUR)
	$(VENV) python tools/png2fx.py $< $(patsubst fx_pics/turned_shapes/%.png,%,$<) > $@

generated/fx_turn_tables.asm: venv
	$(MDGEN)
	$(VENV) python tools/costables.py > $@

generated/fx_turn_data.asm: $(TURNSHAPES)
	$(MDGEN)
	cat $(TURNSHAPES) > $@

generated/fx_text_font.asm: venv
	$(MDGEN)
	$(VENV) python tools/pngfont.py fx_pics/glafont/ > $@

generated/gfx_top.asm: venv
	$(MDGEN)
	$(VENV) python tools/png2hrpf.py fx_pics/stella_09b_top_40x50.png gfx_top > $@

generated/gfx_bottom.asm: venv
	$(MDGEN)
	$(VENV) python tools/png2hrpf.py fx_pics/stella_09b_bottom_40x34.png gfx_bottom > $@

run: main.bin
	stella $<

clean:
	rm -f main.bin main.lst main.sym
	rm -rf venv generated
