RYFS := ../ryfs/ryfs.py
FOX32ASM := ../fox32asm/target/release/fox32asm

ASM_FILES = $(wildcard src/*.asm)
FXF_FILES = $(patsubst src/%.asm, image/%.fxf, $(ASM_FILES))

tcc2024.img: $(FXF_FILES) image/startup.bat
	$(RYFS) -l tcc2024 create $@
	for file in $^; do $(RYFS) add $@ $$file; done

image/%.fxf: src/%.asm
	@mkdir -p image
	$(FOX32ASM) $< $@

image/startup.bat: $(FXF_FILES)
	@mkdir -p image
	echo $(FXF_FILES) | awk '{ \
	for(i=1; i<=NF; i++) { \
		sub(/^image\//, "", $$i); \
		sub(/\.fxf$$/, "", $$i); \
		if($$i !~ /^_/) { printf("*1:%s;\n", $$i); } \
	} \
	print "exit;" }' > $@
