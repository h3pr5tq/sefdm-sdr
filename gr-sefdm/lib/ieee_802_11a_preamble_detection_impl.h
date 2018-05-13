/* -*- c++ -*- */
/* 
 * Copyright 2018 <+YOU OR YOUR COMPANY+>.
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

#ifndef INCLUDED_SEFDM_IEEE_802_11A_PREAMBLE_DETECTION_IMPL_H
#define INCLUDED_SEFDM_IEEE_802_11A_PREAMBLE_DETECTION_IMPL_H

#include <sefdm/ieee_802_11a_preamble_detection.h>

// Если преамбула полностью не вмещается в буфере,
// то 1 - обработать в следующем вызове general_work()
// (чтобы не было два детектирования пакета на одной преамбуле)
//
// 0 - никак не обрабатывать этот случай
#define HANDLE_PRMBL_NEXT_WORK_CALL  1

namespace gr {
  namespace sefdm {

    class ieee_802_11a_preamble_detection_impl : public ieee_802_11a_preamble_detection
    {
     private:
      // Nothing to declare in this block.
      const int    d_summation_window;
      const int    d_signal_offset;
      const float  d_detection_threshold;
      const int    d_detect_thr_cntr_max_val;
//      const bool   d_use_recursive_algorithm;
      const float  d_eps;

      const std::string  d_tag_key;
      const int          d_packet_len_with_margin;

      unsigned  d_detected_pckt_num; // кол-во обнаруженных пакетов

      // debug
      int d_cntr;

      inline gr_complex
      calc_autocorr(const gr_complex* sig) const;

      inline float
      calc_energy(const gr_complex* sig) const;

      inline float
      calc_detection_metric(gr_complex autocorr, float energy) const;

      inline void
      debug_print(int noutput_items, int ninput_items);

     public:
      ieee_802_11a_preamble_detection_impl(int summation_window,
                                           int signal_offset,
                                           float detection_threshold,
                                           int detect_thr_cntr_max_val,
//                                           bool use_recursive_algorithm,
                                           float eps,
                                           const std::string& tag_key,
                                           int packet_len,
                                           int margin);
      ~ieee_802_11a_preamble_detection_impl();

      // Where all the action really happens
      void forecast (int noutput_items, gr_vector_int &ninput_items_required);

      int general_work(int noutput_items,
           gr_vector_int &ninput_items,
           gr_vector_const_void_star &input_items,
           gr_vector_void_star &output_items);
    };

  } // namespace sefdm
} // namespace gr

#endif /* INCLUDED_SEFDM_IEEE_802_11A_PREAMBLE_DETECTION_IMPL_H */

