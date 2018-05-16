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

#ifndef INCLUDED_SEFDM_IEEE_802_11A_SYNCHRONIZATION_IMPL_H
#define INCLUDED_SEFDM_IEEE_802_11A_SYNCHRONIZATION_IMPL_H

#include <sefdm/ieee_802_11a_synchronization.h>

namespace gr {
  namespace sefdm {

    class ieee_802_11a_synchronization_impl : public ieee_802_11a_synchronization
    {
     private:

      // Coarse Time Synch Algorithm
      const int  d_cts_segment_len;
      const int  d_cts_summation_window;
      const int  d_cts_signal_offset;

      // Fine Freq Synch Algorithm
      const bool  d_ffs_is_make;
      const int   d_ffs_offset_from_cts;
      const int   d_ffs_summation_window;
      const int   d_ffs_signal_offset;

      // Fine Time Synch Algorithm
      const int  d_fts_offset_from_cts;
      const int  d_fts_segment_len;
      const int  d_fts_etalon_seq_len;

      // Channel Estimaton
      const bool d_channel_est_is_make;

      // Packet Parameters
      const int d_packet_len;

      // Packet Preamble Parameters
      const int  d_prmbl_subcarriers_num;

//      // Packet Payload Parameters
//      const int  d_payload_ofdm_sym_num;
//      const int  d_payload_subcarriers_num;
//      const int  d_payload_gi_len;

      //int  d_prmbl_payload_len;


      void
      in_handler_function(pmt::pmt_t msg);

      inline int
      estimate_coarse_time_offset(const gr_complex* in) const;

      inline float
      estimate_fine_freq_offset(const gr_complex* in, int cts_est) const;

      inline void
      compensate_fine_freq_offset(gr_complex* in, size_t in_len, int cts_est, float ffs_est) const;

      inline int
      estimate_fine_time_offset(const gr_complex* in, int cts_est) const;

      inline std::vector<gr_complex>
      estimate_channel(const gr_complex* in, int fts_est) const;

     public:
      ieee_802_11a_synchronization_impl(int cts_segment_len,
                                        bool ffs_is_make, int ffs_offset_from_cts,
                                        int fts_offset_from_cts, int fts_segment_len, int fts_etalon_seq_len,
                                        bool channel_est_is_make,
                                        int packet_len
//                                        int payload_ofdm_sym_num, int payload_subcarriers_num, int payload_gi_len
                                        );
      ~ieee_802_11a_synchronization_impl();

      // Where all the action really happens
      void forecast (int noutput_items, gr_vector_int &ninput_items_required);

      int general_work(int noutput_items,
           gr_vector_int &ninput_items,
           gr_vector_const_void_star &input_items,
           gr_vector_void_star &output_items);
    };

  } // namespace sefdm
} // namespace gr

#endif /* INCLUDED_SEFDM_IEEE_802_11A_SYNCHRONIZATION_IMPL_H */

