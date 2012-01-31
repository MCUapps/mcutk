# README

This repository contains some supporting scripts for embedded ARM development with CMake and emulators with GDB servers embedded, like OpenOCD. And it's BSD licensed.

## Installation

Check it out as a git submodule to the `mcutk` folder under the project root folder

    git submodule add https://github.com/mcuapps/mcutk.git

Copy and rename `CMakeLists.txt.sample` to `CMakeLists.txt`. Place it in the project root folder.

Then make a `build` folder under the project root folder, and change your working directory to it. Issue the following command to generate associated `Makefile`

	../mcutk/gen_makefile.sh

Then you can modify `CMakeLists.txt` to fit your needs.

## Usage

No matter whether you are developing your projects with CMake or not, you can always make use of this toolset to help the development. Say, if your project generates `target.elf` as the final product and you'd like to use `jlink` as the OpenOCD interface, then you can type `make help` and see several useful targets like:

- target_outputs -- generates size statics, ROM HEX, map file, program dump ... etc from ELF
- jlink -- simply type `make jlink` to launch OpenOCD's gdbserver with jlink interface. 
- gdb_target.elf -- connect gdbserver at localhost port 3333 for debugging.
- cgdb_target.elf -- connect gdbserver at localhost port 3333 for debugging, but with `cgdb`
- stm32_ram_target.elf -- run target.elf in SRAM. Note you must use linkscript configured for SRAM and remap NVIC's vectors base.

Just extend the file `helpers.cmake` to fit your needs.

