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

#ifndef INCLUDED_SEFDM_HEADER_SYNCHRONIZATION_IMPL_H
#define INCLUDED_SEFDM_HEADER_SYNCHRONIZATION_IMPL_H

#include <sefdm/header_synchronization.h>

namespace gr {
  namespace sefdm {

    class header_synchronization_impl : public header_synchronization
    {
     private:
      // Nothing to declare in this block.

      const int  d_hdr_no_pld_len;

      const int  d_hdr_n_sym;
      const int  d_hdr_len_cp;

      const int  d_pld_n_sym;
      const int  d_pld_len_cp;

      const int  d_sym_fft_size; // FFT-point == OFDM-sym len
      const int  d_sym_sefdm_len; // alfa == d_sym_sefdm_len / d_sym_ifft_size
      const int  d_sym_len_right_gi;
      const int  d_sym_len_left_gi;
      int        d_sym_n_inf_subcarr;

      int  d_n_left_inf_subcarr; // Кол-во информационных поднесущих слева от нулевой частоты
      int  d_n_right_inf_subcarr;
      int  d_n_add_zero;

      void
      sefdm_hdr_synch_in_handler(pmt::pmt_t msg);

      inline std::vector<gr_complex>
      estimate_channel(const std::vector<std::vector<gr_complex>>&  hdr_R) const;

      inline void
      equalizer(std::vector<gr_complex>&        R,
                const std::vector<gr_complex>&  channel_freq_response) const;

      inline void
      estimate_residual_freq_offset(const std::vector<std::vector<gr_complex>>&  hdr_R,
                                    float&  const_fi,
                                    float&  dfi,
                                    int&    symNo) const;

      inline void
      compensate_residual_freq_offset(std::vector<gr_complex>&  R,
                                      const float&                           const_fi,
                                      const float&                           dfi,
                                      int&                                   symNo) const;

      inline std::vector<int8_t>
      slicing_bpsk(const std::vector<gr_complex>&  R) const;

     public:
      header_synchronization_impl(int hdr_pld_len,
                                        int hdr_n_sym, int hdr_len_cp,
                                        int pld_n_sym, int pld_len_cp,
                                        int sym_fft_size, int sefdm_sym_len, int sym_len_right_gi, int sym_len_left_gi);

      ~header_synchronization_impl();

      // Where all the action really happens
      void forecast (int noutput_items, gr_vector_int &ninput_items_required);

      int general_work(int noutput_items,
           gr_vector_int &ninput_items,
           gr_vector_const_void_star &input_items,
           gr_vector_void_star &output_items);


    };

  } // namespace sefdm
} // namespace gr

#endif /* INCLUDED_SEFDM_HEADER_SYNCHRONIZATION_IMPL_H */

