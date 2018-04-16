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
#include "message_test_impl.h"

namespace gr {
  namespace learn {

    message_test::sptr
    message_test::make()
    {
      return gnuradio::get_initial_sptr
        (new message_test_impl());
    }

    /*
     * The private constructor
     * Внутри констурктора определяем кол-во входных/выходных портов под message
     */
    message_test_impl::message_test_impl()
      : gr::block("message_test",
              gr::io_signature::make(0, 1, sizeof(float)),
              gr::io_signature::make(0, 1, sizeof(float)))
    {
      // Задаём порты данного блока
      // @in_port_name_ID и @out_port_name_ID не просто имена портов,
      // но и ИДЕНТИФИКАТОРЫ, которые используются этим и другими блоками
      // при отправки и приёме сообщений! Должны быть уникальными!
      message_port_register_in(pmt::mp("in_port_name_ID"));
      message_port_register_out(pmt::mp("out_port_name_ID"));

      // Указываем имя handler-функции для обработки сообщение данного порта
      // Handler-функция имеет стандартный шаблон (возвращает void  и принимает pmt_t)
      set_msg_handler( pmt::mp("in_port_name_ID"),
                       boost::bind(&message_test_impl::in_port_name_ID_handler_function, this, _1) );



      //void message_port_pub(pmt::pmt_t port_id,
       //pmt::pmt_t msg);

      // Задаём на какие порты подписан данный блок
      // (если на этом порте будет сообщение, то данный блок примет это сообщение)
      //void message_port_sub(pmt::mp("sub_port_ID"),
      // pmt::pmt_t target);

    }

    /*
     * Our virtual destructor.
     */
    message_test_impl::~message_test_impl()
    {
    }

    void
    message_test_impl::forecast (int noutput_items, gr_vector_int &ninput_items_required)
    {
      /* <+forecast+> e.g. ninput_items_required[0] = noutput_items */
      for (auto& n : ninput_items_required) {
        n = noutput_items + history() - 1;
      }
    }

    int
    message_test_impl::general_work (int noutput_items,
                       gr_vector_int &ninput_items,
                       gr_vector_const_void_star &input_items,
                       gr_vector_void_star &output_items)
    {
      const float *in = (const float *) input_items[0];
      float *out = (float *) output_items[0];

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
    // Пусть msg - это pmt Symbols
    void
    message_test_impl::in_port_name_ID_handler_function(pmt::pmt_t msg)
    {
      using std::cout;
      using std::endl;

      std::cout << std::endl;
      std::cout << std::endl;
      std::cout << "Enter to in_port_name_ID_handler_function() --> Receive message!" << std::endl;
      std::cout << "Is PMT Symbols? :" << pmt::is_symbol(msg) << std::endl;

      if (pmt::is_symbol(msg)) {
        std::cout << "Out message :" << pmt::symbol_to_string(msg) << std::endl;

        // Обработаем сообщение и отправим следующему блоку:
        // (в данном случае на выход данного блока)
        std::cout << "Send message" << std::endl;
        std::cout << std::endl;
        std::cout << std::endl;
        message_port_pub(pmt::mp("out_port_name_ID"), msg);

      }


      if (pmt::is_c32vector(msg) == true) {

        size_t in_len;
        const std::complex<float>  *in = c32vector_elements(msg, in_len);

        cout << "vector len: " << in_len << endl;
        for (int i = 0; i < in_len; ++i) {
          cout << in[i] << ' ';
        }
        cout << endl;

      }


    }

  } /* namespace learn */
} /* namespace gr */

