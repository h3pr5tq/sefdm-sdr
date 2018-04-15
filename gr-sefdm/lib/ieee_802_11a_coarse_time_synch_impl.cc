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
#include "ieee_802_11a_coarse_time_synch_impl.h"

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

    ieee_802_11a_coarse_time_synch::sptr
    ieee_802_11a_coarse_time_synch::make()
    {
      return gnuradio::get_initial_sptr
        (new ieee_802_11a_coarse_time_synch_impl());
    }

    /*
     * The private constructor
     */
    ieee_802_11a_coarse_time_synch_impl::ieee_802_11a_coarse_time_synch_impl()
      : gr::block("ieee_802_11a_coarse_time_synch",
              gr::io_signature::make(0, 0, sizeof(gr_complex)),
              gr::io_signature::make(0, 0, sizeof(gr_complex))),
        // параметры алгоритма CTS
        d_cts_segment_len(160),
        d_cts_summation_window(144),
        d_cts_signal_offset(16),

        // параметры алгоритма FFS
        d_ffs_offset_from_cts(15), // смещение от cts_est, чтобы затронуть только STS
        d_ffs_summation_window(64), // L
        d_ffs_signal_offset(64), // D

        // параметры алгоритма FTS
        d_fts_offset_from_cts(160 + 32 - 20), // [(10STS + LGI) - x], где x  оцениваем по моделированию CTS
                                              // Должен 100% попасть первый отсчёт первого LTS
        d_fts_segment_len(40), // Оцениваем по моделированию CTS; данный параметр связан с x
                               // Если брать слишком большой, можем затронуть второй LTS --> получим второй пик, который не нужен
        d_fts_etalon_seq_len(32), // Коррелируем с первыми 32 отсчётами LTS (до 64 можно брать)

        d_num_ofdm_sym_in_payload(20),

        d_subcarriers_num(64)
    {
      message_port_register_in(pmt::mp("in"));
      message_port_register_out(pmt::mp("out"));

      set_msg_handler( pmt::mp("in"),
                       boost::bind(&ieee_802_11a_coarse_time_synch_impl::in_handler_function, this, _1) );

    }

    /*
     * Our virtual destructor.
     */
    ieee_802_11a_coarse_time_synch_impl::~ieee_802_11a_coarse_time_synch_impl()
    {
    }

    void
    ieee_802_11a_coarse_time_synch_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
      for (auto& n : ninput_items_required) {
        n = noutput_items + history() - 1;
      }
    }

    int
    ieee_802_11a_coarse_time_synch_impl::general_work (int noutput_items,
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

    // Handler fucntion, которая вызовится когда на порт "in_port_name_ID"
    // придёт сообщение
    // (выполняет обработку сообщения)
    // @msg - принятое сообщениие (формат сообщения может быть любым, но мы
    //   как разработчик должны строго его знать)
    //
    // Пусть msg - это const==pair (состоит из двух элементов типа pmt_t); pair позволяет обращаться как first, или car
    // и second или cdr
    //
    // Отсчёты никак не меняем
    //
    // Р ЕАДИЗАЦИЯ В ВИДЕ ОДНОГО БЛОКА И В ВИДЕ НЕСКОЛЬКИХ БЛОКОВ (ПОТОМ)!
    void
    ieee_802_11a_coarse_time_synch_impl::in_handler_function(pmt::pmt_t msg)
    {
        size_t             in_len;
        const gr_complex*  in = pmt::c32vector_elements(pmt::cdr(msg), in_len);

        // CTS
        int  cts_est = estimate_coarse_time_offset(in); // верно

        // FFS
        float  ffs_est = estimate_fine_freq_offset(in, cts_est); // верно

        // Сюда компенсацию частоты

        // FTS
        // Не забыть компенсировать freq offset!
        int  fts_est = estimate_fine_time_offset(in, cts_est, ffs_est); // верно


        // Оценка канала - channel_est оценка канала в частотной области
        const std::vector<gr_complex> channel_est = estimate_channel(in, ffs_est, fts_est); // верно


        // Добавляем оценку CTS в виде мета-информации
        // Создание словаря с мето-инфой
        pmt::pmt_t  p_meta = pmt::car(msg); // dict
        p_meta = dict_add(p_meta, pmt::intern("cts_est"),     pmt::from_long(cts_est)); // поидее не нужны
        p_meta = dict_add(p_meta, pmt::intern("fts_est"),     pmt::from_long(fts_est)); // поидее не нужны
        p_meta = dict_add(p_meta, pmt::intern("ffs_est"),     pmt::from_float(ffs_est));
        p_meta = dict_add(p_meta, pmt::intern("channel_est"), pmt::init_c32vector(52, channel_est));
        set_car(msg, p_meta);

        // Удаление преамбулы и передача по одному ofdm-символу следующему блоку
        gr_complex one_ofdm_sym[d_subcarriers_num];
        for (int i = 0; i < d_num_ofdm_sym_in_payload; ++i) {

            for (int j = 0; j < d_subcarriers_num; ++j) {
              one_ofdm_sym[j] = in[0 + fts_est + 64 + 64 + 16 + j + i * 80];
            }
            pmt::pmt_t  p_one_ofdm_sym =
                pmt::init_c32vector(d_subcarriers_num, one_ofdm_sym);
//            set_cdr(msg, p_one_ofdm_sym); // 48 ?? мб тут ошибка и надо новый создавать экземпляр
//            // вывести в консоль (сообщения (pdu) содержат одинаковую payload нагрузку)
            pmt::pmt_t  msg2 = cons(p_meta, p_one_ofdm_sym); // НАДО создавать новое pdu!
            message_port_pub(pmt::mp("out"), msg2); // верно
        }
    }


    inline int
    ieee_802_11a_coarse_time_synch_impl::estimate_coarse_time_offset(const gr_complex* in) const
    {
       // Находим автокорреляции для @d_cts_segment_len первых отсчётов пакета
       // используя рекурсивный алгоритм; за оценку cts берём максимальный модуль автокорреляции

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
    ieee_802_11a_coarse_time_synch_impl::estimate_fine_freq_offset(const gr_complex* in, int cts_est) const
    {
      in = in + cts_est + d_ffs_offset_from_cts; // верно

      gr_complex  autocorr(0.0f, 0.0f);
      for ( int i = 0; i < d_ffs_summation_window; ++i ) {
        autocorr += in[i] * conj(in[i + d_ffs_signal_offset]);
      }

      return d_subcarriers_num / (2 * M_PI * d_ffs_signal_offset) * arg(autocorr);
    }


    inline int
    ieee_802_11a_coarse_time_synch_impl::estimate_fine_time_offset(const gr_complex* in, int cts_est, float ffs_est) const
    {
      // Не забыть компенсировать freq offset!

      in = in + cts_est + d_fts_offset_from_cts; // учесть при возвращаемом ИНДЕКСЕ

      // Компенсируем частотную отстройку
      gr_complex in_after_freq_offset_compensation[d_fts_segment_len + d_fts_etalon_seq_len - 1];
      memcpy( in_after_freq_offset_compensation,
              in,
              (d_fts_segment_len + d_fts_etalon_seq_len - 1) * sizeof(gr_complex) );

      for (int i = 0; i < d_fts_segment_len + d_fts_etalon_seq_len - 1; ++i) {

        in_after_freq_offset_compensation[i] *=
            exp( gr_complex(0.0f, 2 * M_PI * ffs_est * (i + 1) / d_subcarriers_num) );
      } // верно

      float  max_abs_crosscorr = 0.0f;
      int    fts_est = 0;
      for (int i = 0; i < d_fts_segment_len; ++i) {

          // cross corr
          gr_complex crosscorr(0.0f, 0.0f);
          for (int k = 0; k < d_fts_etalon_seq_len; ++k) {

            crosscorr += in_after_freq_offset_compensation[i + k] * conj( one_lts_in_time_domain[k] );
          }

          float abs_crosscorr = abs(crosscorr);
          if (abs_crosscorr > max_abs_crosscorr) {
            max_abs_crosscorr = abs_crosscorr;
            fts_est = i;
          }
      }

      return fts_est + cts_est + d_fts_offset_from_cts;
    }


    // МБ на вход подаваьть in, fts_est, ffs_est
    // НАДО КОМПЕНСИРОВАТ ЧАСТОТНУЮ ОТСТРОЙКУ
//    inline std::vector<gr_complex>
//    ieee_802_11a_coarse_time_synch_impl::estimate_channel(const gr_complex* rx_two_lts_in_time_domain) const
    inline std::vector<gr_complex>
    ieee_802_11a_coarse_time_synch_impl::estimate_channel(const gr_complex* in, float ffs_est, int fts_est) const
    {
      static const signed char etalon_one_lts[52] = {
           1,    -1,    -1,     1,     1,    -1,     1,    -1,     1,    -1,    -1,
          -1,    -1,    -1,     1,     1,    -1,    -1,     1,    -1,     1,    -1,
           1,     1,     1,     1,     1,     1,    -1,    -1,     1,     1,    -1,
           1,    -1,     1,     1,     1,     1,     1,     1,    -1,    -1,     1,
           1,    -1,     1,    -1,     1,     1,     1,     1
      };

      // Компенсируем частотную отстройку ПРОВЕРИТЬ НУЖНА ЛИ ОНА!
      gr_complex  rx_two_lts_in_time_domain[64 + 64];
      memcpy( rx_two_lts_in_time_domain,
              in + fts_est,
              (64 + 64) * sizeof(gr_complex) ); // верно
      for (int i = 0; i < 64 + 64; ++i) {

        rx_two_lts_in_time_domain[i] *=
            exp( gr_complex(0.0f, 2 * M_PI * ffs_est * (i + 1) / d_subcarriers_num) );
      } // верно

      gr::fft::fft_complex fft(64, true, 1); // fftSize, forward, numThreads

      // get first rx_first_lts (freq domain)
      gr_complex rx_first_lts[52];
      memcpy(fft.get_inbuf(), rx_two_lts_in_time_domain, 64 * sizeof(gr_complex));
      fft.execute();
      for (int i = 1; i <= 26; ++i) {

        rx_first_lts[i - 1] = fft.get_outbuf()[i];
      }
      for (int i = 38; i <= 63; ++i) {
        rx_first_lts[i - 12] = fft.get_outbuf()[i];
      } // верно

      // get first rx_second_lts (freq domain)
      gr_complex  rx_second_lts[52];
      memcpy(fft.get_inbuf(), rx_two_lts_in_time_domain + 64, 64 * sizeof(gr_complex));
      fft.execute();
      for (int i = 1; i <= 26; ++i) {
        rx_second_lts[i - 1] = fft.get_outbuf()[i];
      }
      for (int i = 38; i <= 63; ++i) {
        rx_second_lts[i - 12] = fft.get_outbuf()[i];
      } // верно

      // get channel estimation (freq domain)
      std::vector<gr_complex>  channel_est(52, gr_complex(0.0f, 0.0f));
      for (int i = 0; i < 52; ++i) {
        channel_est[i] = gr_complex(0.5f, 0.0f) * (rx_first_lts[i] + rx_second_lts[i]) * gr_complex(etalon_one_lts[i], 0.0f);
      }

      return channel_est;
    }

  } /* namespace sefdm */
} /* namespace gr */

