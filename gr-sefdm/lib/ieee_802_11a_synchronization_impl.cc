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

//#include <cmath>

#include <gnuradio/io_signature.h>
#include <gnuradio/fft/fft.h>
#include "ieee_802_11a_synchronization_impl.h"

namespace gr {
  namespace sefdm {

    // One Long Training Symbol (64 complex samples)
    static const gr_complex  one_lts_in_time_domain[64] = {
        gr_complex(0.15625f, 0.0f),
        gr_complex(-0.0051213f, -0.12033f),
        gr_complex(0.03975f, -0.11116f),
        gr_complex(0.096832f, 0.082798f),
        gr_complex(0.021112f, 0.027886f),
        gr_complex(0.059824f, -0.087707f),
        gr_complex(-0.11513f, -0.05518f),
        gr_complex(-0.038316f, -0.10617f),
        gr_complex(0.097541f, -0.025888f),
        gr_complex(0.053338f, 0.0040763f),
        gr_complex(0.00098898f, -0.115f),
        gr_complex(-0.1368f, -0.04738f),
        gr_complex(0.024476f, -0.058532f),
        gr_complex(0.058669f, -0.014939f),
        gr_complex(-0.022483f, 0.16066f),
        gr_complex(0.11924f, -0.0040956f),
        gr_complex(0.0625f, -0.0625f),
        gr_complex(0.036918f, 0.098344f),
        gr_complex(-0.057206f, 0.039299f),
        gr_complex(-0.13126f, 0.065227f),
        gr_complex(0.082218f, 0.092357f),
        gr_complex(0.069557f, 0.014122f),
        gr_complex(-0.06031f, 0.081286f),
        gr_complex(-0.056455f, -0.021804f),
        gr_complex(-0.035041f, -0.15089f),
        gr_complex(-0.12189f, -0.016566f),
        gr_complex(-0.12732f, -0.020501f),
        gr_complex(0.075074f, -0.07404f),
        gr_complex(-0.0028059f, 0.053774f),
        gr_complex(-0.091888f, 0.11513f),
        gr_complex(0.091717f, 0.10587f),
        gr_complex(0.012285f, 0.0976f),
        gr_complex(-0.15625f, 0.0f),
        gr_complex(0.012285f, -0.0976f),
        gr_complex(0.091717f, -0.10587f),
        gr_complex(-0.091888f, -0.11513f),
        gr_complex(-0.0028059f, -0.053774f),
        gr_complex(0.075074f, 0.07404f),
        gr_complex(-0.12732f, 0.020501f),
        gr_complex(-0.12189f, 0.016566f),
        gr_complex(-0.035041f, 0.15089f),
        gr_complex(-0.056455f, 0.021804f),
        gr_complex(-0.06031f, -0.081286f),
        gr_complex(0.069557f, -0.014122f),
        gr_complex(0.082218f, -0.092357f),
        gr_complex(-0.13126f, -0.065227f),
        gr_complex(-0.057206f, -0.039299f),
        gr_complex(0.036918f, -0.098344f),
        gr_complex(0.0625f, 0.0625f),
        gr_complex(0.11924f, 0.0040956f),
        gr_complex(-0.022483f, -0.16066f),
        gr_complex(0.058669f, 0.014939f),
        gr_complex(0.024476f, 0.058532f),
        gr_complex(-0.1368f, 0.04738f),
        gr_complex(0.00098898f, 0.115f),
        gr_complex(0.053338f, -0.0040763f),
        gr_complex(0.097541f, 0.025888f),
        gr_complex(-0.038316f, 0.10617f),
        gr_complex(-0.11513f, 0.05518f),
        gr_complex(0.059824f, 0.087707f),
        gr_complex(0.021112f, -0.027886f),
        gr_complex(0.096832f, -0.082798f),
        gr_complex(0.03975f, 0.11116f),
        gr_complex(-0.0051213f, 0.12033f)
    };

    ieee_802_11a_synchronization::sptr
    ieee_802_11a_synchronization::make(int cts_segment_len,
                                       bool ffs_is_make, int ffs_offset_from_cts,
                                       int fts_offset_from_cts, int fts_segment_len, int fts_etalon_seq_len,
                                       bool channel_est_is_make,
                                       int packet_len
//                                       int payload_ofdm_sym_num, int payload_subcarriers_num, int payload_gi_len
                                       )
    {
      return gnuradio::get_initial_sptr
        ( new ieee_802_11a_synchronization_impl(cts_segment_len,
                                                ffs_is_make, ffs_offset_from_cts,
                                                fts_offset_from_cts, fts_segment_len, fts_etalon_seq_len,
                                                channel_est_is_make,
                                                packet_len
//                                                payload_ofdm_sym_num, payload_subcarriers_num, payload_gi_len
                                                ) );
    }

    /*
     * The private constructor
     */
    ieee_802_11a_synchronization_impl::ieee_802_11a_synchronization_impl(int cts_segment_len,
                                                                         bool ffs_is_make, int ffs_offset_from_cts,
                                                                         int fts_offset_from_cts, int fts_segment_len, int fts_etalon_seq_len,
                                                                         bool channel_est_is_make,
                                                                         int packet_len
//                                                                         int payload_ofdm_sym_num, int payload_subcarriers_num, int payload_gi_len
                                                                         )
      : gr::block("ieee_802_11a_synchronization",
              gr::io_signature::make(0, 0, sizeof(gr_complex)),
              gr::io_signature::make(0, 0, sizeof(gr_complex))),

        // Coarse Time Synch Algorithm
        d_cts_segment_len(cts_segment_len),
        d_cts_summation_window(144),
        d_cts_signal_offset(16),

        // Fine Freq Synch Algorithm
        d_ffs_is_make(ffs_is_make), // делать или нет FFS
        d_ffs_offset_from_cts(ffs_offset_from_cts), // смещение от cts_est, чтобы затронуть только STS
        d_ffs_summation_window(64), // L
        d_ffs_signal_offset(64), // D

        // Fine Time Synch Algorithm
        d_fts_offset_from_cts(fts_offset_from_cts), // [(10STS + LGI) - x], где x  оцениваем по моделированию CTS // Должен 100% попасть первый отсчёт первого LTS
        d_fts_segment_len(fts_segment_len), // Оцениваем по моделированию CTS; данный параметр связан с x // Если брать слишком большой, можем затронуть второй LTS --> получим второй пик, который не нужен
        d_fts_etalon_seq_len(fts_etalon_seq_len), // Коррелируем с первыми 32 отсчётами LTS

        // Channel Estimaton
        d_channel_est_is_make(channel_est_is_make),

        // Packet Parameters
        d_packet_len(packet_len),

        // Packet Preamble Parameters
        d_prmbl_subcarriers_num(64)

//        // Packet Payload Parameters
//        d_payload_ofdm_sym_num(payload_ofdm_sym_num),
//        d_payload_subcarriers_num(payload_subcarriers_num),
//        d_payload_gi_len(payload_gi_len)
    {

      //d_prmbl_payload_len = 320 + d_payload_ofdm_sym_num * (d_payload_subcarriers_num + d_payload_gi_len);

      // Check input arguments
      if ( d_cts_segment_len < 1 ||
           d_cts_segment_len > d_packet_len - d_cts_summation_window - d_cts_signal_offset + 2  ) {
        throw std::out_of_range( "Bad @d_cts_segment_len" );
      }

      if ( d_ffs_offset_from_cts < 0 ||
           d_ffs_offset_from_cts > 150  ) {
        throw std::out_of_range( "Bad @d_ffs_offset_from_cts" );
      }

      if ( d_fts_offset_from_cts < 160 + 32 - 50 ||
           d_fts_offset_from_cts > 160 + 32 + 50  ) {
        throw std::out_of_range( "Bad @d_fts_offset_from_cts" );
      }

      if ( d_fts_segment_len < 1 ||
           d_fts_segment_len > 100  ) {
        throw std::out_of_range( "Bad @d_fts_segment_len" );
      }

      if ( d_fts_etalon_seq_len < 1 ||
           d_fts_etalon_seq_len > 64  ) {
        throw std::out_of_range( "Bad @d_fts_etalon_seq_len" );
      }

//      if ( d_payload_ofdm_sym_num < 1 ) {
//        throw std::out_of_range( "Bad @d_payload_ofdm_sym_num" );
//      }
//
//      if ( d_payload_subcarriers_num < 1 ) {
//        throw std::out_of_range( "Bad @d_payload_subcarriers_num" );
//      }
//
//      if ( d_payload_gi_len < 1 || d_payload_gi_len > d_payload_subcarriers_num ) {
//        throw std::out_of_range( "Bad @d_payload_gi_len" );
//      }

      message_port_register_in(pmt::mp("in"));
      message_port_register_out(pmt::mp("out"));

      set_msg_handler( pmt::mp("in"),
                       boost::bind(&ieee_802_11a_synchronization_impl::in_handler_function, this, _1) );

    }

    /*
     * Our virtual destructor.
     */
    ieee_802_11a_synchronization_impl::~ieee_802_11a_synchronization_impl()
    {
    }

    void
    ieee_802_11a_synchronization_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
      for (auto& n : ninput_items_required) {
        n = noutput_items + history() - 1;
      }
    }

    int
    ieee_802_11a_synchronization_impl::general_work (int noutput_items,
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
    ieee_802_11a_synchronization_impl::in_handler_function(pmt::pmt_t msg)
    {
        size_t       in_len;
        gr_complex*  in = pmt::c32vector_writable_elements(pmt::cdr(msg), in_len);

        // Проверка размера пакета
        if ( in_len < d_packet_len ) {
          std::cout << "in_len: " << in_len << "   prmbl + rest of packet len: " << d_packet_len << std::endl;
          throw std::runtime_error( "in_len too small --> will be array array overflow" );
        }

        // Coarse Time Synch
        int  cts_est = estimate_coarse_time_offset(in);

        // Fine Freq Synch
        float  ffs_est = 0.0f;
        if (d_ffs_is_make) {
        	ffs_est = estimate_fine_freq_offset(in, cts_est);
        	compensate_fine_freq_offset(in, in_len, cts_est, ffs_est);
        }

        // Fine Time Synch
        int  fts_est = estimate_fine_time_offset(in, cts_est);
        // Проверка на выход за пределны пакета, если сильно ошиблись с оценкой FTS
        // Данная проверка гарантирует, что в @in с учётом fts_est поместится полностью payload
        if ( in_len - fts_est - 64 - 64 < d_packet_len - 320 ) {

          std::cout << "we get payload len: " << in_len - (fts_est + 64 + 64) <<
              "  etalon payload len " << d_packet_len - 320 << std::endl;
          throw std::runtime_error( "fts_est is very bad --> will be array array overflow" );

          // СДЕЛАТЬ ОТКИДЫВАНИЕ ПАКЕТА, А НЕ ЗАВЕРШЕНИЕ РАБОТЫ БЛОКА
        }

        // Channel Freq Response Estimation
        std::vector<gr_complex> channel_est(52, gr_complex(0.0f, 0.0f));
        if (d_channel_est_is_make) {
            channel_est = estimate_channel(in, fts_est);
        }

        // ЭТИМ СЛОМАЛИ ofdm_symbol_demodulation_block!!!!

//        // Получение массива с полезной нагрузкой (без GI и без Preamble)
//        gr_complex  payload_without_gi[d_payload_ofdm_sym_num * d_payload_subcarriers_num];
//        int  offset          = fts_est + 64 + 64 + d_payload_gi_len;
//        int  sym_with_gi_len = d_payload_subcarriers_num + d_payload_gi_len;
//
//        for (int i = 0; i < d_payload_ofdm_sym_num; ++i) {
//
//          for (int k = 0; k < d_payload_subcarriers_num; ++k) {
//
//            payload_without_gi[i * d_payload_subcarriers_num + k] =
//                in[offset + k + i * sym_with_gi_len];
//          }
//        }

        // Откидываем преамбулу от пакета
        gr_complex  packet_without_prmbl[d_packet_len - 320];
        int offset = fts_est + 64 + 64;

        for (int i = 0; i < d_packet_len - 320; ++i) {
          packet_without_prmbl[i] = in[offset + i];
        }

        // Формирование сообщения следующему блоку
        pmt::pmt_t  p_synch_info = pmt::make_dict();
//        p_synch_info = pmt::dict_add(p_synch_info, pmt::intern("cts_est"),     pmt::from_long(cts_est));
//        p_synch_info = pmt::dict_add(p_synch_info, pmt::intern("fts_est"),     pmt::from_long(fts_est));
//        p_synch_info = pmt::dict_add(p_synch_info, pmt::intern("ffs_est"),     pmt::from_float(ffs_est));

        if (d_channel_est_is_make) {
            p_synch_info = pmt::dict_add(p_synch_info, pmt::intern("channel_est"), pmt::init_c32vector(52, channel_est));
        }

        pmt::pmt_t  p_packet_without_prmbl =
            pmt::init_c32vector(d_packet_len - 320, packet_without_prmbl);

        pmt::pmt_t  out_msg = cons(p_synch_info, p_packet_without_prmbl);

        message_port_pub(pmt::mp("out"), out_msg);

    }


    inline int
    ieee_802_11a_synchronization_impl::estimate_coarse_time_offset(const gr_complex* in) const
    {
       // i = 0
       gr_complex  autocorr(0.0f, 0.0f);
       for (int k = 0; k < d_cts_summation_window; ++k) {
         autocorr += in[k] * conj(in[k + d_cts_signal_offset]);
       }
       float  max_abs_autocorr = abs(autocorr);
       int    cts_est = 0;

       // i = 1 ...
       float  abs_autocorr;
       for (int i = 1; i < d_cts_segment_len; ++i) {

           autocorr = autocorr -

               in[i - 1] *
               conj( in[i - 1 + d_cts_signal_offset] ) +

               in[i - 1 + d_cts_summation_window] *
               conj( in[i - 1 + d_cts_summation_window + d_cts_signal_offset] );

           abs_autocorr = abs(autocorr);
           if ( abs_autocorr > max_abs_autocorr ) {
             max_abs_autocorr = abs_autocorr;
             cts_est = i;
           }
       }

       return cts_est;
    }


    inline float
    ieee_802_11a_synchronization_impl::estimate_fine_freq_offset(const gr_complex* in, int cts_est) const
    {
      in = in + cts_est + d_ffs_offset_from_cts;

      gr_complex  autocorr(0.0f, 0.0f);
      for ( int i = 0; i < d_ffs_summation_window; ++i ) {
        autocorr += in[i] * conj(in[i + d_ffs_signal_offset]);
      }

      return d_prmbl_subcarriers_num / (2 * float(M_PI) * d_ffs_signal_offset) * arg(autocorr);
    }


    inline void
		ieee_802_11a_synchronization_impl::compensate_fine_freq_offset(gr_complex* in, size_t in_len, int cts_est, float ffs_est) const
    {
      gr_complex*  new_in     = in + cts_est + d_fts_offset_from_cts;
    	size_t       new_in_len = in_len - cts_est - d_fts_offset_from_cts;

    	float  val = 2 * float(M_PI) * ffs_est / d_prmbl_subcarriers_num;
    	for (int i = 0; i < new_in_len; ++i) {
    	  new_in[i] *= exp( gr_complex(0.0f, val * (i + 1)) );
			}
    }


    inline int
    ieee_802_11a_synchronization_impl::estimate_fine_time_offset(const gr_complex* in, int cts_est) const
    {
      const gr_complex*  new_in = in + cts_est + d_fts_offset_from_cts;

      float  max_abs_crosscorr = 0.0f;
      int    fts_est = 0;
      for (int i = 0; i < d_fts_segment_len; ++i) {

          gr_complex crosscorr(0.0f, 0.0f);
          for (int k = 0; k < d_fts_etalon_seq_len; ++k) {

            crosscorr += new_in[i + k] * conj( one_lts_in_time_domain[k] );
          }

          float abs_crosscorr = abs(crosscorr);
          if (abs_crosscorr > max_abs_crosscorr) {
            max_abs_crosscorr = abs_crosscorr;
            fts_est = i;
          }
      }

      return fts_est + cts_est + d_fts_offset_from_cts;
    }


    inline std::vector<gr_complex>
    ieee_802_11a_synchronization_impl::estimate_channel(const gr_complex* in, int fts_est) const
    {
      const gr_complex*  new_in = in + fts_est;

      static const signed char  etalon_one_lts[52] = {
           1,    -1,    -1,     1,     1,    -1,     1,    -1,     1,    -1,    -1,
          -1,    -1,    -1,     1,     1,    -1,    -1,     1,    -1,     1,    -1,
           1,     1,     1,     1,     1,     1,    -1,    -1,     1,     1,    -1,
           1,    -1,     1,     1,     1,     1,     1,     1,    -1,    -1,     1,
           1,    -1,     1,    -1,     1,     1,     1,     1
      };

      const int  fft_size = 64;

      gr::fft::fft_complex fft(fft_size, true, 1); // fftSize, forward, numThreads

      // get first rx lts in freq domain
      gr_complex rx_first_lts[52];
      memcpy(fft.get_inbuf(), new_in, fft_size * sizeof(gr_complex));
      fft.execute();
      for (int i = 1; i <= 26; ++i) {

        rx_first_lts[i - 1] = fft.get_outbuf()[i];
      }
      for (int i = 38; i <= 63; ++i) {
        rx_first_lts[i - 12] = fft.get_outbuf()[i];
      }

      // get second rx lts in freq domain
      gr_complex  rx_second_lts[52];
      memcpy(fft.get_inbuf(), new_in + 64, fft_size * sizeof(gr_complex));
      fft.execute();
      for (int i = 1; i <= 26; ++i) {
        rx_second_lts[i - 1] = fft.get_outbuf()[i];
      }
      for (int i = 38; i <= 63; ++i) {
        rx_second_lts[i - 12] = fft.get_outbuf()[i];
      }

      // get channel freq response
      std::vector<gr_complex>  channel_est(52, gr_complex(0.0f, 0.0f));
      for (int i = 0; i < 52; ++i) {
        channel_est[i] =
            gr_complex(0.5f, 0.0f) * (rx_first_lts[i] + rx_second_lts[i]) * gr_complex(etalon_one_lts[i], 0.0f);
      }

      return channel_est;
    }

  } /* namespace sefdm */
} /* namespace gr */

