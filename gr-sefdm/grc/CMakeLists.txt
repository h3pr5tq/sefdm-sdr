# Copyright 2011 Free Software Foundation, Inc.
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
install(FILES
    sefdm_ieee_802_11a_preamble_detection.xml
    sefdm_extract_packets_from_stream.xml
    sefdm_ieee_802_11a_coarse_time_synch.xml
    sefdm_ofdm_symbol_demodulation.xml
    sefdm_ieee_802_11a_synchronization.xml
    sefdm_ieee_802_11a_ofdm_symbol_demodulation.xml
    sefdm_header_synchronization.xml
    sefdm_mf_demodulator.xml
    sefdm_id_detector.xml DESTINATION share/gnuradio/grc/blocks
)
