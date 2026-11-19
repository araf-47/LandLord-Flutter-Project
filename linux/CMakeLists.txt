cmake_minimum_required(VERSION 3.10)
project(landlord_app LANGUAGES CXX)

set(BINARY_NAME "landlord_app")
set(APPLICATION_ID "com.landlord.app")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Root directory of the flutter project.
set(FLUTTER_PROJECT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/..")

# Configuration provided by Flutter tool.
include(${FLUTTER_PROJECT_DIR}/linux/flutter/generated_plugins.cmake OPTIONAL)

add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
)

apply_standard_settings(${BINARY_NAME})
target_compile_options(${BINARY_NAME} PRIVATE -Wall -Werror)
target_compile_definitions(${BINARY_NAME} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:FLUTTER_RELEASE>")

target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)
