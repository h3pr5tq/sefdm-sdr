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

    ieee_802_11a_preamble_detection::sptr
    ieee_802_11a_preamble_detection::make(int summation_window,
                                          int signal_offset,
                                          float detection_threshold,
                                          bool use_recursive_algorithm,
                                          float eps)
    {
      return gnuradio::get_initial_sptr
        (new ieee_802_11a_preamble_detection_impl(summation_window, signal_offset, detection_threshold, use_recursive_algorithm, eps));
    }

    /*
     * The private constructor
     */
    ieee_802_11a_preamble_detection_impl::ieee_802_11a_preamble_detection_impl(int summation_window,
                                                                               int signal_offset,
                                                                               float detection_threshold,
                                                                               bool use_recursive_algorithm,
                                                                               float eps)
      : gr::block("ieee_802_11a_preamble_detection",
              gr::io_signature::make2(2, 2, sizeof(gr_complex), sizeof(gr_complex)),
              gr::io_signature::make2(2, 2, sizeof(gr_complex), sizeof(float))),
        d_summation_window(summation_window),
        d_signal_offset(signal_offset),
        d_detection_threshold(detection_threshold),
        d_use_recursive_algorithm(use_recursive_algorithm),
        d_eps(eps)
    {
      set_history(summation_window + signal_offset);
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
      const gr_complex *in            = (const gr_complex *) input_items[0];
      const gr_complex *without_dc_in = (const gr_complex *) input_items[1];

      gr_complex *out = (gr_complex *) output_items[0];
      float *detection_metric = (float *) output_items[1];

      // Do <+signal processing+>

      if (d_use_recursive_algorithm == true) {

        // i = 0 (first iteration)
        gr_complex autocorr = calc_autocorr(without_dc_in);
        float      energy   = calc_energy(without_dc_in);

        detection_metric[0] = calc_detection_metric(autocorr, energy);
        out[0]              = in[0];

        if (detection_metric[0] > d_detection_threshold) { // рекурсивный алгоритм (НЕ РАБОТАЕТ)
          // Signal Detection!
          // skip samples
          //std::cout << "Signal Detection" << "i == " << 0 << std::endl;
          // Тут это кусок не нужен, некретично если одну метрику пропустим!
        }

        // i = 1 ... (recursive algorithm)
        for (int i = 1; i < noutput_items; ++i) {

          autocorr = autocorr -

              without_dc_in[i - 1] *
              conj( without_dc_in[i - 1 + d_signal_offset] ) +

              without_dc_in[i - 1 + d_summation_window] *
              conj( without_dc_in[i - 1 + d_summation_window + d_signal_offset] );

          energy = energy +

              abs( without_dc_in[i - 1 + d_summation_window + d_signal_offset] ) *
              abs( without_dc_in[i - 1 + d_summation_window + d_signal_offset] ) -

              abs( without_dc_in[i - 1 + d_summation_window] ) *
              abs( without_dc_in[i - 1 + d_summation_window] );

          detection_metric[i] = calc_detection_metric(autocorr, energy);
          out[i]              = in[i];

          if (detection_metric[i] > d_detection_threshold) {
            // Signal Detection!
            // skip samples
            //std::cout << "Signal Detection" << "i == " << i << std::endl;
          }
        }

      } else { // обычный алгоритм

        gr_complex  autocorr;
        float       energy;

//        float MAX_DETECTION_METRIC=0;
//        int IDNEX = 0;

        for (int i = 0; i < noutput_items; ++i) {

          autocorr = calc_autocorr(without_dc_in + i);
          energy   = calc_energy(without_dc_in + i);

          detection_metric[i] = calc_detection_metric(autocorr, energy);
          out[i]              = in[i];

//          if (i < 700) {
//            if (MAX_DETECTION_METRIC < detection_metric[i]) {
//              MAX_DETECTION_METRIC = detection_metric[i];
//              IDNEX = i;
//            }
//          }
        }

//        std::cout << "Max detection: detection_metric[" << IDNEX << "] = " << MAX_DETECTION_METRIC << std::endl;
//        std::cout << "out[" << IDNEX << "] = " << out[IDNEX] << std::endl;
//        std::cout << "out[" << IDNEX-1 << "] = " << out[IDNEX-1] << std::endl;
//        std::cout << "out[" << IDNEX-2 << "] = " << out[IDNEX-2] << std::endl;
//        std::cout << "out[" << IDNEX-3 << "] = " << out[IDNEX-3] << std::endl;
//        std::cout << "out[" << IDNEX+1 << "] = " << out[IDNEX+1] << std::endl;
//        std::cout << "out[" << IDNEX+2 << "] = " << out[IDNEX+2] << std::endl;

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
      gr_complex autocorr = 0;
      for (int k = 0; k < d_summation_window; ++k) {
        autocorr += sig[k] * conj(sig[k + d_signal_offset]);
      }

      return autocorr;
    }

    inline float
    ieee_802_11a_preamble_detection_impl::calc_energy(const gr_complex* sig) const
    {
      float energy = 0,
            abs_val;
      for (int k = 0; k < d_summation_window; ++k) {
        abs_val = abs(sig[k + d_signal_offset]);
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

  } /* namespace sefdm */
} /* namespace gr */

