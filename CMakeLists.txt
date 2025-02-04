cmake_minimum_required(VERSION 3.1 FATAL_ERROR)

# ***********************************************************************
# JKU 2022-07-15: Apple target architecture
# place before any project() or enable_language() calls
# ***********************************************************************
if (APPLE AND APPLE_TARGET_ARCHITECTURE)

    execute_process(
        COMMAND uname -m
        RESULT_VARIABLE result
        OUTPUT_VARIABLE APPLE_FOUND_ARCHITECTURE
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    message(STATUS "Detected architecture: ${APPLE_FOUND_ARCHITECTURE}")
    
    if (APPLE_FOUND_ARCHITECTURE STREQUAL "arm64")
        if (APPLE_TARGET_ARCHITECTURE STREQUAL "x86_64")
            
            # ATTENTION: When compiling refs for x86 on a arm machine, samarai crashes
            # unpredictably. It's unknown which library causes the crashs (cryptopp for sure but
            # others too). As of 2022-08-05 we use libraries that have been compiled on a x86 mac
            message(FATAL_ERROR "Cannot target x86 on arm64 machine, compile the library on a x86 mac")
            
            set(CMAKE_OSX_ARCHITECTURES "x86_64" CACHE STRING "")
            message(STATUS "Target architecture: ${APPLE_TARGET_ARCHITECTURE}")
            
        elseif (APPLE_TARGET_ARCHITECTURE STREQUAL "arm64")
            message("Targeting arm64 on arm64 machine")
        endif()
    elseif (APPLE_FOUND_ARCHITECTURE STREQUAL "x86_64")
        if (APPLE_TARGET_ARCHITECTURE STREQUAL "x86_64")
            message("Targeting x86 on x86 machine")
        elseif (APPLE_TARGET_ARCHITECTURE STREQUAL "arm64")
            message(FATAL_ERROR "Cannot target arm64 on a x86 machine")
        endif()  
    else()
        message(FATAL_ERROR "Unsupported architecture detected")
    endif()

endif ()

###################################################################################################
###################################################################################################

file(STRINGS "${CMAKE_CURRENT_LIST_DIR}/src/oatpp/core/base/Environment.hpp" OATPP_VERSION_MACRO REGEX "#define OATPP_VERSION \"[0-9]+.[0-9]+.[0-9]+\"$")
string(REGEX REPLACE "#define OATPP_VERSION \"([0-9]+.[0-9]+.[0-9]+)\"$" "\\1" oatpp_VERSION "${OATPP_VERSION_MACRO}")

###################################################################################################
## These variables are passed to oatpp-module-install.cmake script
## use these variables to configure module installation

set(OATPP_THIS_MODULE_NAME oatpp) ## name of the module (also name of folders in installation dirs)
set(OATPP_THIS_MODULE_VERSION ${oatpp_VERSION}) ## version of the module (also sufix of folders in installation dirs)
set(OATPP_THIS_MODULE_LIBRARIES oatpp oatpp-test) ## list of libraries to find when find_package is called
set(OATPP_THIS_MODULE_TARGETS oatpp oatpp-test) ## list of targets to install
set(OATPP_THIS_MODULE_DIRECTORIES oatpp oatpp-test) ## list of directories to install

###################################################################################################

project(oatpp VERSION ${OATPP_THIS_MODULE_VERSION} LANGUAGES CXX)

option(BUILD_SHARED_LIBS "Build shared libraries" OFF)
option(OATPP_INSTALL "Create installation target for oat++" ON)
option(OATPP_BUILD_TESTS "Create test target for oat++" ON)
option(OATPP_LINK_ATOMIC "Link atomic library for other platform than MSVC|MINGW|APPLE|FreeBSD" ON)
option(OATPP_MSVC_LINK_STATIC_RUNTIME "MSVC: Link with static runtime (/MT and /MTd)." OFF)

###################################################################################################
# MacOS target (JKU 2022-05-15)
###################################################################################################

if (APPLE) 
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.14" CACHE STRING "Minimum OS X deployment version" FORCE)
endif ()

###################################################################################################
## COMPILATION CONFIG #############################################################################
###################################################################################################

option(OATPP_DISABLE_ENV_OBJECT_COUNTERS "Disable object counting for Release builds for better performance" OFF)
option(OATPP_DISABLE_POOL_ALLOCATIONS "This will make oatpp::base::memory::MemoryPool, method obtain and free call new and delete directly" OFF)

set(OATPP_THREAD_HARDWARE_CONCURRENCY "AUTO" CACHE STRING "Predefined value for function oatpp::concurrency::Thread::getHardwareConcurrency()")
set(OATPP_THREAD_DISTRIBUTED_MEM_POOL_SHARDS_COUNT "10" CACHE STRING "Number of shards of ThreadDistributedMemoryPool")

option(OATPP_COMPAT_BUILD_NO_THREAD_LOCAL "Disable 'thread_local' feature" OFF)
option(OATPP_COMPAT_BUILD_NO_SET_AFFINITY "No 'pthread_setaffinity_np' method" OFF)

option(OATPP_DISABLE_LOGV "DISABLE logs priority V" OFF)
option(OATPP_DISABLE_LOGD "DISABLE logs priority D" OFF)
option(OATPP_DISABLE_LOGI "DISABLE logs priority I" OFF)
option(OATPP_DISABLE_LOGW "DISABLE logs priority W" OFF)
option(OATPP_DISABLE_LOGE "DISABLE logs priority E" OFF)

## Print config ##################################################################################

message("\n############################################################################")
message("## oatpp module compilation config:\n")

message("OATPP_DISABLE_ENV_OBJECT_COUNTERS=${OATPP_DISABLE_ENV_OBJECT_COUNTERS}")
message("OATPP_DISABLE_POOL_ALLOCATIONS=${OATPP_DISABLE_POOL_ALLOCATIONS}")
message("OATPP_THREAD_HARDWARE_CONCURRENCY=${OATPP_THREAD_HARDWARE_CONCURRENCY}")
message("OATPP_THREAD_DISTRIBUTED_MEM_POOL_SHARDS_COUNT=${OATPP_THREAD_DISTRIBUTED_MEM_POOL_SHARDS_COUNT}")

message("OATPP_COMPAT_BUILD_NO_THREAD_LOCAL=${OATPP_COMPAT_BUILD_NO_THREAD_LOCAL}")

## Set definitions ###############################################################################

if(OATPP_DISABLE_ENV_OBJECT_COUNTERS)
    add_definitions(-DOATPP_DISABLE_ENV_OBJECT_COUNTERS)
endif()

if(OATPP_DISABLE_POOL_ALLOCATIONS)
    add_definitions (-DOATPP_DISABLE_POOL_ALLOCATIONS)
endif()

set(AUTO_VALUE AUTO)
if(NOT OATPP_THREAD_HARDWARE_CONCURRENCY STREQUAL AUTO_VALUE)
    add_definitions (-DOATPP_THREAD_HARDWARE_CONCURRENCY=${OATPP_THREAD_HARDWARE_CONCURRENCY})
endif()

add_definitions (
    -DOATPP_THREAD_DISTRIBUTED_MEM_POOL_SHARDS_COUNT=${OATPP_THREAD_DISTRIBUTED_MEM_POOL_SHARDS_COUNT}
)

if(OATPP_COMPAT_BUILD_NO_THREAD_LOCAL)
    add_definitions(-DOATPP_COMPAT_BUILD_NO_THREAD_LOCAL)
endif()

if(OATPP_COMPAT_BUILD_NO_SET_AFFINITY)
    add_definitions(-DOATPP_COMPAT_BUILD_NO_SET_AFFINITY)
endif()

if(OATPP_DISABLE_LOGV)
    add_definitions(-DOATPP_DISABLE_LOGV)
endif()

if(OATPP_DISABLE_LOGD)
    add_definitions(-DOATPP_DISABLE_LOGD)
endif()

if(OATPP_DISABLE_LOGI)
    add_definitions(-DOATPP_DISABLE_LOGI)
endif()

if(OATPP_DISABLE_LOGW)
    add_definitions(-DOATPP_DISABLE_LOGW)
endif()

if(OATPP_DISABLE_LOGE)
    add_definitions(-DOATPP_DISABLE_LOGE)
endif()

if(CMAKE_COMPILER_IS_GNUCXX AND ${CMAKE_CXX_COMPILER_VERSION} VERSION_LESS 5.0)
    add_definitions(-DOATPP_DISABLE_STD_PUT_TIME)
endif()

message("\n############################################################################\n")

###################################################################################################

message("oatpp version: '${OATPP_THIS_MODULE_VERSION}'")

#SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address")
#SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=thread")

include(cmake/msvc-runtime.cmake)
configure_msvc_runtime()

add_subdirectory(src)

if(OATPP_BUILD_TESTS)
    enable_testing()
    add_subdirectory(test)
endif()
