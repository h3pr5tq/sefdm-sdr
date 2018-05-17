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

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gnuradio/io_signature.h>
#include <sefdm/common.h>
#include "id_detector_impl.h"

namespace gr {
  namespace sefdm {

    id_detector::sptr
    id_detector::make(int n_iteration,
                      int pld_n_sym,
                      int sym_fft_size, int sym_sefdm_len, int sym_right_gi_len, int sym_left_gi_len)
    {
      return gnuradio::get_initial_sptr
        ( new id_detector_impl(n_iteration,
                               pld_n_sym,
                               sym_fft_size, sym_sefdm_len, sym_right_gi_len, sym_left_gi_len) );
    }

    /*
     * The private constructor
     */
    id_detector_impl::id_detector_impl(int n_iteration,
                                       int pld_n_sym,
                                       int sym_fft_size, int sym_sefdm_len, int sym_right_gi_len, int sym_left_gi_len)
      : gr::block("id_detector",
              gr::io_signature::make(0, 0, sizeof(gr_complex)),
              gr::io_signature::make(0, 0, sizeof(gr_complex))),
      d_n_iteration(n_iteration),
      d_pld_n_sym(pld_n_sym),
      d_sym_fft_size(sym_fft_size),
      d_sym_sefdm_len(sym_sefdm_len),
      d_sym_right_gi_len(sym_right_gi_len),
      d_sym_left_gi_len(sym_left_gi_len),

      d_pld_without_cp_len(pld_n_sym * sym_sefdm_len)
    {
        get_inf_subcarrier_number(sym_sefdm_len, sym_right_gi_len, sym_left_gi_len,
                                  d_sym_n_inf_subcarr, d_sym_n_right_inf_subcarr, d_sym_n_left_inf_subcarr);

        float  alfa = float(sym_sefdm_len) / float(sym_fft_size);
        d_eye_c_matrix = get_eye_c_matrix(sym_sefdm_len, alfa);

        message_port_register_in(pmt::mp("id_detector_in"));
        message_port_register_out(pmt::mp("id_detector_out"));

        set_msg_handler( pmt::mp("id_detector_in"),
                         boost::bind(&id_detector_impl::id_detector_in_handler, this, _1) );
    }

    /*
     * Our virtual destructor.
     */
    id_detector_impl::~id_detector_impl()
    {
    }

    void
    id_detector_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
      for (auto& n : ninput_items_required) {
        n = noutput_items + history() - 1;
      }
    }

    int
    id_detector_impl::general_work (int noutput_items,
                       gr_vector_int &ninput_items,
                       gr_vector_const_void_star &input_items,
                       gr_vector_void_star &output_items)
    {
      const gr_complex *in = (const gr_complex *) input_items[0];
      gr_complex *out = (gr_complex *) output_items[0];

      // Do <+signal processing+>
      // Tell runtime system how many input items we consumed on
      // each input stream.
      consume_each (noutput_items);

      // Tell runtime system how many output items we produced.
      return noutput_items;
    }

    void
    id_detector_impl::id_detector_in_handler(pmt::pmt_t msg)
    {
      size_t       in_len;
      gr_complex*  in = pmt::c32vector_writable_elements(pmt::cdr(msg), in_len);

      // Проверка размера Packet Payload
      if ( in_len != d_pld_without_cp_len ) {
        std::cout << "in_len: " << in_len << "   payload (without CP) len: " << d_pld_without_cp_len << std::endl;
        throw std::runtime_error( "(in_len) != (payload len)" );
      }

      std::vector<gr_complex>   modulation_sym(d_pld_n_sym * d_sym_n_inf_subcarr, gr_complex(0.0f, 0.0f));
      gr_complex  s_uncnsrt_est[d_sym_sefdm_len];
      gr_complex  s_cnsrt_est[d_sym_sefdm_len];
      for (int sym_no = 0; sym_no < d_pld_n_sym; ++sym_no) { // по SEFDM-символам в Packet Payload

          // // // // // // // // // // // // // // // // // //
          // ID Algorithm:
          // // // // // // // // // // // // // // // // // //

          int  offset = sym_no * d_sym_sefdm_len;

          // Init @s_cnsrt_est for the first Algorithm Iteration
          for (int i = 0; i < d_sym_sefdm_len; ++i) {
              s_cnsrt_est[i] = in[offset + i];
          }

          float  d;
          for (int m = 1; m <= d_n_iteration; ++m) { // Algorithm Iteration

              // Get @s_uncnsrt_est
              for (int r = 0; r < d_sym_sefdm_len; ++r) { // по отсчётам

                  s_uncnsrt_est[r] = gr_complex(0.0f, 0.0f);
                  for (int i = 0; i < d_sym_sefdm_len; ++i) {
                      s_uncnsrt_est[r] += d_eye_c_matrix[r][i] * s_cnsrt_est[i];
                  }
                  s_uncnsrt_est[r] += in[offset + r];
              }

              d = 1.0f - float(m) / d_n_iteration;

              // Get new @s_cnsrt_est
              soft_mapping(s_cnsrt_est, s_uncnsrt_est, d);
          }

          // Return result с учётом выделения информационных поднесущих
          int  j = 0,
               i,
               offset2 = sym_no * d_sym_n_inf_subcarr;
          for (i = d_sym_n_left_inf_subcarr + 1;
               i < d_sym_n_left_inf_subcarr + 1 + d_sym_n_right_inf_subcarr;
               ++i, ++j) {

              modulation_sym[offset2 + j] = s_uncnsrt_est[i];
          }

          for (i = 0; i < d_sym_n_left_inf_subcarr; ++i, ++j) {
              modulation_sym[offset2 + j] = s_uncnsrt_est[i];
          }

          // // // // // // // // // // // // // // // // // //
      }


      // Добавить в @modulation_sym порядковый номер!
      // НУЖЕН ЛИ СЛОВАРЬ?
      pmt::pmt_t  p_synch_info = pmt::make_dict();
      p_synch_info = pmt::dict_add( p_synch_info,
                                    pmt::intern("packet_len"),
                                    pmt::from_long(d_pld_n_sym * d_sym_n_inf_subcarr) );
      pmt::pmt_t  p_modulation_sym =
          pmt::init_c32vector(d_pld_n_sym * d_sym_n_inf_subcarr, modulation_sym);

      pmt::pmt_t  out_msg = cons(p_synch_info, p_modulation_sym);

      message_port_pub(pmt::mp("id_detector_out"), out_msg);


    }

    inline void
    id_detector_impl::soft_mapping(gr_complex*        s_cnsrt_est,
                                   const gr_complex*  s_uncnsrt_est,
                                   float              d) const
    {
        float  re;
        for (int r = 0; r < d_sym_sefdm_len; ++r) {

            re = s_uncnsrt_est[r].real();
            if (re > d) {
                s_cnsrt_est[r] = gr_complex( 1.0f, 0.0f);
            } else if (re <= -1 * d) {
                s_cnsrt_est[r] = gr_complex(-1.0f, 0.0f);
            } else {
                s_cnsrt_est[r] = s_uncnsrt_est[r];
            }
        }
    }

  } /* namespace sefdm */
} /* namespace gr */

