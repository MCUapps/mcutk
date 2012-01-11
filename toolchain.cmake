########################################################################
# Set up cross compiler tools
########################################################################
include(CMakeForceCompiler)

# this one is important
set(CMAKE_SYSTEM_NAME Generic)
#this one not so much
set(CMAKE_SYSTEM_VERSION 1)

# specify the cross compiler
CMAKE_FORCE_C_COMPILER  (arm-none-eabi-gcc GNU)
CMAKE_FORCE_CXX_COMPILER(arm-none-eabi-gcc GNU)

# where is the target environment, no need if it's already in the PATH
#set(CMAKE_FIND_ROOT_PATH /opt/arm-cs-tools)

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)

# use relative path
set(CMAKE_USE_RELATIVE_PATHS ON)
