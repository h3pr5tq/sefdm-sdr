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

#ifndef INCLUDED_SEFDM_IEEE_802_11A_OFDM_SYMBOL_DEMODULATION_IMPL_H
#define INCLUDED_SEFDM_IEEE_802_11A_OFDM_SYMBOL_DEMODULATION_IMPL_H

#include <sefdm/ieee_802_11a_ofdm_symbol_demodulation.h>

namespace gr {
  namespace sefdm {

    class ieee_802_11a_ofdm_symbol_demodulation_impl : public ieee_802_11a_ofdm_symbol_demodulation
    {
     private:
      // Nothing to declare in this block.
      const int  d_ofdm_sym_num;
      const int  d_subcarriers_num;
      const int  d_channel_freq_response_len;

      void
      in2_handler_function(pmt::pmt_t msg);

      inline const gr_complex*
      get_channel_freq_response_from_msg(pmt::pmt_t&  msg) const;

     public:
      ieee_802_11a_ofdm_symbol_demodulation_impl(int ofdm_sym_num, int subcarriers_num);
      ~ieee_802_11a_ofdm_symbol_demodulation_impl();

      // Where all the action really happens
      void forecast (int noutput_items, gr_vector_int &ninput_items_required);

      int general_work(int noutput_items,
           gr_vector_int &ninput_items,
           gr_vector_const_void_star &input_items,
           gr_vector_void_star &output_items);
    };

  } // namespace sefdm
} // namespace gr

#endif /* INCLUDED_SEFDM_IEEE_802_11A_OFDM_SYMBOL_DEMODULATION_IMPL_H */

