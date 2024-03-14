# The Stackable Z80 Computer


A layman's attempt at designing a modular, stackable Z80 computer.


## Disclaimer

Let me start by pointing out that I am not an electronic engineer. Everything I know
about electronics I learned from the internet and from two electronic design courses
during my university days, and nearly all of it is theoretical. I am really more of a
software person who decided at one point in his not-so-distant past that it might be
fun to start learning to design (digital) electronic circuits. 

That said, this is not my first KiCAD project. 

The designs in this repository are bound to have many, many flaws, and I would love to
hear about them from you. Just keep in mind that I do have a day job and that it takes
precedence if I do not respond to them within a day. As a person without an actual
background in electronic design I am sure I am making assumptions about components in
the design that are incorrect or otherwise potentially troublesome. 

Ok, enough ranting. Let's have a look at it.

## Physical description

In principle, the Stackable Z80 computer is more an idea than an actual design. As such
it is built around the following concepts:

- The board dimensions are 95.25mm x 95.25mm (3.75" x 3.75")
- There are four main connectors:
    - Expansion Connector A (2x20 pins, IDC)
	- Expansion Connector B (2x17 pins, IDC)
	- Expansion Connector C (2x4 pins, IDC)
	- Power Connector (2x10 pins, IDC)
- Each board can be stacked on top of another through the use of standoffs

Expansion Connector A is standardized; it contains most, if not all, of the relevant
Z80 signals, such as the address bus (A0-A15), the data bus (D0-D7), control signals
like /INT, /RESET, etc, and both a CPU_CLK and a BUS_CLK signal (they may differ, but
the former should then always be an integer multiple of the latter). All address, data
and control lines should have pull-ups or pull-downs on at least one board, so as to
prevent undesirable current from flowing between two devices asserting the bus at the
same time. They are also buffered. Pins 1 and 40 are connected to ground.

Expansion Connector B is partly standardized; the uneven numbered pins are used for 8
interrupt lines (/INT0-/INT7), as well as 8 more address lines (MA14-A21). Pins 1 and 
34 are connected to ground. The remaining pins, all even, are defined as USER0-USER15,
or in other words, user defined. 

Expansion Connector C contains the extra bus signals provided by the Z80 CPU board with
an extended bus (cpu_board_ext_bus+v2). It provides 5 new signals: /IOR, /IOW, /MEMR, /MEMW
and /INTA. These can be used to simplify the designs of future boards. In addition they
also provide the necessary signals for interfacing with an Intel 8259 Programmable
Interrupt Controller. 

The Power Connector is standardized around the 20-pins ATX power supply connector, and indeed
the Power Board does contain one, but power to the CPU board is provided through an IDC header.
The rationale behind this is that power to the CPU board is is delivered from the power supply 
through the power board, which has a front panel header and which in turn distributes power to
the CPU board through the aforementioned 2x10 pins IDC header.

Power delivery to all other boards is standardized around the old-fashioned floppy 
connector (TE_171826-4). Only +12V and +5V are available. +5VSB (standby power) and 3.3V
should be delivered separately, for instance from the power board.

## Minimal configuration (top to bottom)

- Serial I/O board
- ROM/RAM board
- The "even simpler Z80" board
- Power board

This will provide a basic Z80 system with serial I/O support. The serial I/O board should
be configured to use /INT as its interrupt line and use 0x80 as its I/O base address.

The system will have 32kB of ROM, as well as 96kB of RAM, able to be paged in or out of the
Z80 address space as needed in segments of 16kB. 

Expansion Bus B is not used in this configuration.

## A more advance configuration (top to bottom)

- Serial I/O board
- ROM/RAM board v2
- CPU board with expansion Connector C
- Power board

This will provide a slightly more advanced Z80 system with serial I/O support. The serial I/O
board should be configured to use /INT as its interrupt line and use 0x80 as its I/O
base address. The ROM/RAM board should be configured for Bank 0. 

This system will have 512kB of Flash ROM and 1536kB of SRAM. Segments 0-31 will be ROM, 
segments 32-127 will be RAM. Segments 128-255 will be available for add-on boards with
its own ROM or RAM or which use memory mapped I/O. 

## Repository layout
 
The repository is laid out as follows:

- boards/core contains the core boards
    - even_simpler_z80: the basic, bare bones Z80 board; just the CPU, some buffers/latches and a clock generator
	- power_board: the power delivery board
	- rom_ram_board: a board that provides 32kB of ROM and 96kB of RAM, able to be paged in and out as needed.
	- serial_io_board: a board that provides a RS232 interface for outside communication.
- boards/extra contains some extra board designs
    - 8259_pic_board: 8259 Interrupt Controller Board for the SZC-1; requires Expansion Connector C.
    - audio_board: SSG Audio Board for the SZC-1, providing SSG sound support.
	- cpu_board_ext_bus_v2: new and improved CPU board providing Expansion Connector C and an on-board memory mapper.
    - diag_board: a basic diagnostics board, providing a 2-digit 7-segment display accessible through I/O port 0xb8.
	- ide_board: IDE Board for the SZC-1, inspired by the Beer IDE interface.
	- mmu_board: a preliminary design for a Z80 MMU built around a ATF1502/1504 CPLD (*work in progress*)
	- rom_ram_board_2MB: a board that provides 512kB of flash ROM and 1536kB of RAM, able to be paged in and out as needed.
	- rom_ram_board_v2: another board that provides 512kB of flash ROM and 1536kB of RAM; requires Expansion Connector C.
	- simple_z80: the original Z80 board, CPU, buffers/latches and a LS74xx based IM2 interrupt controller.
- boards/msx_compat contains boards to provide MSX compatibility (*work in progress*)
    - msx_rom_board: a board that houses to 32kB EEPROM sockets for MSX compatible ROMs (requires the ppi_slot_select_expanded board)
    - msx_rom_ram_board: a board with 512kB flash ROM and 1MB SRAM (requires the ppi_slot_select_expanded board)
	- ppi_slot_select: a board that provides MSX compatible slot select registers as well as 16 GPIO pins.
	- ppi_slot_select_expanded: as ppi_slot_select, but also contains an expanded slot select register.
- digital contains experiments made in Digital to work out some concepts
- doc: contains documentation and other reference material
- ibom: interactive BOMs for the boards
- pics: 
    - renderings: contains 3D renderings of most of the boards
	- photos: contains photos of PCBs and assembled boards
- verilog: contains verilog output from Digital for the experiments in the *digital* folder.

