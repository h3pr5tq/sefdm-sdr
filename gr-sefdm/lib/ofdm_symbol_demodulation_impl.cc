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
#include "ofdm_symbol_demodulation_impl.h"

namespace gr {
  namespace sefdm {

    ofdm_symbol_demodulation::sptr
    ofdm_symbol_demodulation::make()
    {
      return gnuradio::get_initial_sptr
        (new ofdm_symbol_demodulation_impl());
    }

    /*
     * The private constructor
     */
    ofdm_symbol_demodulation_impl::ofdm_symbol_demodulation_impl()
      : gr::block("ofdm_symbol_demodulation",
              gr::io_signature::make(0, 0, sizeof(gr_complex)),
              gr::io_signature::make(0, 0, sizeof(gr_complex)))
    {
      message_port_register_in(pmt::mp("in2"));
      message_port_register_out(pmt::mp("out2"));

      set_msg_handler( pmt::mp("in2"),
                       boost::bind(&ofdm_symbol_demodulation_impl::in2_handler_function, this, _1) );
    }

    /*
     * Our virtual destructor.
     */
    ofdm_symbol_demodulation_impl::~ofdm_symbol_demodulation_impl()
    {
    }

    void
    ofdm_symbol_demodulation_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
      for (auto& n : ninput_items_required) {
        n = noutput_items + history() - 1;
      }
    }

    int
    ofdm_symbol_demodulation_impl::general_work (int noutput_items,
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
    ofdm_symbol_demodulation_impl::in2_handler_function(pmt::pmt_t msg)
    {
      size_t             in_len;
      const gr_complex*  in = pmt::c32vector_elements(pmt::cdr(msg), in_len);

      gr::fft::fft_complex fft(64, true, 1); // fftSize, forward, numThreads

      memcpy(fft.get_inbuf(), in, 64 * sizeof(gr_complex));
      fft.execute();

      // вытаскиваем все ненулевые поднесущие (информационные и пилотные)
      gr_complex  no_null_subcarriers[52];
      for (int i = 1; i <= 26; ++i) {
        no_null_subcarriers[i - 1] = fft.get_outbuf()[i];
      }
      for (int i = 38; i <= 63; ++i) {
        no_null_subcarriers[i - 12] = fft.get_outbuf()[i];
      }

      // компенсируем влияние канала
      pmt::pmt_t  p_channel_freq_response =
          pmt::dict_ref( pmt::car(msg), // dict
                         pmt::intern("channel_est"), // key
                         pmt::from_long(0) ); // return value, if key is not found
      if ( eq(p_channel_freq_response,  pmt::from_long(0)) ) {
        throw std::runtime_error( "Not found key \"channel_est\"!" );
      }

      size_t             channel_freq_response_len; // 52
      const gr_complex*  channel_freq_response = pmt::c32vector_elements(p_channel_freq_response, channel_freq_response_len);

      for (int i = 0; i < 52; ++i) {
        no_null_subcarriers[i] /= channel_freq_response[i];
      }

      // Выделение информационных и пилотных поднесущих
      gr_complex modulation_inf_syms[48];
      for (int i = 0; i <= 5; ++i) {
        modulation_inf_syms[i] = no_null_subcarriers[i];
      }
      for (int i = 7; i <= 19; ++i) {
        modulation_inf_syms[i - 1] = no_null_subcarriers[i];
      }
      for (int i = 21; i <= 30; ++i) {
        modulation_inf_syms[i - 2] = no_null_subcarriers[i];
      }
      for (int i = 32; i <= 44; ++i) {
        modulation_inf_syms[i - 3] = no_null_subcarriers[i];
      }
      for (int i = 46; i <= 51; ++i) {
        modulation_inf_syms[i - 4] = no_null_subcarriers[i];
      }

      gr_complex modulation_pilot_syms[4];
      modulation_pilot_syms[0] = no_null_subcarriers[6];
      modulation_pilot_syms[1] = no_null_subcarriers[20];
      modulation_pilot_syms[2] = no_null_subcarriers[31];
      modulation_pilot_syms[3] = no_null_subcarriers[45];

      // оценка фазового смещения из-за остаточной частотной отстройки
      static const gr_complex  etalon_modultation_pilot_syms[4] = {
          gr_complex(1.0f, 0.0f),
          gr_complex(-1.0f, 0.0f),
          gr_complex(1.0f, 0.0f),
          gr_complex(1.0f, 0.0f)
      };
      gr_complex  crosscorr(0.0f, 0.0f);
      for (int i = 0; i < 4; ++i) {
        crosscorr += modulation_pilot_syms[i] * etalon_modultation_pilot_syms[i]; // conj
      }
      float  phase_offset_est = arg(crosscorr);

      // компенсация
      for (int i = 0; i < 48; ++i) {
        modulation_inf_syms[i] *= exp( gr_complex(0.0f, -1 * phase_offset_est) );
      }

//      // informational modulation symbols
//      gr_complex modulation_inf_syms[48];
//      for (int i = 1; i <= 6; ++i) {
//        modulation_inf_syms[i - 1] = fft.get_outbuf()[i];
//      }
//      for (int i = 8; i <= 20; ++i) {
//        modulation_inf_syms[i - 2] = fft.get_outbuf()[i];
//      }
//      for (int i = 22; i <= 26; ++i) {
//        modulation_inf_syms[i - 3] = fft.get_outbuf()[i];
//      }
//      for (int i = 38; i <= 42; ++i) {
//        modulation_inf_syms[i - 14] = fft.get_outbuf()[i];
//      }
//      for (int i = 44; i <= 56; ++i) {
//        modulation_inf_syms[i - 15] = fft.get_outbuf()[i];
//      }
//      for (int i = 58; i <= 63; ++i) {
//        modulation_inf_syms[i - 16] = fft.get_outbuf()[i];
//      }
//
//      // pilots modulation symbols
//      gr_complex modulation_pilot_syms[4];
//      modulation_pilot_syms[0] = fft.get_outbuf()[7];
//      modulation_pilot_syms[1] = fft.get_outbuf()[21];
//      modulation_pilot_syms[2] = fft.get_outbuf()[43];
//      modulation_pilot_syms[3] = fft.get_outbuf()[57];

      pmt::pmt_t  p_modulation_inf_syms =
           pmt::init_c32vector(48, modulation_inf_syms);

      set_cdr(msg, p_modulation_inf_syms);
      message_port_pub(pmt::mp("out2"), msg);
    }

  } /* namespace sefdm */
} /* namespace gr */

