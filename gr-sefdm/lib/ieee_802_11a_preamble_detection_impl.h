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

namespace gr {
  namespace sefdm {

    class ieee_802_11a_preamble_detection_impl : public ieee_802_11a_preamble_detection
    {
     private:
      // Nothing to declare in this block.
      const int    d_summation_window;
      const int    d_signal_offset;
      const float  d_detection_threshold;
      const bool   d_use_recursive_algorithm;
      const float  d_eps;

      inline gr_complex
      calc_autocorr(const gr_complex* sig) const;

      inline float
      calc_energy(const gr_complex* sig) const;

      inline float
      calc_detection_metric(gr_complex autocorr, float energy) const;

     public:
      ieee_802_11a_preamble_detection_impl(int summation_window,
                                           int signal_offset,
                                           float detection_threshold,
                                           bool use_recursive_algorithm,
                                           float eps);
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

