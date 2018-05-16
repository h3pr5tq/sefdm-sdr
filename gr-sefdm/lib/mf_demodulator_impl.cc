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
#include <gnuradio/fft/fft.h>
#include <sefdm/common.h>
#include "mf_demodulator_impl.h"

namespace gr {
  namespace sefdm {

    mf_demodulator::sptr
    mf_demodulator::make(int pld_n_sym,
                         int sym_fft_size, int sym_sefdm_len, int sym_right_gi_len, int sym_left_gi_len,
                         bool channel_compensation__is_make, bool phase_offset_compensation__is_make)
    {
      return gnuradio::get_initial_sptr
        ( new mf_demodulator_impl(pld_n_sym,
                                  sym_fft_size, sym_sefdm_len, sym_right_gi_len, sym_left_gi_len,
                                  channel_compensation__is_make, phase_offset_compensation__is_make) );
    }

    /*
     * The private constructor
     */
    mf_demodulator_impl::mf_demodulator_impl(int pld_n_sym,
                                             int sym_fft_size, int sym_sefdm_len, int sym_right_gi_len, int sym_left_gi_len,
                                             bool channel_compensation__is_make, bool phase_offset_compensation__is_make)
      : gr::block("mf_demodulator",
              gr::io_signature::make(0, 0, sizeof(gr_complex)),
              gr::io_signature::make(0, 0, sizeof(gr_complex))),
      d_pld_n_sym(pld_n_sym),
      d_sym_fft_size(sym_fft_size),
      d_sym_sefdm_len(sym_sefdm_len),
      d_sym_right_gi_len(sym_right_gi_len),
      d_sym_left_gi_len(sym_left_gi_len),
      d_channel_compensation__is_make(channel_compensation__is_make),
      d_phase_offset_compensation__is_make(phase_offset_compensation__is_make),

      d_pld_without_cp_len(pld_n_sym * sym_sefdm_len)
    {
        get_inf_subcarrier_number(sym_sefdm_len, sym_right_gi_len, sym_left_gi_len,
                                  d_sym_n_inf_subcarr, d_sym_n_right_inf_subcarr, d_sym_n_left_inf_subcarr);

        d_add_zero_subcarr = get_add_zero_subcarrier_number(sym_fft_size, sym_sefdm_len);

        message_port_register_in(pmt::mp("mf_demodulator_in"));
        message_port_register_out(pmt::mp("mf_demodulator_out"));

        set_msg_handler( pmt::mp("mf_demodulator_in"),
                         boost::bind(&mf_demodulator_impl::mf_demodulator_in_handler, this, _1) );
    }

    /*
     * Our virtual destructor.
     */
    mf_demodulator_impl::~mf_demodulator_impl()
    {
    }

    void
    mf_demodulator_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
      for (auto& n : ninput_items_required) {
        n = noutput_items + history() - 1;
      }
    }

    int
    mf_demodulator_impl::general_work (int noutput_items,
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
    mf_demodulator_impl::mf_demodulator_in_handler(pmt::pmt_t msg)
    {
        size_t       in_len;
        gr_complex*  in = pmt::c32vector_writable_elements(pmt::cdr(msg), in_len);

        // Проверка размера Packet Payload
        if ( in_len != d_pld_without_cp_len ) {
          std::cout << "in_len: " << in_len << "   payload (without CP) len: " << d_pld_without_cp_len << std::endl;
          throw std::runtime_error( "(in_len) != (payload len)" );
        }

        // Сдвигаем спектр
//        gr_complex  hdr[d_hdr_n_sym][d_sym_fft_size];
        static gr_complex  exp_val = gr_complex( 0.0f, 2 * M_PI * d_sym_n_left_inf_subcarr / d_sym_fft_size );
        for (int i = 0; i < d_pld_n_sym; ++i) { // По SEFDM-символам в Packet Payload

            for (int j = 0; j < d_sym_sefdm_len; ++j) { // По отсчётам в SEFDM-символе

                in[ i * d_sym_sefdm_len + j ] *=
                    exp( exp_val * gr_complex(j + 1, 0.0f) );
            }
        }

        // Plus "Add zeros" -> FFT for Packet Payload -> Minus "Add zeros"
        std::vector<std::vector<gr_complex>>  pld_R( d_pld_n_sym,
                                                     std::vector<gr_complex>(d_sym_sefdm_len, gr_complex(0.0f, 0.0f)) );
//        std::vector<gr_complex>  zeros(d_add_zero_subcarr, gr_complex(0.0f, 0.0f));
        gr::fft::fft_complex  fft(d_sym_fft_size, true, 1); // fftSize, forward, numThreads
//        static int  first_for_end = d_n_left_inf_subcarr + 1 + d_n_left_inf_subcarr + d_sym_len_right_gi;
        for (int i = 0; i < d_pld_n_sym; ++i) {

            memcpy( fft.get_inbuf(),
                    in + i * d_sym_sefdm_len,
                    d_sym_sefdm_len * sizeof(gr_complex));

            // Add zeros
            for (int k = 0; k < d_add_zero_subcarr; ++k) {
              fft.get_inbuf()[d_sym_sefdm_len + k] = gr_complex(0.0f, 0.0f);
            }

            fft.execute();

            // Get result of FFT and Minus Zeros
            for (int j = 0; j < d_sym_sefdm_len; ++j) {
                pld_R[i][j] = fft.get_outbuf()[j];
            }
        }

        if (d_channel_compensation__is_make) {

            // Get @channel_freq_response from message
            pmt::pmt_t  p_channel_freq_response =
                pmt::dict_ref( pmt::car(msg), // dict
                               pmt::intern("channel_est"), // key
                               pmt::from_long(0) ); // return value, if key is not found
            if ( eq(p_channel_freq_response,  pmt::from_long(0)) ) {
                throw std::runtime_error( "Not found key \"channel_est\"!" );
            }

            const std::vector<gr_complex>  channel_freq_response =
                pmt::c32vector_elements(p_channel_freq_response);
            if ( channel_freq_response.size() != d_sym_sefdm_len ) {
                std::cout << "channel_freq_response.size(): " << channel_freq_response.size() <<
                    "   d_sym_sefdm_len: " << d_sym_sefdm_len << std::endl;
                throw std::runtime_error( "channel_freq_response.size() != d_sym_sefdm_len" );
            }

            for (int i = 0; i < d_pld_n_sym; ++i) {
                equalizer(pld_R[i], channel_freq_response);
            }
        }

        if (d_phase_offset_compensation__is_make) {

            // Get @const_fi, @dfi and @sym_no from message
            pmt::pmt_t  p_const_fi =
                pmt::dict_ref( pmt::car(msg), // dict
                               pmt::intern("const_phase_offset"), // key
                               pmt::from_long(0) ); // return value, if key is not found

            pmt::pmt_t  p_diff_fi =
                pmt::dict_ref( pmt::car(msg), // dict
                               pmt::intern("diff_phase_offset"), // key
                               pmt::from_long(0) ); // return value, if key is not found

            pmt::pmt_t  p_sym_no =
                pmt::dict_ref( pmt::car(msg), // dict
                               pmt::intern("sym_No"), // key
                               pmt::from_long(0) ); // return value, if key is not found

            if ( eq(p_const_fi,  pmt::from_long(0)) ||
                 eq(p_diff_fi,   pmt::from_long(0)) ||
                 eq(p_sym_no,    pmt::from_long(0)) ) {
                throw std::runtime_error( "Not found key!" );
            }

            const float  const_fi = to_float(p_const_fi);
            const float  diff_fi  = to_float(p_diff_fi);
            int    sym_no   = to_long(p_sym_no);

            for (int i = 0; i < d_pld_n_sym; ++i) {
                compensate_residual_freq_offset(pld_R[i], const_fi, diff_fi, sym_no);
            }
        }

        // Формирование сообщения следующему блоку
        pmt::pmt_t  p_synch_info = pmt::make_dict();
        p_synch_info = pmt::dict_add( p_synch_info,
                                      pmt::intern("packet_No"),
                                      pmt::dict_ref( pmt::car(msg), // dict
                                                     pmt::intern("packet_No"), // key
                                                     pmt::from_long(0) ) );

        // from 2d vector to 1d vector
        gr_complex pld_R_1d[d_pld_without_cp_len];
        for (int i = 0; i < d_pld_n_sym; ++i) {
            for (int j = 0; j < d_sym_sefdm_len; ++j) {
                pld_R_1d[i * d_sym_sefdm_len + j] = pld_R[i][j];
            }
        }

        pmt::pmt_t  p_pld_R =
            pmt::init_c32vector(d_pld_without_cp_len, pld_R_1d);

        pmt::pmt_t  out_msg = cons(p_synch_info, p_pld_R);

        message_port_pub(pmt::mp("mf_demodulator_out"), out_msg);

    }

    inline void
    mf_demodulator_impl::equalizer(std::vector<gr_complex>&        R,
                                   const std::vector<gr_complex>&  channel_freq_response) const
    {
        // Поднесущие слева от нулевой частоты
        for (int  i = 0; i < d_sym_n_left_inf_subcarr; ++i) {
            R[i] /= channel_freq_response[i];
        }

        // DC null subcarrier
        R[d_sym_n_left_inf_subcarr] = gr_complex(0.0f, 0.0f);

        // Поднесущие справа от нулевой частоты
        for (int  i = d_sym_n_left_inf_subcarr + 1;
             i < d_sym_n_left_inf_subcarr + d_sym_n_right_inf_subcarr + 1;
             ++i) {

            R[i] /= channel_freq_response[i];
        }

        // Нулевые GI по частоте
        for (int  i = d_sym_n_left_inf_subcarr + d_sym_n_right_inf_subcarr + 1;
             i < d_sym_sefdm_len;
             ++i) {

            R[i] = gr_complex(0.0f, 0.0f);
        }
    }

    inline void
    mf_demodulator_impl::compensate_residual_freq_offset(std::vector<gr_complex>&  R,
                                                         const float&  const_fi,
                                                         const float&  dfi,
                                                         int&    symNo) const
    {
        gr_complex  exp_val = exp( gr_complex(0.0f, -1 * const_fi + dfi * (symNo - 1)) );

        // Поднесущие слева от нулевой частоты
        for (int  i = 0; i < d_sym_n_left_inf_subcarr; ++i) {
            R[i] *= exp_val;
        }

        // Поднесущие справа от нулевой частоты
        for (int  i = d_sym_n_left_inf_subcarr + 1;
             i < d_sym_n_left_inf_subcarr + d_sym_n_right_inf_subcarr + 1;
             ++i) {

            R[i] *= exp_val;
        }

        symNo = symNo + 1;
    }

  } /* namespace sefdm */
} /* namespace gr */

