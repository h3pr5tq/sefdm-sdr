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
#include "history_test_impl.h"

namespace gr {
  namespace learn {

    history_test::sptr
    history_test::make()
    {
      return gnuradio::get_initial_sptr
        (new history_test_impl());
    }

    /*
     * The private constructor
     */
    history_test_impl::history_test_impl()
      : gr::block("history_test",
              gr::io_signature::make2(2, 2, sizeof(float), sizeof(float)),
              gr::io_signature::make(1, 1, sizeof(float)))
    {
      set_history(3);
      set_max_noutput_items(4);
    }

    /*
     * Our virtual destructor.
     */
    history_test_impl::~history_test_impl()
    {
    }

    void
    history_test_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
      for (auto& n : ninput_items_required) {
        n = noutput_items + history() - 1;
      }
    }

    int
    history_test_impl::general_work (int noutput_items,
                       gr_vector_int &ninput_items,
                       gr_vector_const_void_star &input_items,
                       gr_vector_void_star &output_items)
    {
      const float *filtered_in = (const float *) input_items[0];
      float *out = (float *) output_items[0];

      const float *without_dc_in = (const float *) input_items[1];

      std::cout << "\nEnter the general_work" << std::endl;
      std::cout << "history == " << history() <<
          "; max_noutput_items == " << max_noutput_items() << std::endl;

      // print all elements in @in buffers
      int in_len = noutput_items + history() - 1;
      std::cout << "print all elements in @FILTERED_IN buffer:" << std::endl;
      print_float_val(filtered_in, in_len);
      std::cout << "print all elements in @WITHOUT_DC_IN buffer:" << std::endl;
      print_float_val(without_dc_in, in_len);

      // out
      for (int i = 0; i < noutput_items; ++i) {
        out[i] = filtered_in[i] + 1000;
      }
      std::cout << "print all elements in @OUT buffer:" << std::endl;
      print_float_val(out, noutput_items);

      // Do <+signal processing+>
      // Tell runtime system how many input items we consumed on
      // each input stream.
      std::cout << "consume " << noutput_items << " items" << std::endl;
      consume_each (noutput_items);

      // Tell runtime system how many output items we produced.
      return noutput_items;
    }

    void
    history_test_impl::print_float_val(const float* buf, int buf_len) const
    {
      for (int i = 0; i < buf_len - 1; ++i) {
        std::cout << buf[i] << ' ';
      }
      std::cout << buf[buf_len - 1] << std::endl;
    }

  } /* namespace learn */
} /* namespace gr */

