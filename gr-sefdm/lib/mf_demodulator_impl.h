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

#ifndef INCLUDED_SEFDM_MF_DEMODULATOR_IMPL_H
#define INCLUDED_SEFDM_MF_DEMODULATOR_IMPL_H

#include <sefdm/mf_demodulator.h>

namespace gr {
  namespace sefdm {

    class mf_demodulator_impl : public mf_demodulator
    {
     private:
      // Nothing to declare in this block.
      const int  d_pld_n_sym;
      const int  d_sym_fft_size;
      const int  d_sym_sefdm_len;
      const int  d_sym_right_gi_len;
      const int  d_sym_left_gi_len;

      const bool  d_channel_compensation__is_make;
      const bool  d_phase_offset_compensation__is_make;

      int  d_sym_n_inf_subcarr;
      int  d_sym_n_right_inf_subcarr;
      int  d_sym_n_left_inf_subcarr;

      int  d_add_zero_subcarr;

      const int  d_pld_without_cp_len;

      void
      mf_demodulator_in_handler(pmt::pmt_t msg);

      inline void
      equalizer(std::vector<gr_complex>&        R,
                const std::vector<gr_complex>&  channel_freq_response) const;

      inline void
      compensate_residual_freq_offset(std::vector<gr_complex>&  R,
                                      const float&  const_fi,
                                      const float&  dfi,
                                      int&    symNo) const;

     public:
      mf_demodulator_impl(int pld_n_sym,
                          int sym_fft_size, int sym_sefdm_len, int sym_right_gi_len, int sym_left_gi_len,
                          bool channel_est__is_make, bool phase_offset_compensation__is_make);
      ~mf_demodulator_impl();

      // Where all the action really happens
      void forecast (int noutput_items, gr_vector_int &ninput_items_required);

      int general_work(int noutput_items,
           gr_vector_int &ninput_items,
           gr_vector_const_void_star &input_items,
           gr_vector_void_star &output_items);
    };

  } // namespace sefdm
} // namespace gr

#endif /* INCLUDED_SEFDM_MF_DEMODULATOR_IMPL_H */

