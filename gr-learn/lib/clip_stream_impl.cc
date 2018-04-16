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
#include "clip_stream_impl.h"

namespace gr {
  namespace learn {


    void
    print_float_val(const float* buf, int buf_len)
    {
      for (int i = 0; i < buf_len - 1; ++i) {
        std::cout << buf[i] << ' ';
      }
      std::cout << buf[buf_len - 1] << std::endl;
    }

    clip_stream::sptr
    clip_stream::make(const std::string& tag_key, int packet_len)
    {
      return gnuradio::get_initial_sptr
        (new clip_stream_impl(tag_key, packet_len));
    }

    /*
     * The private constructor
     */
    clip_stream_impl::clip_stream_impl(const std::string& tag_key, int packet_len)
      : gr::block("clip_stream",
              gr::io_signature::make(1, 1, sizeof(float)),
              gr::io_signature::make(1, 1, sizeof(float))),
        d_tag_key(tag_key),
        d_packet_len(packet_len)
    {
      set_tag_propagation_policy(TPP_DONT);
    }

    /*
     * Our virtual destructor.
     */
    clip_stream_impl::~clip_stream_impl()
    {
    }

    void
    clip_stream_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
      for (auto& n : ninput_items_required) {
        n = noutput_items + history() - 1;
      }
    }

    int
    clip_stream_impl::general_work (int noutput_items,
                       gr_vector_int &ninput_items,
                       gr_vector_const_void_star &input_items,
                       gr_vector_void_star &output_items)
    {
      const float *in = (const float *) input_items[0];
      float *out = (float *) output_items[0];

      std::cout << "\n\nEnter to work()" << std::endl;
      std::cout << "noutput_items: " << noutput_items << std::endl;
      std::cout << "ninput_items[0]: "  << ninput_items[0] << std::endl;
      std::cout << "in: " << std::endl;
      print_float_val(in, ninput_items[0]);

      // Do <+signal processing+>
      std::vector<tag_t>  tags;

      // Найдём все тэги с ключом @d_tag_key во входном буфере
      get_tags_in_range(
          tags, // Tags will be saved here
          0, // Port 0
          nitems_read(0), // Start of range
          nitems_read(0) + ninput_items[0], // End of range // <== переберём все элементы во входном буфере!
          pmt::mp(d_tag_key) // Optional: Only find tags with key @d_tag_key
      );

      if ( tags.empty() == false ) {

        size_t  i;
        int nproduce_items = 0; // ОБЯЗАТЕЛЬНО ИНИЦИАЛИЗИРУЕМ!
        long packet_len;
        int relative_offset;
        for (i = 0; i < tags.size(); ++i) {

          // Тут бы хороша проверка на тип данных в tag.value
          packet_len = pmt::to_long(tags[i].value);
          // или to_uint64_t

          // Проверка если во входном буфере packet_len item'ов чтобы их скопирвоат на выход
          // если нет, то надо их взять из следующего вызова данной функции --> реализация конечного автомата
          // Или лучше их просто не потреблять (consume) и обработать при следующем вызове <-- так даже лучше будет
          // Но для начала реализовать просто, что откидываем этот пакет

          // Offset - есть абсолютное значение и оно утверждено-определено для определённого порта
          // Самый первый item (при первом вызове функции work()) который передаётся через блок иммет Offset==0,
          // второй item - смещение Offset == 1 и т.д.
          // При втором вызове функции work() абсолютное смещение будет уже указываться с помощью
          // nitems_written() и nitems_read()!
          // Подробнее см. комментарии в tag_test_impl.cc

          // ???
          // Мб придётся самому удалть старый tag и вставлять в выходной буфер новый tag
          relative_offset = tags[i].offset - nitems_read(0);

          if (relative_offset + packet_len > ninput_items[0]) { // последний пакет не влезает понлостью в буфер

            std::cout << "i == " << i << "; packet не влез в input_buf --> обработка в следующем вызове work()" << std::endl;
            break;

          } else if (nproduce_items + packet_len > noutput_items) { // если пакет не влезает в выходной буфер
                                                                    // (пакеты могут перекрываться и кол-во items
                                                                    //  в выходном буфере может оказаться больше чем в входном)

            std::cout << "i == " << i << "; packet не влез в OUTPUT_buf --> обработка в следующем вызове work()" << std::endl;
            if (i == 0) {
              // Исключение и завершение программы
              throw std::runtime_error( "packet_len > noutput_items (i == 0)" );
            }
            break;

          } else {

            std::memcpy(out + nproduce_items, in + relative_offset, packet_len * sizeof(float)); // ТУТ ТИП ITEM НУЖНО ВЕРНЫЙ

            add_item_tag(0, // Port number
                         nitems_written(0) + nproduce_items, // Offset (абсолютное смещение) // nitems_written(0) - 0 - номер порта
                                                // Данная запись верна для Synch-блока, если блок не Synch - то ВНИМАТЕЛЬНЕЕ ДУМАТь
                         pmt::mp(d_tag_key), // Key
                         pmt::mp(packet_len) // Value
            );

            nproduce_items += packet_len;
          }

        }

        // Если все пакеты влези во входной буфер
//        long last_packet_len = pmt::to_long(tags[tags.size() - 1].value);
//        int  nconsume_item = tags[tags.size() - 1].offset - nitems_read(0) + last_packet_len;
        // i != 0
        int  nconsume_items;
        if ( i == tags.size() ) { // обработали все тэги полностью без всяких исключений связанных
                                  // с переполнением буферов
          nconsume_items = ninput_items[0];

//        } else if (i != 0) {
//
////          // Верно если пакеты не пересекаются (и то можно оптимизировать)
////          long last_write_packet_len = pmt::to_long( tags[i - 1].value );
////          nconsume_items = tags[i - 1].offset - nitems_read(0) + last_write_packet_len;
//
//          nconsume_items = tags[i].offset - nitems_read(0);

          // Но если пакеты пересекаются то надо подругому сделать

        } else { // если i == 0
          nconsume_items = tags[i].offset - nitems_read(0);
        }

        consume_each ( nconsume_items );
        return nproduce_items; // Tell runtime system how many output items we produced

      } else { // не нашли в буфере ничего с тэгами

        consume_each (ninput_items[0]); // noutput_items == ninput_items[0]
        return 0; // Tell runtime system how many output items we produced. - на выход ничего не пишем
      }

    }



  } /* namespace learn */
} /* namespace gr */

