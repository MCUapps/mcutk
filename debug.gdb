target extended-remote localhost:3333

define hook-step
monitor cortex_m3 maskisr on
end
define hookpost-step
monitor cortex_m3 maskisr off
end

monitor reset init
