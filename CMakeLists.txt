cmake_minimum_required(VERSION 3.0 FATAL_ERROR)
project(prediction-app)

find_package(Torch REQUIRED)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${TORCH_CXX_FLAGS}")

#add_executable(prediction-app prediction-app.cpp)
add_library(prediction-app SHARED prediction-app.cpp)
target_link_libraries(prediction-app "${TORCH_LIBRARIES}")
#set_property(TARGET prediction-app PROPERTY CXX_STANDARD 14)

SET(LIBRARY_OUTPUT_PATH "C:/Users/Thembi/AppData/Roaming/MetaQuotes/Terminal/67381DD86A2959850232C0BA725E5966/MQL5/Libraries/")
# The following code block is suggested to be used on Windows.
# According to https://github.com/pytorch/pytorch/issues/25457,
# the DLLs need to be copied to avoid memory errors.
if (MSVC)
  file(GLOB TORCH_DLLS "${TORCH_INSTALL_PREFIX}/lib/*.dll")
  add_custom_command(TARGET prediction-app
                     POST_BUILD
                     COMMAND ${CMAKE_COMMAND} -E copy_if_different
                     ${TORCH_DLLS}
                     $<TARGET_FILE_DIR:prediction-app>)
endif (MSVC)
