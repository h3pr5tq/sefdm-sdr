INCLUDE(FindPkgConfig)
PKG_CHECK_MODULES(PC_LEARN learn)

FIND_PATH(
    LEARN_INCLUDE_DIRS
    NAMES learn/api.h
    HINTS $ENV{LEARN_DIR}/include
        ${PC_LEARN_INCLUDEDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/include
          /usr/local/include
          /usr/include
)

FIND_LIBRARY(
    LEARN_LIBRARIES
    NAMES gnuradio-learn
    HINTS $ENV{LEARN_DIR}/lib
        ${PC_LEARN_LIBDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/lib
          ${CMAKE_INSTALL_PREFIX}/lib64
          /usr/local/lib
          /usr/local/lib64
          /usr/lib
          /usr/lib64
)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LEARN DEFAULT_MSG LEARN_LIBRARIES LEARN_INCLUDE_DIRS)
MARK_AS_ADVANCED(LEARN_LIBRARIES LEARN_INCLUDE_DIRS)

