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

#ifndef INCLUDED_LEARN_MY_ADD_FF_IMPL_H
#define INCLUDED_LEARN_MY_ADD_FF_IMPL_H

#include <learn/my_add_ff.h>

namespace gr {
  namespace learn {

    class my_add_ff_impl : public my_add_ff
    {
     private:
      // Nothing to declare in this block.
      // Непонятно почему только (?)
      const int d_add_val; // задаваемый-передаваемый из GRC параметр блока (второе слагаемое)

     public:
      my_add_ff_impl(int add_val);
      ~my_add_ff_impl();
      
      // Нужны ли? Нет, необязательны
      /*
      void set_add_val(int add_val);
      int add_val();
      */

      // Where all the action really happens
      int work(int noutput_items,
         gr_vector_const_void_star &input_items,
         gr_vector_void_star &output_items);
    };

  } // namespace learn
} // namespace gr

#endif /* INCLUDED_LEARN_MY_ADD_FF_IMPL_H */

