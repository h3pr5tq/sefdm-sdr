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
#include <sefdm/common.h>

namespace gr {
  namespace sefdm {

    void
    get_inf_subcarrier_number(int sym_sefdm_len, int sym_right_gi_len, int sym_left_gi_len,
                              // out:
                              int& sym_n_inf_subcarr,
                              int& sym_n_right_inf_subcarr,
                              int& sym_n_left_inf_subcarr)
    {
        sym_n_inf_subcarr = sym_sefdm_len - sym_right_gi_len - sym_left_gi_len - 1;

        if (sym_n_inf_subcarr % 2 == 0) {
            sym_n_right_inf_subcarr = sym_n_inf_subcarr / 2;
            sym_n_left_inf_subcarr  = sym_n_right_inf_subcarr;
        } else {
            if (sym_right_gi_len < sym_left_gi_len) {
                sym_n_right_inf_subcarr = sym_n_inf_subcarr / 2 + 1;
            } else {
                sym_n_right_inf_subcarr = sym_n_inf_subcarr / 2;
            }
            sym_n_left_inf_subcarr = sym_n_inf_subcarr - sym_n_right_inf_subcarr;
        }
    }

    int
    get_add_zero_subcarrier_number(int sym_fft_size, int sym_sefdm_len)
    {
        return sym_fft_size - sym_sefdm_len;
    }

    common::common()
    {
    }

    common::~common()
    {
    }

  } /* namespace sefdm */
} /* namespace gr */

