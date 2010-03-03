SHELL = /bin/bash

CMD = php ./scripts/components.php
ALL_COMPONENT_FILES = tmp/*/*.cmp

all : cpuv4

cpuv4 : tmp/4/alu.cmp tmp/4/sramc.cmp tmp/4/cache.cmp tmp/4/reservationStation.cmp tmp/4/reservationStationBru.cmp\
	tmp/4/reg.cmp tmp/4/memory.cmp tmp/4/iou.cmp tmp/4/rs232c.cmp tmp/4/led.cmp tmp/4/bru.cmp\
	tmp/4/branchPredictor.cmp tmp/4/lsu.cmp tmp/4/fpu.cmp tmp/4/reorderBuffer.cmp\
	tmp/4/clock.cmp tmp/4/clock.cmp tmp/4/decoder.cmp tmp/4/dff.cmp tmp/4/returnAddressStack.cmp
	$(CMD) -l 4 cpuv4/library/SuperScalarComponents.vhd  
	
tmp/4/alu.cmp:cpuv4/alu/alu.vhd
	$(CMD) 4 $< $@

tmp/4/alu_im.cmp:cpuv4/alu/alu_im.vhd
	$(CMD) 4 $< $@
	
tmp/4/sramc.cmp:cpuv4/memory/sram/sram_controller.vhd
	$(CMD) 4 $< $@
	
tmp/4/cache.cmp:cpuv4/memory/cache.vhd
	$(CMD) 4 $< $@

tmp/4/branchPredictor.cmp:cpuv4/branchPredictor.vhd
	$(CMD) 4 $< $@
	
tmp/4/clock.cmp:cpuv4/clock/clockgenerator.vhd
	$(CMD) 4 $< $@
	
tmp/4/decoder.cmp:cpuv4/decoder.vhd
	$(CMD) 4 $< $@
	
tmp/4/dff.cmp:cpuv4/dff.vhd
	$(CMD) 4 $< $@

tmp/4/reg.cmp:cpuv4/reg.vhd
	$(CMD) 4 $< $@
	
tmp/4/irom.cmp:cpuv4/memory/IROM.vhd
	$(CMD) 4 $< $@
	
tmp/4/lsu.cmp:cpuv4/memory/lsu.vhd
	$(CMD) 4 $< $@
	
tmp/4/memory.cmp:cpuv4/memory/memory.vhd
	$(CMD) 4 $< $@
	
#tmp/4/instructionBuffer.cmp:cpuv4/memory/instructionBuffer.vhd
#	$(CMD) 4 $< $@
	
tmp/4/iou.cmp:cpuv4/io/IOU.vhd
	$(CMD) 4 $< $@
	
tmp/4/led.cmp:cpuv4/io/LED/ledextd2.vhd
	$(CMD) 4 $< $@
	
tmp/4/rs232c.cmp:cpuv4/io/rs232c/rs232cio.vhd
	$(CMD) 4 $< $@
	
	
tmp/4/fpu.cmp:cpuv4/fpu_4clk/fpu.vhd
	$(CMD) 4 $< $@

tmp/4/reorderBuffer.cmp:cpuv4/reorderBuffer.vhd
	$(CMD) 4 $< $@
	
tmp/4/returnAddressStack.cmp:cpuv4/returnAddressStack.vhd
	$(CMD) 4 $< $@
	
tmp/4/reservationStation.cmp:cpuv4/reservationStation.vhd
	$(CMD) 4 $< $@

tmp/4/reservationStationBru.cmp:cpuv4/reservationStationBru.vhd
	$(CMD) 4 $< $@

tmp/4/bru.cmp:cpuv4/bru.vhd
	$(CMD) 4 $< $@
	
clean:
	rm -f $(ALL_COMPONENT_FILES)
	
.PHONY: clean