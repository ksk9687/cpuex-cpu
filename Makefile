SHELL = /bin/bash

CMD = php ./scripts/components.php
ALL_COMPONENT_FILES = tmp/*/*.cmp


all : cpuv2

cpuv2 : tmp/2/alu.cmp tmp/2/alu_im.cmp tmp/2/sramc.cmp tmp/2/cache.cmp tmp/2/instructionBuffer.cmp\
	tmp/2/reg.cmp tmp/2/irom.cmp tmp/2/memory.cmp tmp/2/usb.cmp tmp/2/iou.cmp\
	tmp/2/branchPredictor.cmp tmp/2/lsu.cmp\
	tmp/2/clock.cmp tmp/2/clock.cmp tmp/2/decoder.cmp tmp/2/dff.cmp
	$(CMD) -l 2 cpuv2/library/SuperScalarComponents.vhd  
	
tmp/2/alu.cmp:cpuv2/alu/alu.vhd
	$(CMD) 2 $< $@

tmp/2/alu_im.cmp:cpuv2/alu/alu_im.vhd
	$(CMD) 2 $< $@
	
tmp/2/sramc.cmp:cpuv2/memory/sram/sram_controller.vhd
	$(CMD) 2 $< $@
	
tmp/2/cache.cmp:cpuv2/memory/cache.vhd
	$(CMD) 2 $< $@

tmp/2/branchPredictor.cmp:cpuv2/branchPredictor.vhd
	$(CMD) 2 $< $@
	
tmp/2/clock.cmp:cpuv2/clock.vhd
	$(CMD) 2 $< $@
	
tmp/2/decoder.cmp:cpuv2/decoder.vhd
	$(CMD) 2 $< $@
	
tmp/2/dff.cmp:cpuv2/dff.vhd
	$(CMD) 2 $< $@

tmp/2/reg.cmp:cpuv2/reg.vhd
	$(CMD) 2 $< $@
	
tmp/2/irom.cmp:cpuv2/memory/IROM.vhd
	$(CMD) 2 $< $@
	
tmp/2/lsu.cmp:cpuv2/memory/lsu.vhd
	$(CMD) 2 $< $@
	
tmp/2/memory.cmp:cpuv2/memory/memory.vhd
	$(CMD) 2 $< $@
	
tmp/2/instructionBuffer.cmp:cpuv2/memory/instructionBuffer.vhd
	$(CMD) 2 $< $@
	
tmp/2/iou.cmp:cpuv2/io/IOU.vhd
	$(CMD) 2 $< $@
	
tmp/2/usb.cmp:cpuv2/io/usbio3/usbio1_buf.vhd
	$(CMD) 2 $< $@
	
clean:
	rm -f $(ALL_COMPONENT_FILES)
	
.PHONY: clean