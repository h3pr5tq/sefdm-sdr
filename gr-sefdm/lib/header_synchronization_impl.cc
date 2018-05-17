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
#include "header_synchronization_impl.h"

namespace gr {
  namespace sefdm {

    static const gr_complex  header_pilot_modulation_sym[260] = {
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex(-1.0f, 0.0f),
        gr_complex( 1.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f),
        gr_complex( 0.0f, 0.0f)
    };

    header_synchronization::sptr
    header_synchronization::make(int hdr_pld_len,
                                 int hdr_n_sym, int hdr_len_cp,
                                 int pld_n_sym, int pld_len_cp,
                                 int sym_fft_size, int sefdm_sym_len, int sym_len_right_gi, int sym_len_left_gi)
    {
      return gnuradio::get_initial_sptr
        ( new header_synchronization_impl(hdr_pld_len,
                                          hdr_n_sym, hdr_len_cp,
                                          pld_n_sym, pld_len_cp,
                                          sym_fft_size, sefdm_sym_len, sym_len_right_gi, sym_len_left_gi) );
    }

    /*
     * The private constructor
     */
    header_synchronization_impl::header_synchronization_impl(int hdr_pld_len,
                                                             int hdr_n_sym, int hdr_len_cp,
                                                             int pld_n_sym, int pld_len_cp,
                                                             int sym_fft_size, int sefdm_sym_len, int sym_len_right_gi, int sym_len_left_gi)
      : gr::block("header_synchronization",
              gr::io_signature::make(0, 0, sizeof(gr_complex)),
              gr::io_signature::make(0, 0, sizeof(gr_complex))),
      d_hdr_no_pld_len(hdr_pld_len),
      d_hdr_n_sym(hdr_n_sym),
      d_hdr_len_cp(hdr_len_cp),

      d_pld_n_sym(pld_n_sym),
      d_pld_len_cp(pld_len_cp),

      d_sym_fft_size(sym_fft_size),
      d_sym_sefdm_len(sefdm_sym_len),
      d_sym_len_right_gi(sym_len_right_gi),
      d_sym_len_left_gi(sym_len_left_gi)
    {
        // Сделать ограничение-проверки заголовка небольше 10 символов! + ограничеия на fft и т.п. !!!!!!!!!!

        // Получение @d_n_left_inf_subcarr и @d_sym_n_inf_subcarr
        d_sym_n_inf_subcarr = d_sym_sefdm_len - d_sym_len_right_gi - d_sym_len_left_gi - 1;
        if (d_sym_n_inf_subcarr % 2 == 0) {
            d_n_right_inf_subcarr = d_sym_n_inf_subcarr / 2;
            d_n_left_inf_subcarr  = d_n_right_inf_subcarr;
        } else {
            if (d_sym_len_right_gi < d_sym_len_left_gi) {
                d_n_right_inf_subcarr = d_sym_n_inf_subcarr / 2 + 1;
            } else {
                d_n_right_inf_subcarr = d_sym_n_inf_subcarr / 2;
            }
            d_n_left_inf_subcarr = d_sym_n_inf_subcarr - d_n_right_inf_subcarr;
        }

        // Получение @d_n_add_zero
        d_n_add_zero = d_sym_fft_size - d_sym_sefdm_len;

        message_port_register_in(pmt::mp("sefdm_hdr_synch_in"));
        message_port_register_out(pmt::mp("sefdm_hdr_synch_out"));

        set_msg_handler( pmt::mp("sefdm_hdr_synch_in"),
                         boost::bind(&header_synchronization_impl::sefdm_hdr_synch_in_handler, this, _1) );
    }

    /*
     * Our virtual destructor.
     */
    header_synchronization_impl::~header_synchronization_impl()
    {
    }

    void
    header_synchronization_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
      for (auto& n : ninput_items_required) {
        n = noutput_items + history() - 1;
      }
    }

    int
    header_synchronization_impl::general_work (int noutput_items,
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
    header_synchronization_impl::sefdm_hdr_synch_in_handler(pmt::pmt_t msg)
    {
      size_t       in_len;
      gr_complex*  in = pmt::c32vector_writable_elements(pmt::cdr(msg), in_len);

      // Проверка размера пакета
      if ( in_len != d_hdr_no_pld_len ) {
        std::cout << "in_len: " << in_len << "   header + payload len: " << d_hdr_no_pld_len << std::endl;
        throw std::runtime_error( "(in_len) != (header + payload len)" );
      }

      // Выделяем Packet Header + удаление CP у Packet Header
      // + Сдвигаем спектр
      gr_complex  hdr[d_hdr_n_sym][d_sym_fft_size];
      static gr_complex  exp_val = gr_complex( 0.0f, 2 * M_PI * d_n_left_inf_subcarr / d_sym_fft_size );
      for (int i = 0; i < d_hdr_n_sym; ++i) { // По OFDM-символам в Packet Header

          for (int j = 0; j < d_sym_fft_size; ++j) { // По отсчётам в OFDM-символе

              hdr[i][j] = in[ i * (d_sym_fft_size + d_hdr_len_cp) + d_hdr_len_cp + j ] *
                  exp( exp_val * gr_complex(j + 1, 0.0f) );
          }
      }

      // FFT for Packet Header + Minus "Add zeros"
      std::vector<std::vector<gr_complex>>  hdr_R( d_hdr_n_sym,
                                                   std::vector<gr_complex>(d_sym_sefdm_len, gr_complex(0.0f, 0.0f)) );
      gr::fft::fft_complex  fft(d_sym_fft_size, true, 1); // fftSize, forward, numThreads
      static int  first_for_end = d_n_left_inf_subcarr + 1 + d_n_left_inf_subcarr + d_sym_len_right_gi;
      for (int i = 0; i < d_hdr_n_sym; ++i) {

          memcpy(fft.get_inbuf(),  hdr[i], d_sym_fft_size * sizeof(gr_complex));

          fft.execute();

          for (int j = 0; j < first_for_end; ++j) {
              hdr_R[i][j] = fft.get_outbuf()[j];
          }

          for (int j = first_for_end; j < d_sym_sefdm_len; ++j) {
              hdr_R[i][j] = fft.get_outbuf()[j + d_n_add_zero];
          }
      }

      // Оценка канала
      const std::vector<gr_complex>  channel_freq_response = estimate_channel(hdr_R);

      // Компенсация влияния канала для Packet Header
      for (int i = 0; i < d_hdr_n_sym; ++i) {
          equalizer(hdr_R[i], channel_freq_response);
      }

      // Оценка остаточной частотной отстройки
      float  const_fi;
      float  dfi;
      int    symNo;
      estimate_residual_freq_offset(hdr_R, const_fi, dfi, symNo);

      // Получение порядкового номера пакета

      // Выделяем Packet No + Удаление CP у Packet No
      // + Сдвигаем спектр
      gr_complex  no[d_sym_fft_size];
      for (int j = 0; j < d_sym_fft_size; ++j) {

          no[j] = in[ d_hdr_n_sym * (d_sym_fft_size + d_hdr_len_cp) + d_hdr_len_cp + j ] *
              exp( exp_val * gr_complex(j + 1, 0.0f) );
      }

      // FFT for Packet No + Minus "Add zeros"
      std::vector<gr_complex>  no_R(d_sym_sefdm_len, gr_complex(0.0f, 0.0f));
      memcpy(fft.get_inbuf(), no, d_sym_fft_size * sizeof(gr_complex));
      fft.execute();
      for (int j = 0; j < first_for_end; ++j) {
          no_R[j] = fft.get_outbuf()[j];
      }
      for (int j = first_for_end; j < d_sym_sefdm_len; ++j) {
          no_R[j] = fft.get_outbuf()[j + d_n_add_zero];
      }

      // Компенсация влияния канала и остаточной частотной отстройки для Packet No
      equalizer(no_R, channel_freq_response);
      compensate_residual_freq_offset(no_R, const_fi, dfi, symNo);

      // Packet No BPSK demap
      std::vector<int8_t>  no_modulation_sym = slicing_bpsk(no_R);

      // Удаление CP у Packet Payload
      std::vector<gr_complex>  pld_without_cp(d_pld_n_sym * d_sym_sefdm_len, gr_complex(0.0f, 0.0f));
      int  offset = (d_hdr_n_sym + 1) * (d_sym_fft_size + d_hdr_len_cp) + d_pld_len_cp;
      for (int i = 0; i < d_pld_n_sym; ++i) {

          for (int j = 0; j < d_sym_sefdm_len; ++j) {

              pld_without_cp[i * d_sym_sefdm_len + j] =
                  in[ offset + i * (d_sym_sefdm_len + d_pld_len_cp) + j ];
          }
      }


      // Формирование сообщения следующему блоку
      pmt::pmt_t  p_synch_info = pmt::make_dict();
      p_synch_info = pmt::dict_add( p_synch_info, pmt::intern("channel_est"),        pmt::init_c32vector(d_sym_sefdm_len, channel_freq_response) );
      p_synch_info = pmt::dict_add( p_synch_info, pmt::intern("packet_No"),          pmt::init_s8vector(d_sym_n_inf_subcarr, no_modulation_sym) );
      p_synch_info = pmt::dict_add( p_synch_info, pmt::intern("const_phase_offset"), pmt::from_float(const_fi) );
      p_synch_info = pmt::dict_add( p_synch_info, pmt::intern("diff_phase_offset"),  pmt::from_float(dfi) );
      p_synch_info = pmt::dict_add( p_synch_info, pmt::intern("sym_No"),             pmt::from_long(symNo) );

      pmt::pmt_t  p_pld_without_cp =
          pmt::init_c32vector(d_pld_n_sym * d_sym_sefdm_len, pld_without_cp);

      pmt::pmt_t  out_msg = cons(p_synch_info, p_pld_without_cp);

      message_port_pub(pmt::mp("sefdm_hdr_synch_out"), out_msg);
    }

    inline std::vector<gr_complex>
    header_synchronization_impl::estimate_channel(const std::vector<std::vector<gr_complex>>&  hdr_R) const
    {
       std::vector<gr_complex>  channel_freq_response(d_sym_sefdm_len, gr_complex(0.0f, 0.0f));

       for (int i = 0; i < d_hdr_n_sym; ++i) {

           for (int j = 0; j < d_sym_sefdm_len; ++j) {

              channel_freq_response[j] += hdr_R[i][j] * header_pilot_modulation_sym[i * d_sym_sefdm_len + j];
           }
       }

       float val = 1.0f / d_hdr_n_sym;
       for (int j = 0; j < d_sym_sefdm_len; ++j) {
         channel_freq_response[j] *= val;
       }

       return channel_freq_response;
    }

    inline void
    header_synchronization_impl::equalizer(std::vector<gr_complex>&        R,
                                           const std::vector<gr_complex>&  channel_freq_response) const
    {
        // Поднесущие слева от нулевой частоты
        for (int  i = 0; i < d_n_left_inf_subcarr; ++i) {
            R[i] /= channel_freq_response[i];
        }

        // DC null subcarrier
        R[d_n_left_inf_subcarr] = gr_complex(0.0f, 0.0f);

        // Поднесущие справа от нулевой частоты
        for (int  i = d_n_left_inf_subcarr + 1;
             i < d_n_left_inf_subcarr + d_n_right_inf_subcarr + 1;
             ++i) {

            R[i] /= channel_freq_response[i];
        }

        // Нулевые GI по частоте
        for (int  i = d_n_left_inf_subcarr + d_n_right_inf_subcarr + 1;
             i < d_sym_sefdm_len;
             ++i) {

            R[i] = gr_complex(0.0f, 0.0f);
        }
    }

    inline void
    header_synchronization_impl::estimate_residual_freq_offset(const std::vector<std::vector<gr_complex>>&  hdr_R,
                                                               float&  const_fi,
                                                               float&  dfi,
                                                               int&    symNo) const
    {
        int  i = 0;
        gr_complex  val(0.0f, 0.0f);
        for (int j = 0; j < d_sym_sefdm_len; ++j) {

            val += hdr_R[i][j] * header_pilot_modulation_sym[i * d_sym_sefdm_len + j];
        }
        float  fi1 = arg(val);

        i   = d_hdr_n_sym - 1;
        val = gr_complex(0.0f, 0.0f);
        for (int j = 0; j < d_sym_sefdm_len; ++j) {

            val += hdr_R[i][j] * header_pilot_modulation_sym[i * d_sym_sefdm_len + j];
        }
        float  fi2 = arg(val);

        const_fi = fi1;
        dfi      = (fi1 - fi2) / (d_hdr_n_sym - 1);
        symNo    = d_hdr_n_sym + 1;
    }

    inline void
    header_synchronization_impl::compensate_residual_freq_offset(std::vector<gr_complex>&  R,
                                                                 const float&  const_fi,
                                                                 const float&  dfi,
                                                                 int&    symNo) const
    {
        gr_complex  exp_val = exp( gr_complex(0.0f, -1 * const_fi + dfi * (symNo - 1)) );

        // Поднесущие слева от нулевой частоты
        for (int  i = 0; i < d_n_left_inf_subcarr; ++i) {
            R[i] *= exp_val;
        }

        // Поднесущие справа от нулевой частоты
        for (int  i = d_n_left_inf_subcarr + 1;
             i < d_n_left_inf_subcarr + d_n_right_inf_subcarr + 1;
             ++i) {

            R[i] *= exp_val;
        }

        symNo = symNo + 1;
    }

    inline std::vector<int8_t>
    header_synchronization_impl::slicing_bpsk(const std::vector<gr_complex>&  R) const
    {
        std::vector<int8_t> modulation_sym(d_sym_n_inf_subcarr, 0);

        int j = 0,
            i;

        for (i = d_n_left_inf_subcarr + 1;
             i < d_n_left_inf_subcarr + 1 + d_n_right_inf_subcarr;
             ++i, ++j) {

          modulation_sym[j] = ( R[i].real() > 0 ) ? 1 : -1;
        }

        for (i = 0; i < d_n_left_inf_subcarr; ++i, ++j) {
          modulation_sym[j] = ( R[i].real() > 0 ) ? 1 : -1;
        }

        return modulation_sym;
    }


  } /* namespace sefdm */
} /* namespace gr */

