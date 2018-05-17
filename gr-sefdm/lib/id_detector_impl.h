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

#ifndef INCLUDED_SEFDM_ID_DETECTOR_IMPL_H
#define INCLUDED_SEFDM_ID_DETECTOR_IMPL_H

#include <sefdm/id_detector.h>

namespace gr {
  namespace sefdm {

    class id_detector_impl : public id_detector
    {
     private:
      // Nothing to declare in this block.
      const int  d_n_iteration;

      const int  d_pld_n_sym;
      const int  d_sym_fft_size;
      const int  d_sym_sefdm_len;
      const int  d_sym_right_gi_len;
      const int  d_sym_left_gi_len;

      int  d_sym_n_inf_subcarr;
      int  d_sym_n_right_inf_subcarr;
      int  d_sym_n_left_inf_subcarr;

      const int  d_pld_without_cp_len;

      std::vector<std::vector<gr_complex>>  d_eye_c_matrix;

      void
      id_detector_in_handler(pmt::pmt_t msg);

      inline void
      soft_mapping(gr_complex*        s_cnsrt_est,
                   const gr_complex*  s_uncnsrt_est,
                   float              d) const;

     public:
      id_detector_impl(int n_iteration,
                       int pld_n_sym,
                       int sym_fft_size, int sym_sefdm_len, int sym_right_gi_len, int sym_left_gi_len);
      ~id_detector_impl();

      // Where all the action really happens
      void forecast (int noutput_items, gr_vector_int &ninput_items_required);

      int general_work(int noutput_items,
           gr_vector_int &ninput_items,
           gr_vector_const_void_star &input_items,
           gr_vector_void_star &output_items);
    };

  } // namespace sefdm
} // namespace gr

#endif /* INCLUDED_SEFDM_ID_DETECTOR_IMPL_H */

