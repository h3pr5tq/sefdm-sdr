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

#ifndef INCLUDED_LEARN_SIGNAL_DETECT_IMPL_H
#define INCLUDED_LEARN_SIGNAL_DETECT_IMPL_H

#include <learn/signal_detect.h>

namespace gr {
  namespace learn {

    class signal_detect_impl : public signal_detect
    {
     private:
      // Nothing to declare in this block.
      const int    d_summation_window;
      const int    d_signal_offset;
      const float  d_detection_threshold;

//      bool        d_is_first_metric_calc;
//      gr_complex  d_prev_autocorr;
//      float       d_prev_energy;

      // @sig - pointer to last element of array
      // @sig[d_summation_window + d_signal_offset]
      gr_complex
      calc_autocorr(const gr_complex* sig) const;

      float
      calc_energy(const gr_complex* sig) const;


     public:
      signal_detect_impl(int summation_window, int signal_offset, float detection_threshold);
      ~signal_detect_impl();

      // Where all the action really happens
      void forecast (int noutput_items, gr_vector_int &ninput_items_required);

      int general_work(int noutput_items,
           gr_vector_int &ninput_items,
           gr_vector_const_void_star &input_items,
           gr_vector_void_star &output_items);
    };




  } // namespace learn
} // namespace gr

#endif /* INCLUDED_LEARN_SIGNAL_DETECT_IMPL_H */

