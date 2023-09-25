cmake_minimum_required(VERSION 3.7)
project(ps_cpp)

set(CMAKE_CXX_STANDARD 17)


find_package(RapidJSON CONFIG REQUIRED)
if(RAPIDJSON_FOUND)
    message(STATUS "Found RapidJSON version")
    include_directories(${RAPIDJSON_INCLUDE_DIRS})
else()
    message(STATUS "Could not found RapidJson")
endif()


find_package(CURL REQUIRED)
if(CURL_FOUND)
    message(STATUS "Found CURL version: ${CURL_VERSION_STRING}")
    message(STATUS "Using CURL include dir(s): ${CURL_INCLUDE_DIRS}")
    message(STATUS "Using CURL lib(s): ${CURL_LIBRARIES}")
    include_directories(${CURL_INCLUDE_DIRS})
else()
    message(FATAL_ERROR "Could not find CURL")
endif()

# Setze den Pfad zum RapidJSON-Include-Verzeichnis
# set(RAPIDJSON_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include/rapidjson)

include_directories(
        ${CMAKE_SOURCE_DIR}/include
        ${CURL_INCLUDE_DIR}
        ${RAPIDJSON_INCLUDE_DIR}
)

add_executable(ps_cpp scr/main.cpp scr/handling_vbb.cpp include/handling_vbb.h)
target_link_libraries(ps_cpp ${CURL_LIBRARIES} ${RAPIDJSON_LIBRARIES})
#target_link_libraries(ps_cpp RapidJSON )
#add_dependencies(ps_cpp rapidjson)

target_compile_options(ps_cpp PRIVATE -g3 -O0)
install(TARGETS ps_cpp DESTINATION bin)


