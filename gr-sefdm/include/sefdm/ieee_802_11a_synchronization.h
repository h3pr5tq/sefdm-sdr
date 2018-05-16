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


#ifndef INCLUDED_SEFDM_IEEE_802_11A_SYNCHRONIZATION_H
#define INCLUDED_SEFDM_IEEE_802_11A_SYNCHRONIZATION_H

#include <sefdm/api.h>
#include <gnuradio/block.h>

namespace gr {
  namespace sefdm {

    /*!
     * \brief Using IEEE 802.11a preamble, block makes synchronizations for packet
     * \ingroup sefdm
     *
     * \details
     * Make synchronizations:
     *   1) Coarse Time Synch
     *   2) Fine Freq Synch (optional)
     *   3) Fine Time Synch
     *   4) Get Channel Freq Response
     *   5) Delete Preamble and GI
     */
    class SEFDM_API ieee_802_11a_synchronization : virtual public gr::block
    {
     public:
      typedef boost::shared_ptr<ieee_802_11a_synchronization> sptr;

      /*!
       * \brief Create IEEE 802.11a preamble synchronization block
       *
       * \param cts_segment_len          CTS: Length of the segment on which autocorrelation calculation
       * \param ffs_is_make              FFS: Do or not FFS
       * \param ffs_offset_from_cts      FFS: Offset from CTS estimation for find FFS
       * \param fts_offset_from_cts      FTS: Offset from CTS estimation for find FTS
       * \param fts_segment_len          FTS: Length of the segment on which correlation calculation
       * \param fts_etalon_seq_len       FTS: Length of etalon signal which using for correlation
       * \param channel_est_is_make      Channel Est: Make or not channel estimation
       * \param packet_len               Length of packet in samples (PHY packet)
//       * \param payload_ofdm_sym_num     Payload: number of ofdm/sefdm symbols in packet payload
//       * \param payload_subcarriers_num  Payload: number of subcarriers in ofdm/sefdm symbol of payload
//       * \param payload_gi_len           Payload: number of complex samples in GI of ofdm/sefdm symbol
       */
      static sptr make(int cts_segment_len,
                       bool ffs_is_make, int ffs_offset_from_cts,
                       int fts_offset_from_cts, int fts_segment_len, int fts_etalon_seq_len,
                       bool channel_est_is_make,
                       int packet_len
//                       int payload_ofdm_sym_num, int payload_subcarriers_num, int payload_gi_len
                       );
    };

  } // namespace sefdm
} // namespace gr

#endif /* INCLUDED_SEFDM_IEEE_802_11A_SYNCHRONIZATION_H */

