INCLUDE(FindPkgConfig)
PKG_CHECK_MODULES(PC_SEFDM sefdm)

FIND_PATH(
    SEFDM_INCLUDE_DIRS
    NAMES sefdm/api.h
    HINTS $ENV{SEFDM_DIR}/include
        ${PC_SEFDM_INCLUDEDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/include
          /usr/local/include
          /usr/include
)

FIND_LIBRARY(
    SEFDM_LIBRARIES
    NAMES gnuradio-sefdm
    HINTS $ENV{SEFDM_DIR}/lib
        ${PC_SEFDM_LIBDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/lib
          ${CMAKE_INSTALL_PREFIX}/lib64
          /usr/local/lib
          /usr/local/lib64
          /usr/lib
          /usr/lib64
)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(SEFDM DEFAULT_MSG SEFDM_LIBRARIES SEFDM_INCLUDE_DIRS)
MARK_AS_ADVANCED(SEFDM_LIBRARIES SEFDM_INCLUDE_DIRS)

