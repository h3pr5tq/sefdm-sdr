/* -*- c++ -*- */

#define SEFDM_API

%include "gnuradio.i"			// the common stuff

//load generated python docstrings
%include "sefdm_swig_doc.i"

%{
#include "sefdm/ieee_802_11a_preamble_detection.h"
#include "sefdm/extract_packets_from_stream.h"
#include "sefdm/ieee_802_11a_coarse_time_synch.h"
#include "sefdm/ofdm_symbol_demodulation.h"
#include "sefdm/ieee_802_11a_synchronization.h"
#include "sefdm/ieee_802_11a_ofdm_symbol_demodulation.h"
%}

%include "sefdm/ieee_802_11a_preamble_detection.h"
GR_SWIG_BLOCK_MAGIC2(sefdm, ieee_802_11a_preamble_detection);
%include "sefdm/extract_packets_from_stream.h"
GR_SWIG_BLOCK_MAGIC2(sefdm, extract_packets_from_stream);
%include "sefdm/ieee_802_11a_coarse_time_synch.h"
GR_SWIG_BLOCK_MAGIC2(sefdm, ieee_802_11a_coarse_time_synch);
%include "sefdm/ofdm_symbol_demodulation.h"
GR_SWIG_BLOCK_MAGIC2(sefdm, ofdm_symbol_demodulation);
%include "sefdm/ieee_802_11a_synchronization.h"
GR_SWIG_BLOCK_MAGIC2(sefdm, ieee_802_11a_synchronization);
%include "sefdm/ieee_802_11a_ofdm_symbol_demodulation.h"
GR_SWIG_BLOCK_MAGIC2(sefdm, ieee_802_11a_ofdm_symbol_demodulation);
