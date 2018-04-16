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
#include "tag_test_impl.h"

namespace gr {
  namespace learn {

    tag_test::sptr
    tag_test::make(float threshold, int packet_len)
    {
      return gnuradio::get_initial_sptr
        (new tag_test_impl(threshold, packet_len));
    }

    /*
     * The private constructor
     */
    tag_test_impl::tag_test_impl(float threshold, int packet_len)
      : gr::block("tag_test",
              gr::io_signature::make(1, 1, sizeof(float)),
              gr::io_signature::make(1, 1, sizeof(float))),
        d_threshold(threshold),
        d_packet_len(packet_len)
    {

    }

    /*
     * Our virtual destructor.
     */
    tag_test_impl::~tag_test_impl()
    {
    }

    void
    tag_test_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
      for (auto& n : ninput_items_required) {
        n = noutput_items + history() - 1;
      }
    }

    int
    tag_test_impl::general_work (int noutput_items,
                       gr_vector_int &ninput_items,
                       gr_vector_const_void_star &input_items,
                       gr_vector_void_star &output_items)
    {
      const float *in = (const float *) input_items[0];
      float *out = (float *) output_items[0];


      // Вход-выход с номером 0 - есть единый кольцевой буфер!
      // Вход и выход с номер 1 (индекс @input_items/@output_items) - следующий, отдельный кольцевой буфер
      // Но выше написанное не имеет большого значения
      // Тэг ПРИКРЕПЛЯЕТСЯ к элементам ВЫХОДНОГО буфера
      //
      // Во время добавления тэга мы указываем его положение с помощью смещения
      // Но используем НЕ ОТНОСИТЕЛЬНОЕ смещение, а АБСОЛЮТНОЕ
      //
      // Относительно смещение - смещение, характерезующееся только данным вызовом функции work()
      // и оно обычно мб от 0 до noutput_items (максимально возможное кол-во элементов в выходном буфере)
      // Пр. for (int i = 0; i < noutput_items; ++i) {..} <-- используем относительное смещение
      //
      // Абсолютное смещение - смещение, характерещующееся данным и ВСЕМИ прошлыми вызовами функции work(),
      // т.е. системный обработчик помнит сколько всего, за всё время работы данного блока, прошло items
      // через его вход и его выход.
      //
      // nitems_written(...) - сколько всего items прошло на выход (при самом первом вызове функции work()
      // функция вернёт 0, но последующие вызовы produce() или return будут увеличивать и накапливать
      // кол-во выходных items)
      //
      // nitems_read(...) - сколько всего items прошло на вход (данное значение изменяется при каждом
      // вызове consume())
      //
      // Если блок является Synch-блоком, то nitems_written(port_no) == nitems_read(port_no)


      for (int i = 0; i < noutput_items; ++i) {

        // Тэг уже прикреплён к out[i]!
        // Данная строчка мб как до add_item_tag, так и после
        out[i] = in[i];

        // Д О Б А В Л Я Е М   Т Э Г (key + value;)
        // к item значение которого больше d_threshold
        // (тэг прикрепляется к выходному массиву)
        if (in[i] > d_threshold) {

//          add_item_tag(0, // Port number
//                       nitems_written(0) + i, // Offset (абсолютное смещение) // nitems_written(0) - 0 - номер порта
//                       pmt::mp("packet_start"), // Key
//                       pmt::mp("Exceed Detection Threshold") // Value
//          );
//
//          add_item_tag(0, // Port number
//                       nitems_written(0) + i, // Offset (абсолютное смещение) // nitems_written(0) - 0 - номер порта
//                       pmt::mp("abs_offset"), // Key
//                       pmt::mp(nitems_written(0) + i) // Value
//          );
//
//          add_item_tag(0, // Port number
//                       nitems_written(0) + i, // Offset (абсолютное смещение) // nitems_written(0) - 0 - номер порта
//                       pmt::mp("relative_offset"), // Key
//                       pmt::mp(i) // Value
//          );

          add_item_tag(0, // Port number
                       nitems_written(0) + i, // Offset (абсолютное смещение) // nitems_written(0) - 0 - номер порта
                                              // Данная запись верна для Synch-блока, если блок не Synch - то ВНИМАТЕЛЬНЕЕ ДУМАТь
                       pmt::mp("packet_len"), // Key
                       pmt::mp(d_packet_len) // Value
          );
        }


      }


      // Do <+signal processing+>
      // Tell runtime system how many input items we consumed on
      // each input stream.
      consume_each (noutput_items);

      // Tell runtime system how many output items we produced.
      return noutput_items;
    }

  } /* namespace learn */
} /* namespace gr */

