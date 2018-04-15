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

#ifndef INCLUDED_SEFDM_IEEE_802_11A_COARSE_TIME_SYNCH_IMPL_H
#define INCLUDED_SEFDM_IEEE_802_11A_COARSE_TIME_SYNCH_IMPL_H

#include <sefdm/ieee_802_11a_coarse_time_synch.h>

namespace gr {
  namespace sefdm {

    class ieee_802_11a_coarse_time_synch_impl : public ieee_802_11a_coarse_time_synch
    {
     private:
      // Nothing to declare in this block.
      const int  d_cts_segment_len; // отрезок (кол-во отсчётов) на котором выполняется CTS
      const int  d_cts_summation_window;
      const int  d_cts_signal_offset;

      // параметры алгоритма FFS
      const int  d_ffs_offset_from_cts; // смещение от cts_est, чтобы затронуть только STS
      const int  d_ffs_summation_window; // L
      const int  d_ffs_signal_offset; // D

      // параметры алгоритма FTS
      const int  d_fts_offset_from_cts; // [(10STS + LGI) - x], где x  оцениваем по моделированию CTS
                                        // Должен 100% попасть первый отсчёт первого LTS
      const int  d_fts_segment_len; // Оцениваем по моделированию CTS; данный параметр связан с x
                                    // Если брать слишком большой, можем затронуть второй LTS --> получим второй пик, который не нужен
      const int  d_fts_etalon_seq_len; // Коррелируем с первыми 32 отсчётами LTS (до 64 можно брать)

      const int  d_num_ofdm_sym_in_payload;

      const int  d_subcarriers_num;

      void
      in_handler_function(pmt::pmt_t msg);

      inline int
      estimate_coarse_time_offset(const gr_complex* in) const;

      inline float
      estimate_fine_freq_offset(const gr_complex* in, int cts_est) const;

      inline int
      estimate_fine_time_offset(const gr_complex* in, int cts_est, float ffs_est) const;

      inline std::vector<gr_complex>
      estimate_channel(const gr_complex* in, float ffs_est, int fts_est) const;

     public:
      ieee_802_11a_coarse_time_synch_impl();
      ~ieee_802_11a_coarse_time_synch_impl();

      // Where all the action really happens
      void forecast (int noutput_items, gr_vector_int &ninput_items_required);

      int general_work(int noutput_items,
           gr_vector_int &ninput_items,
           gr_vector_const_void_star &input_items,
           gr_vector_void_star &output_items);
    };

  } // namespace sefdm
} // namespace gr

#endif /* INCLUDED_SEFDM_IEEE_802_11A_COARSE_TIME_SYNCH_IMPL_H */

