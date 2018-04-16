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
#include "my_add_ff_impl.h"
#include <iostream>

namespace gr {
  namespace learn {

    // Тут также указываем изменяемые из GRC параметры блока
    my_add_ff::sptr
    my_add_ff::make(int add_val)
    {
      return gnuradio::get_initial_sptr
        (new my_add_ff_impl(add_val));
    }

    /*
     * The private constructor
     */
    /*
     * Как минимум, должны задать кол-во входных/выходных портов
     * и тип данных, которые они принимают/отправляют (item)
     *
     * В качестве аргументов должен принимать изменяемые из GRC параметры блока,
     * например @add_val, которая присваивается privata data member класса
     * @d_add_val
     *
     * В конструкторе также указываем: используем ли мы "историю" (d_history,
     * по-умолчанию d_history == 1)
     * History гарантирует, что во входном буфере, например, input_items[0]
     * будет последних k-1 items из input_items[0] прошлого вызова метода work(...).
     * Несмотря даже на cosume(...) // d_history == k
     * Т.е. при d_history == k входной буфер будет содержать N + k - 1 items,
     * где k - 1 items это последние items из прошлого вызова функции
     */
    my_add_ff_impl::my_add_ff_impl(int add_val)
      : gr::sync_block("my_add_ff",
              //gr::io_signature::make(<+MIN_IN+>, <+MAX_IN+>, sizeof(<+ITYPE+>)),
              //gr::io_signature::make(<+MIN_OUT+>, <+MAX_OUT+>, sizeof(<+OTYPE+>)))
              // Если 2 порта:
              //gr::io_signature::make2(2, 2, sizeof(gr_complex), sizeof(gr_complex))
              gr::io_signature::make(1, 1, sizeof(float)),
              gr::io_signature::make(1, 1, sizeof(float))),
        d_add_val(add_val) // эквивалентно d_add_val = add_val внутри тела конструктора
    {
    	set_history(3);
    }

    /*
     * Our virtual destructor.
     */
    my_add_ff_impl::~my_add_ff_impl()
    {
    }
    
    // Нужны ли? Нет, необязательны
    /*
    int
    my_add_ff_impl::add_val()
    {
      return d_add_val;
    }

    void
    my_add_ff_impl::set_add_val(int add_val)
    {
      d_add_val = add_val;
    }
    */
    
    /*
     * Основной метод, который содержит алгоритм обработки данного блок
     *
     * Данный блок является Sync-блоком!
     * Для Sync-блока @noutput_items is the length in items of all input and output buffers
     *
     * Возвращает число items действительно записанных в каждый выходной порт
     * (return value <= noutput_items)
     * или -1
     */
    int
    my_add_ff_impl::work(int noutput_items, // кол-во доступеых выходных item в каждом выходном буфере
                                            // Т.е. определяет максимальные размер выходных буферов
                                            // (кол-во выходных буферов определяется числом выходным портов)
                                            // !!! (кол-во ВХОДНЫХ item соответсвует noutput_items --ВРОДЕ БЫ НЕТ если используется history!!!)
                                            // Т.е. noutput_items не определяет размер входного буфера!!!!
        gr_vector_const_void_star &input_items, // вектор указателей на буферы с входными items
        gr_vector_void_star &output_items) // вектор указателей на буферы с выходными items
    {
      //const <+ITYPE+> *in = (const <+ITYPE+> *) input_items[0];
      //<+OTYPE+> *out = (<+OTYPE+> *) output_items[0];
      const float *in = (const float *) input_items[0]; // указатель на ПЕРВЫЙ входной буфер/stream
                                                        // Если используем history, то будет указывать на первый элемент
                                                        // с учётом истории!!!
      float *out = (float *) output_items[0]; // указатель на ПЕРВЫЙ выходной буфер/stream

      std::cout << "Enter to work()" << std::endl;

      // Do <+signal processing+>
      // noutput_items - максимальный размер выходного буфера
      // мы можем записать на выход до noutput_items элементов
      // i - index по выходному буферу
      // history == 3 --> 2 значения старых --> входной буфер содержит N + history() - 1, в нашем случае N == noutput_items
      for (int j = history() - 1, i = 0;
           i < noutput_items;
           ++i, ++j) {

        out[i] = in[j] + in[j - 1] + in[j - 2] + d_add_val;
//        std::cout << out[i] << std::endl;
      }

//      for (int i = 0; i < noutput_items; i++) {
//          out[i] = 0;
//          for (int k = 0; k < history(); k++) {
//              out[i] += in[i+k];
//          }
//      }


      // Tell runtime system how many output items we produced.
      // Можем на выход записать меньше, чем noutput_items, но
      // в нашем случае используется sync-блок, которые гарантирует
      // что consumed input item == noutput_items и соотношение 1:1
      return noutput_items;
    }

    /*
     * Необходимый метод для внутреннего gnu radio scheduler
     * Сообщает, как много входных item требуется, чтобы
     * получить noutput_items выходных item
     *
     * По-умолчанию предполагается, что кол-во элементов во входных буферах
     * равняется кол-во элементов во выходных буферах (@noutput_items)
     * Но с помощью данного методы мы можем изменить поведение по-умолчанию
     *
     * Данный метод для Sync-блока не нужен!!!
     *
     * ВАЖНО!: forecast задаёт границу снизу для размера входного буфера!
     * Вообще ninput_items[0] м.б. больше чем noutput_items!
     * Поэтому используем цикл вида for (int i = 0; i < NOUTPUT_ITEMS; ++i) { out[i] ... }
     */
    /*
    void
    my_add_ff_impl::forecast(int noutput_items, gr_vector_int &ninput_items_required)
    {
      // Для первого входного порта:
      // чтобы получить @noutput_items items на выходном порту,
      // необходимо @ninput_items_required[0] items на входном порту
      ninput_items_required[0] = noutput_items;

      // Для второго входного порта (если есть):
      //ninput_items_required[1] = noutput_items;
    }
    */

  } /* namespace learn */
} /* namespace gr */

