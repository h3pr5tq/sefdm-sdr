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


#ifndef INCLUDED_SEFDM_HEADER_SYNCHRONIZATION_H
#define INCLUDED_SEFDM_HEADER_SYNCHRONIZATION_H

#include <sefdm/api.h>
#include <gnuradio/block.h>

namespace gr {
  namespace sefdm {

    /*!
     * \brief <+description of block+>
     * \ingroup sefdm
     *
     */
    class SEFDM_API header_synchronization : virtual public gr::block
    {
     public:
      typedef boost::shared_ptr<header_synchronization> sptr;

      /*!
       * \brief Return a shared_ptr to a new instance of sefdm::header_synchronization.
       *
       * To avoid accidental use of raw pointers, sefdm::header_synchronization's
       * constructor is in a private implementation
       * class. sefdm::header_synchronization::make is the public interface for
       * creating new instances.
       */
      static sptr make(int hdr_no_pld_len,
                       int hdr_n_sym, int hdr_len_cp,
                       int pld_n_sym, int pld_len_cp,
                       int sym_fft_size, int sym_sefdm_len, int sym_len_right_gi, int sym_len_left_gi);
    };

  } // namespace sefdm
} // namespace gr

#endif /* INCLUDED_SEFDM_HEADER_SYNCHRONIZATION_H */

