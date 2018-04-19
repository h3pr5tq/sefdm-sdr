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
#include "ieee_802_11a_ofdm_symbol_demodulation_impl.h"

namespace gr {
  namespace sefdm {

    ieee_802_11a_ofdm_symbol_demodulation::sptr
    ieee_802_11a_ofdm_symbol_demodulation::make(int ofdm_sym_num, int subcarriers_num)
    {
      return gnuradio::get_initial_sptr
        (new ieee_802_11a_ofdm_symbol_demodulation_impl(ofdm_sym_num, subcarriers_num));
    }

    /*
     * The private constructor
     */
    ieee_802_11a_ofdm_symbol_demodulation_impl::ieee_802_11a_ofdm_symbol_demodulation_impl(int ofdm_sym_num, int subcarriers_num)
      : gr::block("ofdm_symbol_demodulation",
              gr::io_signature::make(0, 0, sizeof(gr_complex)),
              gr::io_signature::make(0, 0, sizeof(gr_complex))),
      d_ofdm_sym_num(ofdm_sym_num),
      d_subcarriers_num(subcarriers_num),
      d_channel_freq_response_len(52)
    {
      message_port_register_in(pmt::mp("in2"));
      message_port_register_out(pmt::mp("out2"));

      set_msg_handler( pmt::mp("in2"),
                       boost::bind(&ieee_802_11a_ofdm_symbol_demodulation_impl::in2_handler_function, this, _1) );
    }

    /*
     * Our virtual destructor.
     */
    ieee_802_11a_ofdm_symbol_demodulation_impl::~ieee_802_11a_ofdm_symbol_demodulation_impl()
    {
    }

    void
    ieee_802_11a_ofdm_symbol_demodulation_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
      for (auto& n : ninput_items_required) {
        n = noutput_items + history() - 1;
      }
    }

    int
    ieee_802_11a_ofdm_symbol_demodulation_impl::general_work (int noutput_items,
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
    ieee_802_11a_ofdm_symbol_demodulation_impl::in2_handler_function(pmt::pmt_t msg)
    {
      static const gr_complex  etalon_modultation_pilot_syms[4] = {
          gr_complex(1.0f, 0.0f),
          gr_complex(-1.0f, 0.0f),
          gr_complex(1.0f, 0.0f),
          gr_complex(1.0f, 0.0f)
      };

      size_t       in_len;
      gr_complex*  in = pmt::c32vector_writable_elements(pmt::cdr(msg), in_len);

      // Проверка размера пакета
      if ( in_len < d_ofdm_sym_num * d_subcarriers_num ) {
        std::cout << "in_len: " << in_len << "   packet_len: " << d_ofdm_sym_num * d_subcarriers_num << std::endl;
        throw std::runtime_error( "in_len too small --> will be array array overflow" );
      }

      // Вытаскиваем частотную характеристику канала из сообщения
      const gr_complex*  channel_freq_response = get_channel_freq_response_from_msg(msg);

      gr::fft::fft_complex  fft(d_subcarriers_num, true, 1); // fftSize, forward, numThreads

      gr_complex  no_null_subcarriers[52];
      gr_complex  modulation_pilot_syms[4];
      gr_complex  modulation_inf_syms[48 * d_ofdm_sym_num];
      for (int i = 0; i < d_ofdm_sym_num; ++i) {

          memcpy(fft.get_inbuf(), in + i * d_subcarriers_num, d_subcarriers_num * sizeof(gr_complex));
          fft.execute();

          // Вытаскиваем все ненулевые поднесущие (информационные и пилотные)
          // и сразу же компенсируем влияние канала
          for (int i = 1; i <= 26; ++i) {
            no_null_subcarriers[i - 1] = fft.get_outbuf()[i] / channel_freq_response[i - 1];
          }
          for (int i = 38; i <= 63; ++i) {
            no_null_subcarriers[i - 12] = fft.get_outbuf()[i] / channel_freq_response[i - 12];
          }

          // Выделение пилотных поднесущих
          modulation_pilot_syms[0] = no_null_subcarriers[6];
          modulation_pilot_syms[1] = no_null_subcarriers[20];
          modulation_pilot_syms[2] = no_null_subcarriers[31];
          modulation_pilot_syms[3] = no_null_subcarriers[45];

          // Оценка фазового смещения
          gr_complex  crosscorr(0.0f, 0.0f);
          for (int i = 0; i < 4; ++i) {
            crosscorr += modulation_pilot_syms[i] * etalon_modultation_pilot_syms[i]; // conj
          }
          float  phase_offset_est = arg(crosscorr);

          // Выделение информационных поднесущих
          // и сразу же компенсация фазового сдвига
          gr_complex  val = exp( gr_complex(0.0f, -1 * phase_offset_est) );
          for (int k = 0; k <= 5; ++k) {
            modulation_inf_syms[k + i * 48] = no_null_subcarriers[k] * val;
          }
          for (int k = 7; k <= 19; ++k) {
            modulation_inf_syms[k - 1 + i * 48] = no_null_subcarriers[k] * val;
          }
          for (int k = 21; k <= 30; ++k) {
            modulation_inf_syms[k - 2 + i * 48] = no_null_subcarriers[k] * val;
          }
          for (int k = 32; k <= 44; ++k) {
            modulation_inf_syms[k - 3 + i * 48] = no_null_subcarriers[k] * val;
          }
          for (int k = 46; k <= 51; ++k) {
            modulation_inf_syms[k - 4 + i * 48] = no_null_subcarriers[k] * val;
          }
      }

      pmt::pmt_t  out_msg = cons( pmt::make_dict(),
                                  pmt::init_c32vector(48 * d_ofdm_sym_num, modulation_inf_syms) );
      message_port_pub(pmt::mp("out2"), out_msg);
    }


    inline const gr_complex*
    ieee_802_11a_ofdm_symbol_demodulation_impl::get_channel_freq_response_from_msg(pmt::pmt_t&  msg) const
    {
      pmt::pmt_t  p_channel_freq_response = pmt::dict_ref( pmt::car(msg), // dict
                                                           pmt::intern("channel_est"), // key
                                                           pmt::from_long(0) ); // return value, if key is not found
      if ( eq(p_channel_freq_response,  pmt::from_long(0)) ) {
        throw std::runtime_error( "Not found key \"channel_est\"!" );
      }

      size_t             channel_freq_response_len;
      const gr_complex*  channel_freq_response = pmt::c32vector_elements(p_channel_freq_response, channel_freq_response_len);
      if (channel_freq_response_len != d_channel_freq_response_len) {
        throw std::runtime_error( "Bad length of channel freq response" );
      }

      return channel_freq_response;

    }


  } /* namespace sefdm */
} /* namespace gr */

