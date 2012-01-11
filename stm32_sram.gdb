target extended-remote localhost:3333

define hook-step
monitor cortex_m3 maskisr on
end
define hookpost-step
monitor cortex_m3 maskisr off
end

monitor reset halt

load
set $sp = *(int *)0x20000000
set $pc = *(int *)0x20000004
mon mww 0xE000ED08 0x20000000

continue
quit
