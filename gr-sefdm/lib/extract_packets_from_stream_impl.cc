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
#include "extract_packets_from_stream_impl.h"

namespace gr {
  namespace sefdm {

    extract_packets_from_stream::sptr
    extract_packets_from_stream::make(const std::string& tag_key)
    {
      return gnuradio::get_initial_sptr
        (new extract_packets_from_stream_impl(tag_key));
    }

    /*
     * The private constructor
     */
    extract_packets_from_stream_impl::extract_packets_from_stream_impl(const std::string& tag_key)
      : gr::block("extract_packets_from_stream",
              gr::io_signature::make(1, 1, sizeof(gr_complex)),
              gr::io_signature::make(1, 1, sizeof(gr_complex))),
        d_tag_key(tag_key)
    {
      set_tag_propagation_policy(TPP_DONT);
      set_output_multiple(4096);
    }

    /*
     * Our virtual destructor.
     */
    extract_packets_from_stream_impl::~extract_packets_from_stream_impl()
    {
    }

    void
    extract_packets_from_stream_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
      for (auto& n : ninput_items_required) {
        n = noutput_items + history() - 1;
      }
    }

    int
    extract_packets_from_stream_impl::general_work (int noutput_items,
                       gr_vector_int &ninput_items,
                       gr_vector_const_void_star &input_items,
                       gr_vector_void_star &output_items)
    {
      const gr_complex *in = (const gr_complex *) input_items[0];
      gr_complex *out = (gr_complex *) output_items[0];

      // Найдём все тэги с ключом @d_tag_key во входном буфере
      std::vector<tag_t>  tags;
      get_tags_in_range( tags, 0, nitems_read(0), nitems_read(0) + ninput_items[0], pmt::mp(d_tag_key) );

      if ( tags.empty() == false ) {

          size_t  i;
          int     nproduce_items = 0; // Обязательно инициализируем
          long    packet_len;
          int     relative_offset;
          for (i = 0; i < tags.size(); ++i) {

              // Тут бы хороша проверка на тип данных в tag.value: мб to_uint64_t
              packet_len = pmt::to_long(tags[i].value);
              relative_offset = tags[i].offset - nitems_read(0);

              if (relative_offset + packet_len > ninput_items[0]) { // Последний пакет не содержится полностью в буфере
                break;

              } else if (nproduce_items + packet_len > noutput_items) { // Если пакет не влезает в выходной буфер (из-за перекрытия пакетов)
                if (i == 0) {
                  throw std::runtime_error( "packet_len > noutput_items (i == 0)" );
                }
                break;

              } else {

                std::memcpy(out + nproduce_items, in + relative_offset, packet_len * sizeof(gr_complex));
                add_item_tag( 0, nitems_written(0) + nproduce_items, pmt::mp(d_tag_key), pmt::mp(packet_len) );
                nproduce_items += packet_len;
              }
          }

          int  nconsume_items;
          if ( i == tags.size() ) { // Обработали все тэги полностью без всяких исключений
              nconsume_items = ninput_items[0];
          } else {
              nconsume_items = tags[i].offset - nitems_read(0);
          }
          consume_each ( nconsume_items );
          return nproduce_items;

      } else { // Входной буфер не содержал никаких тэгов

          consume_each (ninput_items[0]);
          return 0;
      }
    }

  } /* namespace sefdm */
} /* namespace gr */

