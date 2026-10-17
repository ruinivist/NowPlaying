# Builds the CAVA QML bridge.
# Development and packaging consume the staged Plasma package in build/package.
cmake_minimum_required(VERSION 3.21)
project(NowPlaying LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
find_package(Qt6 6.4 REQUIRED COMPONENTS Core Qml)
qt_standard_project_setup()

set(CAVA_SOURCES native/cavasource.h native/cavasource.cpp)
qt_add_qml_module(nowplayingvisualizer SHARED
    URI NowPlaying.Native VERSION 1.0
    RESOURCE_PREFIX /qt/qml
    PLUGIN_TARGET nowplayingvisualizer
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml/NowPlaying/Native"
    SOURCES ${CAVA_SOURCES})
target_link_libraries(nowplayingvisualizer PRIVATE Qt6::Core Qt6::Qml)
target_include_directories(nowplayingvisualizer PRIVATE native)
qt_add_resources(nowplayingvisualizer cava_config
    PREFIX "/nowplaying"
    BASE "native"
    FILES native/cava.conf.in)
add_custom_target(stage ALL
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${CMAKE_BINARY_DIR}/package"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CMAKE_SOURCE_DIR}/package" "${CMAKE_BINARY_DIR}/package"
    COMMAND ${CMAKE_COMMAND} -E make_directory
        "${CMAKE_BINARY_DIR}/package/contents/ui/NowPlaying/Native"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_FILE:nowplayingvisualizer>
        "${CMAKE_BINARY_DIR}/qml/NowPlaying/Native/qmldir"
        "${CMAKE_BINARY_DIR}/qml/NowPlaying/Native/nowplayingvisualizer.qmltypes"
        "${CMAKE_BINARY_DIR}/package/contents/ui/NowPlaying/Native"
    DEPENDS nowplayingvisualizer)
