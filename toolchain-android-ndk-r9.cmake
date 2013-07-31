#
# Android NDK toolchain file for CMake
#
# (c) Copyrights 2009-2013 Hartmut Seichter
# 
# Note: this version only targets NDK r8e
#
# Only tested with using stlport

# need to know where the NDK resides
# Note: $ENV{ANDROID_NDK_ROOT} is the semi-official blessed environmental variable
# for the location of the root of the Android NDK.
# For the non-standalone toolchain, this is the directory we want and we don't need
# a separate $ENV{NDK_TOOLCHAIN_ROOT}
if($ENV{NDK_TOOLCHAIN_ROOT})
	set(ANDROID_NDK_ROOT "$ENV{NDK_TOOLCHAIN_ROOT}" CACHE PATH "Android Toolchain location")
else()
	set(ANDROID_NDK_ROOT "$ENV{ANDROID_NDK_ROOT}" CACHE PATH "Android Toolchain location")
endif()

# set(ANDROID_NDK_TOOLCHAIN_DEBUG ON)

# check host platform
set(ANDROID_NDK_HOST)
if(APPLE)
	set(ANDROID_NDK_HOST "darwin-x86_64")
elseif(WIN32)
	set(ANDROID_NDK_HOST "windows")
elseif(UNIX)
	set(ANDROID_NDK_HOST "linux-x86")
else()
	message( FATAL_ERROR "Platform not supported" )
endif()

# basic setup
set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SKIP_RPATH ON)

# for convenience
set(ANDROID 1)

# set supported architecture
set(ANDROID_NDK_ARCH_SUPPORTED "arm;armv7;x86")
set(ANDROID_NDK_ARCH "arm" CACHE STRING "Android NDK CPU architecture (${ANDROID_NDK_ARCH_SUPPORTED})")
set_property(CACHE ANDROID_NDK_ARCH PROPERTY STRINGS ${ANDROID_NDK_ARCH_SUPPORTED})

# armeabi / armeabi-v7a / x86
set(ANDROID_NDK_ABI)
set(ANDROID_NDK_ABI_EXT)
set(ANDROID_NDK_GCC_PREFIX)

set(ANDROID_NDK_ARCH_CFLAGS)
set(ANDROID_NDK_ARCH_LDFLAGS)

if("${ANDROID_NDK_ARCH}" STREQUAL "arm" )
	set(CMAKE_SYSTEM_PROCESSOR "arm")
	set(ANDROID_NDK_ABI "armeabi")
	set(ANDROID_NDK_ABI_EXT "arm-linux-androideabi")
	set(ANDROID_NDK_GCC_PREFIX "arm-linux-androideabi")
	set(ANDROID_NDK_ARCH_CFLAGS "-D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ -Wno-psabi -march=armv5te -mtune=xscale -msoft-float -mthumb")
endif()	
if("${ANDROID_NDK_ARCH}" STREQUAL "armv7" )
	set(CMAKE_SYSTEM_PROCESSOR "arm")
	set(ANDROID_NDK_ABI "armeabi-v7a")
	set(ANDROID_NDK_ABI_EXT "arm-linux-androideabi")
	set(ANDROID_NDK_GCC_PREFIX "arm-linux-androideabi")
	set(ANDROID_NDK_ARCH_CFLAGS "-march=armv7-a -mfloat-abi=softfp")
	set(ANDROID_NDK_ARCH_LDFLAGS "-Wl,--fix-cortex-a8")
endif()
if("${ANDROID_NDK_ARCH}" STREQUAL "x86" )
	set(ANDROID_NDK_ABI "x86")
	set(ANDROID_NDK_ABI_EXT "x86")
	set(ANDROID_NDK_GCC_PREFIX "i686-linux-android")
endif()

if(ANDROID_NDK_TOOLCHAIN_DEBUG)
	message(STATUS "ANDROID_NDK_ABI - ${ANDROID_NDK_ABI}")
	message(STATUS "ANDROID_NDK_ABI_EXT - ${ANDROID_NDK_ABI_EXT}")
	message(STATUS "ANDROID_NDK_ARCH_CFLAGS - ${ANDROID_NDK_ARCH_CFLAGS}")
endif()

# global C flags
set(ANDROID_NDK_GLOBAL_CFLAGS "-fpic -fomit-frame-pointer -fno-strict-aliasing -finline-limit=64 -ffunction-sections -funwind-tables -fstack-protector")


# choose NDK STL implementation
set(ANDROID_NDK_STL_SUPPORTED "gnu-libstdc++;stlport;system;gabi++")
set(ANDROID_NDK_STL "stlport" CACHE STRING "Android NDK STL (${ANDROID_NDK_STL_SUPPORTED})")
set_property(CACHE ANDROID_NDK_STL PROPERTY STRINGS ${ANDROID_NDK_STL_SUPPORTED})


# set the Android Platform
set(ANDROID_API_SUPPORTED "android-8;android-9;android-14;android-18")
set(ANDROID_API "android-18" CACHE STRING "Android SDK API (${ANDROID_API_SUPPORTED})")
set_property(CACHE ANDROID_API PROPERTY STRINGS ${ANDROID_API_SUPPORTED})

# set sysroot - in Android this in function of Android API and architecture
set(ANDROID_NDK_SYSROOT)
if("${ANDROID_NDK_ARCH}" STREQUAL "arm" OR "${ANDROID_NDK_ARCH}" STREQUAL "armv7" )
	set(ANDROID_NDK_SYSROOT "${ANDROID_NDK_ROOT}/platforms/${ANDROID_API}/arch-arm" CACHE PATH "NDK sysroot" FORCE)
	message("setting ANDROID_NDK_SYSROOT to arm ${ANDROID_NDK_SYSROOT}")
elseif("${ANDROID_NDK_ARCH}" STREQUAL "x86")
	set(ANDROID_NDK_SYSROOT "${ANDROID_NDK_ROOT}/platforms/${ANDROID_API}/arch-x86" CACHE PATH "NDK sysroot" FORCE)
	message("setting ANDROID_NDK_SYSROOT to x86 ${ANDROID_NDK_SYSROOT}")
endif()

# set(CMAKE_C_COMPILER_WORKS 1)
# set(CMAKE_CXX_COMPILER_WORKS 1)

# set(CMAKE_SKIP_COMPATIBILITY_TESTS 1)

# set version
set(ANDROID_NDK_GCC_VERSION "4.6")

# STL
set(ANDROID_NDK_STL_CXXFLAGS)
set(ANDROID_NDK_STL_LIBRARYPATH)
set(ANDROID_NDK_STL_LDFLAGS)
if ("${ANDROID_NDK_STL}" STREQUAL "stlport") 
	set(ANDROID_NDK_STL_CXXFLAGS "-D_STLP_USE_SIMPLE_NODE_ALLOC -D_STLP_NO_EXCEPTIONS  -fno-exceptions -fno-rtti -I${ANDROID_NDK_ROOT}/sources/cxx-stl/${ANDROID_NDK_STL}/stlport") #-D_STLP_USE_NEWALLOC
	set(ANDROID_NDK_STL_LIBRARYPATH "${ANDROID_NDK_ROOT}/sources/cxx-stl/${ANDROID_NDK_STL}/libs/${ANDROID_NDK_ABI}")
	set(ANDROID_NDK_STL_LDFLAGS "-lstdc++")
else()
	set(ANDROID_NDK_STL_CXXFLAGS "-I${ANDROID_NDK_ROOT}/sources/cxx-stl/${ANDROID_NDK_STL}/include -I${ANDROID_NDK_ROOT}/sources/cxx-stl/${ANDROID_NDK_STL}/libs/${ANDROID_NDK_ABI}/include  -fno-exceptions -fno-rtti ")
	set(ANDROID_NDK_STL_LIBRARYPATH "${ANDROID_NDK_ROOT}/sources/cxx-stl/${ANDROID_NDK_STL}/libs/${ANDROID_NDK_ABI}")
	set(ANDROID_NDK_STL_LDFLAGS "-lstdc++")
endif()

# global linker flags
set(ANDROID_NDK_GLOBAL_LDFLAGS "-Wl,--no-undefined -Wl,-z,noexecstack -Wl,--gc-sections -Wl,-z,nocopyreloc")

# get the gcc companion lib
exec_program(
	${ANDROID_NDK_ROOT}/toolchains/${ANDROID_NDK_ABI_EXT}-${ANDROID_NDK_GCC_VERSION}/prebuilt/${ANDROID_NDK_HOST}/bin/${ANDROID_NDK_GCC_PREFIX}-gcc 
	ARGS "-print-libgcc-file-name"
	OUTPUT_VARIABLE ANDROID_NDK_GCC_COMPANIONLIBRARY
	)

get_filename_component(ANDROID_NDK_GCC_COMPANIONLIBRARY_PATH ${ANDROID_NDK_GCC_COMPANIONLIBRARY} PATH)
#set(CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES "${ANDROID_NDK_GCC_COMPANIONLIBRARY_PATH}")

# hack
#add_definitions(-static-libgcc)
#link_libraries(${ANDROID_NDK_GCC_COMPANIONLIBRARY})


# some overrides (see docs/STANDALONE-TOOLCHAIN.html) 
# set(CMAKE_C_FLAGS "-MMD -MP -MF ${ANDROID_NDK_GLOBAL_CFLAGS} ${ANDROID_NDK_GLOBAL_LDFLAGS} --sysroot=${ANDROID_NDK_SYSROOT} -DANDROID ${ANDROID_NDK_ARCH_CFLAGS} ${ANDROID_NDK_ARCH_LDFLAGS} -L${ANDROID_NDK_GCC_COMPANIONLIBRARY_PATH} -nostdlib -landroid -llog -lc -lm -lgcc" CACHE STRING "C flags" FORCE)
# set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} ${ANDROID_NDK_STL_CXXFLAGS} -L${ANDROID_NDK_STL_LIBRARYPATH} ${ANDROID_NDK_STL_LDFLAGS}" CACHE STRING "C++ flags" FORCE)

# libs
# set(CMAKE_SHARED_LINKER_FLAGS "${ANDROID_NDK_GCC_COMPANIONLIBRARY}" CACHE STRING "Linker flags" FORCE)
# set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${ANDROID_NDK_GCC_COMPANIONLIBRARY}" CACHE STRING "Linker flags" FORCE)

#message(STATUS "${ANDROID_NDK_GCC_COMPANIONLIBRARY_PATH}")

# set(CMAKE_C_FLAGS "-v ${ANDROID_NDK_GLOBAL_CFLAGS} ${ANDROID_NDK_GLOBAL_LDFLAGS} --sysroot=${ANDROID_NDK_SYSROOT} -DANDROID ${ANDROID_NDK_ARCH_CFLAGS} ${ANDROID_NDK_ARCH_LDFLAGS} -L${ANDROID_NDK_GCC_COMPANIONLIBRARY_PATH} -nostdlib -landroid -llog -lc -lm -lgcc")

#set(CMAKE_C_COMPILER "${ANDROID_NDK_ROOT}/toolchains/${ANDROID_NDK_ABI_EXT}-${ANDROID_NDK_GCC_VERSION}/prebuilt/${ANDROID_NDK_HOST}/bin/${ANDROID_NDK_GCC_PREFIX}-gcc" CACHE PATH "C Compiler")
#set(CMAKE_CXX_COMPILER "${ANDROID_NDK_ROOT}/toolchains/${ANDROID_NDK_ABI_EXT}-${ANDROID_NDK_GCC_VERSION}/prebuilt/${ANDROID_NDK_HOST}/bin/${ANDROID_NDK_GCC_PREFIX}-g++" CACHE PATH "C++ Compiler")
# 
# include(CMakeForceCompiler)
# CMAKE_FORCE_C_COMPILER("${CMAKE_C_COMPILER}" GNU)
# CMAKE_FORCE_CXX_COMPILER("${CMAKE_CXX_COMPILER}" GNU)

#set(COMMON_FLAGS "${CMAKE_C_FLAGS} --sysroot=${ANDROID_NDK_SYSROOT}")
set(COMMON_FLAGS "${CMAKE_C_FLAGS}")

set(CMAKE_C_FLAGS "${COMMON_FLAGS} --sysroot=${ANDROID_NDK_SYSROOT}" CACHE STRING "C Flags" FORCE)
set(CMAKE_CXX_FLAGS "${COMMON_FLAGS} --sysroot=${ANDROID_NDK_SYSROOT} ${ANDROID_NDK_STL_CXXFLAGS} -L${ANDROID_NDK_STL_LIBRARYPATH} ${ANDROID_NDK_STL_LDFLAGS}" CACHE STRING "C++ Flags" FORCE)

set(CMAKE_C_COMPILER ${ANDROID_NDK_GCC_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER ${ANDROID_NDK_GCC_PREFIX}-g++)

if(ANDROID_NDK_TOOLCHAIN_DEBUG)
	message(STATUS "GCC companion library: ${ANDROID_NDK_GCC_COMPANIONLIBRARY}")
	message(STATUS "CMAKE_C_COMPILER: ${CMAKE_C_COMPILER}")
	message(STATUS "CMAKE_CXX_COMPILER: ${CMAKE_CXX_COMPILER}")
	message(STATUS "ANDROID_NDK_SYSROOT: ${ANDROID_NDK_SYSROOT}")
endif()


# root path
set(CMAKE_FIND_ROOT_PATH "${ANDROID_NDK_SYSROOT}")

set(CMAKE_SYSTEM_PROGRAM_PATH 	"${ANDROID_NDK_ROOT}/toolchains/${ANDROID_NDK_ABI_EXT}-${ANDROID_NDK_GCC_VERSION}/prebuilt/${ANDROID_NDK_HOST}/bin/"
	)
	
# search paths
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)



# # specify compiler
# set(CMAKE_C_COMPILER   "${ANDROID_NDK_ROOT}/toolchains/${ANDROID_NDK_ABI_EXT}-${ANDROID_NDK_GCC_VERSION}/prebuilt/${ANDROID_NDK_HOST}/bin/${ANDROID_NDK_GCC_PREFIX}-gcc" CACHE PATH "C compiler" FORCE)
# set(CMAKE_CXX_COMPILER "${ANDROID_NDK_ROOT}/toolchains/${ANDROID_NDK_ABI_EXT}-${ANDROID_NDK_GCC_VERSION}/prebuilt/${ANDROID_NDK_HOST}/bin/${ANDROID_NDK_GCC_PREFIX}-g++" CACHE PATH "C++ compiler" FORCE)
# 

