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


#ifndef INCLUDED_LEARN_MY_ADD_FF_H
#define INCLUDED_LEARN_MY_ADD_FF_H

#include <learn/api.h>
#include <gnuradio/sync_block.h>

namespace gr {
  namespace learn {

    /*!
     * \brief <+description of block+>
     * \ingroup learn
     *
     */
    class LEARN_API my_add_ff : virtual public gr::sync_block
    {
     public:
      typedef boost::shared_ptr<my_add_ff> sptr;

      /*!
       * \brief Return a shared_ptr to a new instance of learn::my_add_ff.
       *
       * To avoid accidental use of raw pointers, learn::my_add_ff's
       * constructor is in a private implementation
       * class. learn::my_add_ff::make is the public interface for
       * creating new instances.
       *
       * \param add_val Set integer value
       */
      //Тут также указываем изменяемые-конфигурируемые из GRC параметры блока
      //с их описанием
      //Пример: add_val
      static sptr make(int add_val);
      
      /*
       * Нужны ли? Нет, необязательны
       */
       /*
      virtual void set_add_val(int add_val) = 0;
      virtual int add_val() = 0;
      */ 
    };

  } // namespace learn
} // namespace gr

#endif /* INCLUDED_LEARN_MY_ADD_FF_H */

