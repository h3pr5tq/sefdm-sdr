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

#ifndef INCLUDED_SEFDM_EXTRACT_PACKETS_FROM_STREAM_IMPL_H
#define INCLUDED_SEFDM_EXTRACT_PACKETS_FROM_STREAM_IMPL_H

#include <sefdm/extract_packets_from_stream.h>

namespace gr {
  namespace sefdm {

    class extract_packets_from_stream_impl : public extract_packets_from_stream
    {
     private:
      // Nothing to declare in this block.
      const std::string  d_tag_key;

     public:
      extract_packets_from_stream_impl(const std::string& tag_key);
      ~extract_packets_from_stream_impl();

      // Where all the action really happens
      void forecast (int noutput_items, gr_vector_int &ninput_items_required);

      int general_work(int noutput_items,
           gr_vector_int &ninput_items,
           gr_vector_const_void_star &input_items,
           gr_vector_void_star &output_items);
    };

  } // namespace sefdm
} // namespace gr

#endif /* INCLUDED_SEFDM_EXTRACT_PACKETS_FROM_STREAM_IMPL_H */

