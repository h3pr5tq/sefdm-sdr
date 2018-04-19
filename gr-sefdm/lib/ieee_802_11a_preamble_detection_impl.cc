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
#include "ieee_802_11a_preamble_detection_impl.h"

namespace gr {
  namespace sefdm {

    static const int  PREAMBLE_LEN = 320; // в отсчётах

    ieee_802_11a_preamble_detection::sptr
    ieee_802_11a_preamble_detection::make(int summation_window,
                                          int signal_offset,
                                          float detection_threshold,
                                          bool use_recursive_algorithm,
                                          float eps,
                                          const std::string& tag_key,
                                          int packet_len,
                                          int margin)
    {
      return gnuradio::get_initial_sptr
        (new ieee_802_11a_preamble_detection_impl(summation_window, signal_offset, detection_threshold,
                                                  use_recursive_algorithm, eps,
                                                  tag_key, packet_len, margin));
    }

    /*
     * The private constructor
     */
    ieee_802_11a_preamble_detection_impl::ieee_802_11a_preamble_detection_impl(int summation_window,
                                                                               int signal_offset,
                                                                               float detection_threshold,
                                                                               bool use_recursive_algorithm,
                                                                               float eps,
                                                                               const std::string& tag_key,
                                                                               int packet_len,
                                                                               int margin)
      : gr::block("ieee_802_11a_preamble_detection",
              gr::io_signature::make2(2, 2, sizeof(gr_complex), sizeof(gr_complex)),
              gr::io_signature::make2(1, 2, sizeof(gr_complex), sizeof(float))),
        d_summation_window(summation_window),
        d_signal_offset(signal_offset),
        d_detection_threshold(detection_threshold),
        d_use_recursive_algorithm(use_recursive_algorithm),
        d_eps(eps),
        d_tag_key(tag_key),
        d_packet_len_with_margin(packet_len + margin),
        d_cntr(0),
        d_detected_pckt_num(0)
    {
      set_history(summation_window + signal_offset);

#if HANDLE_PRMBL_NEXT_WORK_CALL == 1
      set_output_multiple(512);
#endif
    }

    /*
     * Our virtual destructor.
     */
    ieee_802_11a_preamble_detection_impl::~ieee_802_11a_preamble_detection_impl()
    {
    }

    void
    ieee_802_11a_preamble_detection_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
      for (auto& n : ninput_items_required) {
        n = noutput_items + history() - 1;
      }
    }

    int
    ieee_802_11a_preamble_detection_impl::general_work (int noutput_items,
                       gr_vector_int &ninput_items,
                       gr_vector_const_void_star &input_items,
                       gr_vector_void_star &output_items)
    {
      // Buffers size: noutput_items + history() - 1 == noutput_items + L + D - 1
      const gr_complex  *in            = (const gr_complex *) input_items[0];
      const gr_complex  *without_dc_in = (const gr_complex *) input_items[1];

      gr_complex  *out              = (gr_complex *) output_items[0];
      float       *detection_metric = (float *)      output_items[1];


      // П Р Е Д П О Л А Г А Е М   Ч Т О   Fd  Н А  Tx и Rx  С О В П А Д А Ю Т
      // UPSAMPLING на Rx отсутствует

      if (d_use_recursive_algorithm == true) { // Р Е К У Р С И В Н Ы Й   А Л Г О Р И Т М   О Б Н А Р У Ж Е Н И Я

        int  i; // for loop ==> (i + 1) is number consume/produce items
        int  skip_prmbl_cntr = 0; // cntr for skip preamble

        // i = 0 (first iteration)
        i = 0;
        gr_complex autocorr = calc_autocorr(without_dc_in);
        float      energy   = calc_energy(without_dc_in);

        detection_metric[i] = calc_detection_metric(autocorr, energy);
        out[i]              = in[i];

        if ( detection_metric[i] > d_detection_threshold ) {

          // Обработать ситуацию когда треугольник который надо скипнуть
          // полностью не вмещается во входном буфере --> его обработать при следующем вызове general_work()
          if (i + PREAMBLE_LEN >= noutput_items) {
            debug_print(noutput_items, ninput_items[0]);
#if HANDLE_PRMBL_NEXT_WORK_CALL == 1
            consume_each (i + 1); // 1
            return i + 1; // 1
#endif
          }

          // Тэг для @out
          add_item_tag(0, // Port number
                       nitems_written(0) + i, // Offset (абсолютное смещение)
                       pmt::mp(d_tag_key), // Key
                       pmt::mp(d_packet_len_with_margin) // Value
          );

          // Тэг для @detection_metric
          add_item_tag( 1, nitems_written(1) + i, pmt::mp("Detect Preamble"), pmt::mp(detection_metric[i]) );

          skip_prmbl_cntr = PREAMBLE_LEN - 1; // Для скипа "треугольник"

          d_detected_pckt_num++;
#ifdef CMAKE_BUILD_TYPE_DEBUG
          std::cout << "number of detected packets: " << d_detected_pckt_num << " : " << nitems_read(0) + i + 1 << std::endl;
#endif
        }

        // i = 1 ... (recursive algorithm)
        for (i = 1; i < noutput_items; ++i) {

          autocorr = autocorr -

              without_dc_in[i - 1] *
              conj( without_dc_in[i - 1 + d_signal_offset] ) +

              without_dc_in[i - 1 + d_summation_window] *
              conj( without_dc_in[i - 1 + d_summation_window + d_signal_offset] );

          energy = energy +

              abs( without_dc_in[i - 1 + d_summation_window + d_signal_offset] ) *
              abs( without_dc_in[i - 1 + d_summation_window + d_signal_offset] ) -

              abs( without_dc_in[i - 1 + d_signal_offset] ) *
              abs( without_dc_in[i - 1 + d_signal_offset] );

          detection_metric[i] = calc_detection_metric(autocorr, energy);
          out[i]              = in[i];

          if ( detection_metric[i] > d_detection_threshold &&
               skip_prmbl_cntr <= 0 ) {

            // Обработать ситуацию когда треугольник который надо скипнуть
            // полностью не вмещается во входном буфере --> его обработать при следующем вызове general_work()
            //
            // Мб пока убрать??
            if (i + PREAMBLE_LEN >= noutput_items) {
              debug_print(noutput_items, ninput_items[0]);
#if HANDLE_PRMBL_NEXT_WORK_CALL == 1
              consume_each (i + 1);
              return i + 1;
#endif
            }

            add_item_tag( 0, nitems_written(0) + i, pmt::mp(d_tag_key), pmt::mp(d_packet_len_with_margin) );
            add_item_tag( 1, nitems_written(1) + i, pmt::mp("Detect Preamble"), pmt::mp(detection_metric[i]) );

            skip_prmbl_cntr = PREAMBLE_LEN; // Для скипа "треугольник"

            d_detected_pckt_num++;
#ifdef CMAKE_BUILD_TYPE_DEBUG
            std::cout << "number of detected packets: " << d_detected_pckt_num << " : " << nitems_read(0) + i + 1 << std::endl;
#endif
          }
          skip_prmbl_cntr--;

        }

      } else { // О Б Ы Ч Н Ы Й   А Л Г О Р И Т М

        int  i; // for loop ==> (i + 1) is number consume/produce items
        int  skip_prmbl_cntr = 0; // cntr for skip preamble

        gr_complex  autocorr;
        float       energy;

        for (i = 0; i < noutput_items; ++i) {

            autocorr = calc_autocorr(without_dc_in + i);
            energy   = calc_energy(without_dc_in + i);

            detection_metric[i] = calc_detection_metric(autocorr, energy);
            out[i]              = in[i];

            if ( detection_metric[i] > d_detection_threshold &&
                 skip_prmbl_cntr <= 0 ) {

              if (i + PREAMBLE_LEN >= noutput_items) {
                debug_print(noutput_items, ninput_items[0]);
#if HANDLE_PRMBL_NEXT_WORK_CALL == 1
                consume_each (i + 1);
                return i + 1;
#endif
              }

              add_item_tag( 0, nitems_written(0) + i, pmt::mp(d_tag_key), pmt::mp(d_packet_len_with_margin) );
              add_item_tag( 1, nitems_written(1) + i, pmt::mp("Detect Preamble"), pmt::mp(detection_metric[i]) );

              skip_prmbl_cntr = PREAMBLE_LEN; // Для скипа "треугольник"

              d_detected_pckt_num++;
#ifdef CMAKE_BUILD_TYPE_DEBUG
              std::cout << "number of detected packets: " << d_detected_pckt_num << " : " << nitems_read(0) + i + 1 << std::endl;
#endif
            }
            skip_prmbl_cntr--;
        }

      }

      // Tell runtime system how many input items we consumed on
      // each input stream.
      consume_each (noutput_items);
      // Tell runtime system how many output items we produced.
      return noutput_items;

    }

    inline gr_complex
    ieee_802_11a_preamble_detection_impl::calc_autocorr(const gr_complex* sig) const
    {
      gr_complex autocorr(0.0f, 0.0f);
      for (int k = 0; k < d_summation_window; ++k) {
        autocorr += sig[k] * conj( sig[k + d_signal_offset] );
      }

      return autocorr;
    }

    inline float
    ieee_802_11a_preamble_detection_impl::calc_energy(const gr_complex* sig) const
    {
      float energy = 0.0f,
            abs_val;
      for (int k = 0; k < d_summation_window; ++k) {
        abs_val = abs( sig[k + d_signal_offset] );
        energy += abs_val * abs_val;
      }

      return energy;
    }


    inline float
    ieee_802_11a_preamble_detection_impl::calc_detection_metric(gr_complex autocorr, float energy) const
    {
      float abs_autocorr = abs(autocorr);

      if (energy < d_eps || abs_autocorr < d_eps) {
        return 0.0f;
      } else {
        return abs_autocorr * abs_autocorr / energy / energy;
      }
    }

    inline void
    ieee_802_11a_preamble_detection_impl::debug_print(int noutput_items, int ninput_items)
    {
      std::cout << std::endl;
      std::cout << d_cntr << ") general_work(): i + PREAMBLE_LEN >= noutput_items" << std::endl;
      std::cout << "noutput_imtems == " << noutput_items << "; ninput_items[0] == " << ninput_items << std::endl;
      d_cntr++;
    }

//    inline bool
//    ieee_802_11a_preamble_detection_impl::is_preamble_detection(float detection_metric) const
//    {
//      if ( detection_metric > d_detection_threshold &&
//           skip_prmbl_cntr <= 0 ) {
//
//        // Обработать ситуацию когда треугольник который надо скипнуть
//        // полностью не вмещается во входном буфере --> его обработать при следующем вызове general_work()
//        //
//        // Мб пока убрать??
//        if (i + PREAMBLE_LEN >= noutput_items) {
//          std::cout << "\nieee_802_11a_preamble_detection_impl::general_work(): i + PREAMBLE_LEN >= noutput_items" << std::endl;
//          std::cout << "noutput_imtems == " << noutput_items << "; ninput_items[0] == " << ninput_items[0] << std::endl;
////              i++;
////              break;
//        }
//
//        // Тэг для @out
//        add_item_tag(0, // Port number
//                     nitems_written(0) + i, // Offset (абсолютное смещение)
//                     pmt::mp(d_tag_key), // Key
//                     pmt::mp(d_packet_len_with_margin) // Value
//        );
//
//        // Тэг для @detection_metric
//        add_item_tag( 1, nitems_written(1) + i, pmt::mp("Detect Preamble"), pmt::mp(detection_metric[i]) );
//
//        skip_prmbl_cntr = PREAMBLE_LEN; // Для скипа "треугольник"
//      }
//    }

  } /* namespace sefdm */
} /* namespace gr */

