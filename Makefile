SHELL = /bin/bash

CMD = php ./scripts/components.php
ALL_COMPONENT_FILES = tmp/*/*.cmp


all : cpuv3

cpuv3 : tmp/3/alu.cmp tmp/3/alu_im.cmp tmp/3/sramc.cmp tmp/3/cache.cmp tmp/3/instructionBuffer.cmp\
	tmp/3/reg.cmp tmp/3/irom.cmp tmp/3/memory.cmp tmp/3/iou.cmp tmp/3/rs232c.cmp tmp/3/led.cmp\
	tmp/3/branchPredictor.cmp tmp/3/lsu.cmp tmp/3/fpu.cmp tmp/3/reorderBuffer.cmp\
	tmp/3/clock.cmp tmp/3/clock.cmp tmp/3/decoder.cmp tmp/3/dff.cmp tmp/3/returnAddressStack.cmp
	$(CMD) -l 3 cpuv3/library/SuperScalarComponents.vhd  
	
tmp/3/alu.cmp:cpuv3/alu/alu.vhd
	$(CMD) 3 $< $@

tmp/3/alu_im.cmp:cpuv3/alu/alu_im.vhd
	$(CMD) 3 $< $@
	
tmp/3/sramc.cmp:cpuv3/memory/sram/sram_controller.vhd
	$(CMD) 3 $< $@
	
tmp/3/cache.cmp:cpuv3/memory/cache.vhd
	$(CMD) 3 $< $@

tmp/3/branchPredictor.cmp:cpuv3/branchPredictor.vhd
	$(CMD) 3 $< $@
	
tmp/3/clock.cmp:cpuv3/clock/clockgenerator.vhd
	$(CMD) 3 $< $@
	
tmp/3/decoder.cmp:cpuv3/decoder.vhd
	$(CMD) 3 $< $@
	
tmp/3/dff.cmp:cpuv3/dff.vhd
	$(CMD) 3 $< $@

tmp/3/reg.cmp:cpuv3/reg.vhd
	$(CMD) 3 $< $@
	
tmp/3/irom.cmp:cpuv3/memory/IROM.vhd
	$(CMD) 3 $< $@
	
tmp/3/lsu.cmp:cpuv3/memory/lsu.vhd
	$(CMD) 3 $< $@
	
tmp/3/memory.cmp:cpuv3/memory/memory.vhd
	$(CMD) 3 $< $@
	
tmp/3/instructionBuffer.cmp:cpuv3/memory/instructionBuffer.vhd
	$(CMD) 3 $< $@
	
tmp/3/iou.cmp:cpuv3/io/IOU.vhd
	$(CMD) 3 $< $@
	
tmp/3/led.cmp:cpuv3/io/LED/ledextd2.vhd
	$(CMD) 3 $< $@
	
tmp/3/rs232c.cmp:cpuv3/io/rs232c/rs232cio.vhd
	$(CMD) 3 $< $@
	
	
tmp/3/fpu.cmp:cpuv3/fpu_4clk/fpu.vhd
	$(CMD) 3 $< $@

tmp/3/reorderBuffer.cmp:cpuv3/reorderBuffer.vhd
	$(CMD) 3 $< $@
	
tmp/3/returnAddressStack.cmp:cpuv3/returnAddressStack.vhd
	$(CMD) 3 $< $@
	


clean:
	rm -f $(ALL_COMPONENT_FILES)
	
.PHONY: clean