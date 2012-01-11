########################################################################
# programs for output files
########################################################################
find_program(LINKER arm-none-eabi-ld)
find_program(OBJCOPY arm-none-eabi-objcopy)
find_program(OBJDUMP arm-none-eabi-objdump)
find_program(GDB arm-none-eabi-gdb)
find_program(SIZE arm-none-eabi-size)
find_program(HEXDUMP hexdump)
find_program(OPENOCD openocd)

########################################################################
# JTAG helpers
########################################################################
set(TARGET_NAME "target_name_not_set")
macro(JTAG_TARGET name)
	set(TARGET_NAME ${name})
    foreach (interface jlink openjtag)
		add_custom_target(
			${interface}
			COMMAND echo 'init; reset reset' |
				${OPENOCD} -f ${CMAKE_SOURCE_DIR}/mcutk/${interface}.cfg
                           -f target/${TARGET_NAME}.cfg
                           -c 'init'
                           -c 'reset init'
		)
    endforeach (interface)
endmacro(JTAG_TARGET)

########################################################################
# helper functions to build output formats
########################################################################
set(GEN_OUTPUTS_BIN_SIZE "bin_size_not_set") #set before calling
macro(GEN_OUTPUTS target)
	get_filename_component(name ${target} NAME_WE)
	#print the size information
	add_custom_command(
	    OUTPUT ${name}_size DEPENDS ${target}
	    COMMAND ${SIZE} --format=berkeley ${target}
	)
	#command to create a map from elf
	add_custom_command(
	    OUTPUT ${name}.map DEPENDS ${target}
	    COMMAND ${LINKER} -Map ${name}.map ${target} && rm a.out
	)
	#command to create a bin from elf
	add_custom_command(
	    OUTPUT ${name}.bin DEPENDS ${target}
	    COMMAND ${OBJCOPY} -O binary ${target} ${name}.bin
	    	--pad-to ${GEN_OUTPUTS_BIN_SIZE}
	)
	#command to create a ihx from elf
	add_custom_command(
	    OUTPUT ${name}.ihx DEPENDS ${target}
	    COMMAND ${OBJCOPY} -O ihex ${target} ${name}.ihx
	    	--pad-to ${GEN_OUTPUTS_BIN_SIZE}
	)
	#command to create a dump from elf
	add_custom_command(
	    OUTPUT ${name}.dump DEPENDS ${target}
	    COMMAND ${OBJDUMP} -DSC ${target} > ${name}.dump
	)
	#command to create a rom from bin
	add_custom_command(
	    OUTPUT ${name}.rom DEPENDS ${name}.bin
	    COMMAND ${HEXDUMP} -v -e'1/1 \"%.2X\\n\"' ${name}.bin > ${name}.rom
	)
	#add a top level target for output files
	add_custom_target(
	    ${name}_outputs ALL DEPENDS ${name}_size ${name}.map ${name}.bin ${name}.ihx ${name}.dump ${name}.rom
	)
	#commands to debug
	add_custom_target(
		gdb_${target}
		DEPENDS ${target}
		COMMAND ${GDB} ${target} -x ${CMAKE_SOURCE_DIR}/mcutk/debug.gdb
	)
	add_custom_target(
		cgdb_${target}
		DEPENDS ${target}
		COMMAND cgdb -d ${GDB} ${target} -x ${CMAKE_SOURCE_DIR}/mcutk/debug.gdb
	)
	#command to load in RAM and run
	add_custom_target(
		stm32_sram_${target}
		DEPENDS ${target}
		COMMAND ${GDB} ${target} -x ${CMAKE_SOURCE_DIR}/mcutk/stm32_sram.gdb
	)
	#commands to flash
    foreach (interface jlink openjtag)
		add_custom_target(
			flash_${interface}_${target}
			DEPENDS ${target}
			COMMAND ${OPENOCD} -f ${CMAKE_SOURCE_DIR}/mcutk/${interface}.cfg
                               -f target/${TARGET_NAME}.cfg
                               -c 'flash write_image erase ${target} 0x00000000 elf'
                               -c 'verify_image ${target} 0x00000000 elf'
                               -c 'sleep 100'
                               -c 'reset run'
                               -c 'shutdown'
		)
    endforeach (interface)
endmacro(GEN_OUTPUTS)
