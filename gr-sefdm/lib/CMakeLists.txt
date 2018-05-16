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
list(APPEND sefdm_sources
    ieee_802_11a_preamble_detection_impl.cc
    extract_packets_from_stream_impl.cc
    ieee_802_11a_coarse_time_synch_impl.cc
    ofdm_symbol_demodulation_impl.cc
    ieee_802_11a_synchronization_impl.cc
    ieee_802_11a_ofdm_symbol_demodulation_impl.cc
    header_synchronization_impl.cc
    mf_demodulator_impl.cc )

set(sefdm_sources "${sefdm_sources}" PARENT_SCOPE)
if(NOT sefdm_sources)
	MESSAGE(STATUS "No C++ sources... skipping lib/")
	return()
endif(NOT sefdm_sources)

add_library(gnuradio-sefdm SHARED ${sefdm_sources})
target_link_libraries(gnuradio-sefdm ${Boost_LIBRARIES} ${GNURADIO_ALL_LIBRARIES})
set_target_properties(gnuradio-sefdm PROPERTIES DEFINE_SYMBOL "gnuradio_sefdm_EXPORTS")

if(APPLE)
    set_target_properties(gnuradio-sefdm PROPERTIES
        INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib"
    )
endif(APPLE)

########################################################################
# Install built library files
########################################################################
include(GrMiscUtils)
GR_LIBRARY_FOO(gnuradio-sefdm RUNTIME_COMPONENT "sefdm_runtime" DEVEL_COMPONENT "sefdm_devel")

########################################################################
# Build and register unit test
########################################################################
include(GrTest)

include_directories(${CPPUNIT_INCLUDE_DIRS})
list(APPEND test_sefdm_sources
    ${CMAKE_CURRENT_SOURCE_DIR}/test_sefdm.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/qa_sefdm.cc
    )

add_executable(test-sefdm ${test_sefdm_sources})

target_link_libraries(
  test-sefdm
  ${GNURADIO_RUNTIME_LIBRARIES}
  ${Boost_LIBRARIES}
  ${CPPUNIT_LIBRARIES}
  gnuradio-sefdm
)

GR_ADD_TEST(test_sefdm test-sefdm)

########################################################################
# Print summary
########################################################################
message(STATUS "Using install prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "Building for version: ${VERSION} / ${LIBVER}")

