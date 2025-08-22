#!/usr/bin/env bash

#
# The verilog file may have been regenerated, so add PIN assignments to resulting file
#

ATF15XX_YOSYSDIR=../../atf15xx_yosys
cat z80_mmu.v.in pins.v.in > z80_mmu.v
#cat z80_mmu.v.in  > z80_mmu.v

${ATF15XX_YOSYSDIR}/run_yosys.sh z80_mmu > z80_mmu.log

echo $*

${ATF15XX_YOSYSDIR}/run_fitter.sh -d ATF1504 -p PLC44 z80_mmu -strategy JTAG = OFF -preassign keep -tdi_pullup on -tms_pullup on -output_fast off -xor_synthesis on $*
