cmake_minimum_required(VERSION 3.12)

add_custom_target(SvgLogos ALL
                  DEPENDS metalogo-black-512.svg metalogo-black-200.svg metalogo-white-512.svg metalogo-white-200.svg)

add_custom_target(PngLogos ALL
                  DEPENDS metalogo-black-512.png metalogo-black-200.png metalogo-white-512.png metalogo-white-200.png)

add_custom_command(OUTPUT metalogo-black-512.png metalogo-black-200.png metalogo-white-512.png metalogo-white-200.png
                   COMMAND convert -background none ${CMAKE_CURRENT_BINARY_DIR}/metalogo-black-512.svg ${CMAKE_CURRENT_BINARY_DIR}/metalogo-black-512.png
                   COMMAND convert -background none ${CMAKE_CURRENT_BINARY_DIR}/metalogo-black-200.svg ${CMAKE_CURRENT_BINARY_DIR}/metalogo-black-200.png
                   COMMAND convert -background none ${CMAKE_CURRENT_BINARY_DIR}/metalogo-white-512.svg ${CMAKE_CURRENT_BINARY_DIR}/metalogo-white-512.png
                   COMMAND convert -background none ${CMAKE_CURRENT_BINARY_DIR}/metalogo-white-200.svg ${CMAKE_CURRENT_BINARY_DIR}/metalogo-white-200.png)

add_custom_command(OUTPUT metalogo-black-512.svg metalogo-black-200.svg metalogo-white-512.svg metalogo-white-200.svg
                   COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/metalogo.sh ARGS 256 0.80 30 black white > ${CMAKE_CURRENT_BINARY_DIR}/metalogo-black-512.svg
		   COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/metalogo.sh ARGS 100 0.80 30 black white > ${CMAKE_CURRENT_BINARY_DIR}/metalogo-black-200.svg
                   COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/metalogo.sh ARGS 256 0.80 30 white black > ${CMAKE_CURRENT_BINARY_DIR}/metalogo-white-512.svg
                   COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/metalogo.sh ARGS 100 0.80 30 white black > ${CMAKE_CURRENT_BINARY_DIR}/metalogo-white-200.svg)


