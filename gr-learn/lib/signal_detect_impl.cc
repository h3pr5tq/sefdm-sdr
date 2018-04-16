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
#include "signal_detect_impl.h"
#include <complex>
#include <cmath>

using std::conj;
using std::abs;

namespace gr {
  namespace learn {

    signal_detect::sptr
    signal_detect::make(int summation_window, int signal_offset, float detection_threshold)
    {
      return gnuradio::get_initial_sptr
        (new signal_detect_impl(summation_window, signal_offset, detection_threshold));
    }

    /*
     * The private constructor
     */
    signal_detect_impl::signal_detect_impl(int summation_window, int signal_offset, float detection_threshold)
      : gr::block("signal_detect",
              gr::io_signature::make2(2, 2, sizeof(gr_complex), sizeof(gr_complex)),
              gr::io_signature::make2(2, 2, sizeof(gr_complex), sizeof(float))),
        d_summation_window(summation_window),
        d_signal_offset(signal_offset),
        d_detection_threshold(detection_threshold)
//        d_is_first_metric_calc(true),
//        d_prev_autocorr(gr_complex(0, 0)),
//        d_prev_energy(0.0f)
    {
      set_history(summation_window + signal_offset);
    }

    /*
     * Our virtual destructor.
     */
    signal_detect_impl::~signal_detect_impl()
    {
    }

    // Задаём сколько элемнтов во входных буферах требуется, чтобы
    // произвести на выход noutput_items элементов
    //
    // ВАЖНО!: forecast задаёт границу снизу для размера входного буфера!
    // Вообще ninput_items[0] м.б. больше чем noutput_items!
    // Поэтому используем цикл вида for (int i = 0; i < NOUTPUT_ITEMS; ++i) { out[i] ... }
    void
    signal_detect_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
      for (auto& n : ninput_items_required) {
        n = noutput_items + history() - 1;
      }
    }

    int
    signal_detect_impl::general_work (int noutput_items,
                       gr_vector_int &ninput_items,
                       gr_vector_const_void_star &input_items,
                       gr_vector_void_star &output_items)
    {
      const gr_complex *filtered_in = (const gr_complex *) input_items[0]; // without DC (after filtering)
      const gr_complex *in = (const gr_complex *) input_items[1]; // pure signal without filtering

      gr_complex *out = (gr_complex *) output_items[0]; // part of @in with signal detection tags
      float *detection_metric = (float *) output_items[1];

      // Do <+signal processing+>
      int index = history() - 1; // index of first new item (skip history)

      // calculate @d_prev_autocorr and @d_prev_energy
//      if (d_is_first_metric_calc == true) {


        gr_complex d_prev_autocorr = calc_autocorr(filtered_in + index);
        float d_prev_energy   = calc_energy(filtered_in + index);

        detection_metric[0] = abs(d_prev_autocorr) * abs(d_prev_autocorr) /
            abs(d_prev_energy) / abs(d_prev_energy);

        if (detection_metric[0] > d_detection_threshold) {
          std::cout << "Detect Signal!" << std::endl;
        }

        out[0] = in[index + 0];

//        d_is_first_metric_calc = false;

//      }

      gr_complex autocorr;
      float energy;
      float abs_val_1,
            abs_val_2;
      for (int i = 1; i < noutput_items; ++i) { // i = 1 !!! // если i делать с 0, то history придётся увеличивать на единицу!

//        conj_1 = conj(filtered_in[i + index - d_signal_offset]);
//        conj_2 = conj(filtered_in[i + index  - d_summation_window - d_signal_offset]);

        autocorr = d_prev_autocorr +
            filtered_in[i + index]                      * conj(filtered_in[i + index - d_signal_offset]) -
            filtered_in[i + index - d_summation_window] * conj(filtered_in[i + index  - d_summation_window - d_signal_offset]);


        abs_val_1 = abs(filtered_in[i + index - d_signal_offset]);
        abs_val_2 = abs(filtered_in[i + index  - d_summation_window - d_signal_offset]);

        energy = d_prev_energy +
            abs_val_1 * abs_val_1  -
            abs_val_2 * abs_val_2;

        detection_metric[i] = abs(autocorr) * abs(autocorr) / abs(energy) / abs(energy);

        d_prev_autocorr = autocorr;
        d_prev_energy = energy;

        if (detection_metric[i] > d_detection_threshold) {
          std::cout << "Detect Signal!" << std::endl;
        }

        out[i] = in[index + i];
      }


      // Tell runtime system how many input items we consumed on
      // each input stream.
      // Говорим сколько элементов из входных буферов обработали-задействовали,
      // для того чтобы их откинуть при следующем вызове функции general_work
      consume_each(noutput_items + history() - 1);

      // Tell runtime system how many output items we produced.
      // см. produce()
      return noutput_items;
    }


    gr_complex
    signal_detect_impl::calc_autocorr(const gr_complex* sig) const
    {
      gr_complex autocorr = 0;
      for (int k = 0; k < d_summation_window; ++k) {
        autocorr += sig[-k] * conj(sig[-k - d_signal_offset]);
      }

      return autocorr;
    }

    float
    signal_detect_impl::calc_energy(const gr_complex* sig) const
    {
      float energy = 0,
            abs_val;
      for (int k = 0; k < d_summation_window; ++k) {
        abs_val = abs(sig[-k - d_signal_offset]);
        energy += abs_val * abs_val;
      }

      return energy;
    }

  } /* namespace learn */
} /* namespace gr */

