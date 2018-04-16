# Copyright 2011,2012,2016 Free Software Foundation, Inc.
#
# This file is part of GNU Radio
#
# GNU Radio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# GNU Radio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNU Radio; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street,
# Boston, MA 02110-1301, USA.

########################################################################
# Setup library
########################################################################
include(GrPlatform) #define LIB_SUFFIX

include_directories(${Boost_INCLUDE_DIR})
link_directories(${Boost_LIBRARY_DIRS})
list(APPEND learn_sources
    my_add_ff_impl.cc
    signal_detect_impl.cc
    history_test_impl.cc
    message_test_impl.cc
    tag_test_impl.cc
    clip_stream_impl.cc )

set(learn_sources "${learn_sources}" PARENT_SCOPE)
if(NOT learn_sources)
	MESSAGE(STATUS "No C++ sources... skipping lib/")
	return()
endif(NOT learn_sources)

add_library(gnuradio-learn SHARED ${learn_sources})
target_link_libraries(gnuradio-learn ${Boost_LIBRARIES} ${GNURADIO_ALL_LIBRARIES})
set_target_properties(gnuradio-learn PROPERTIES DEFINE_SYMBOL "gnuradio_learn_EXPORTS")

if(APPLE)
    set_target_properties(gnuradio-learn PROPERTIES
        INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib"
    )
endif(APPLE)

########################################################################
# Install built library files
########################################################################
include(GrMiscUtils)
GR_LIBRARY_FOO(gnuradio-learn RUNTIME_COMPONENT "learn_runtime" DEVEL_COMPONENT "learn_devel")

########################################################################
# Build and register unit test
########################################################################
include(GrTest)

include_directories(${CPPUNIT_INCLUDE_DIRS})

list(APPEND test_learn_sources
    ${CMAKE_CURRENT_SOURCE_DIR}/test_learn.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/qa_learn.cc
)

add_executable(test-learn ${test_learn_sources})

target_link_libraries(
  test-learn
  ${GNURADIO_RUNTIME_LIBRARIES}
  ${Boost_LIBRARIES}
  ${CPPUNIT_LIBRARIES}
  gnuradio-learn
)

GR_ADD_TEST(test_learn test-learn)

########################################################################
# Print summary
########################################################################
message(STATUS "Using install prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "Building for version: ${VERSION} / ${LIBVER}")

