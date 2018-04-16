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


#ifndef INCLUDED_LEARN_SIGNAL_DETECT_H
#define INCLUDED_LEARN_SIGNAL_DETECT_H

#include <learn/api.h>
#include <gnuradio/block.h>

namespace gr {
  namespace learn {

    /*!
     * \brief <+description of block+>
     * \ingroup learn
     *
     */
    class LEARN_API signal_detect : virtual public gr::block
    {
     public:
      typedef boost::shared_ptr<signal_detect> sptr;

      /*!
       * \brief Return a shared_ptr to a new instance of learn::signal_detect.
       *
       * To avoid accidental use of raw pointers, learn::signal_detect's
       * constructor is in a private implementation
       * class. learn::signal_detect::make is the public interface for
       * creating new instances.
       *
       * \param summation_window Summation window (L) in autocorrelation and energy calculations
       * \param signal_offset Siganl offset (D) in autocorrelation and energy calculations
       * \param detection_threshold Threshold of signal detection
       */
      static sptr make(int summation_window, int signal_offset, float detection_threshold);
    };

  } // namespace learn
} // namespace gr

#endif /* INCLUDED_LEARN_SIGNAL_DETECT_H */

