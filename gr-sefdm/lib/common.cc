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

#include <complex>

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

    std::vector<std::vector<gr_complex>>
    get_idft_matrix(int n_point, float alfa)
    {
        std::vector<std::vector<gr_complex>>  idft_matrix( n_point,
            std::vector<gr_complex>(n_point, gr_complex(0.0f, 0.0f)) );

        for (int k = 0; k < n_point; ++k) {
            for (int n = 0; n < n_point; ++n) {
                idft_matrix[k][n] =
                    gr_complex(1 / sqrt(n_point), 0.0f) *
                    exp( gr_complex(0.0f, 2 * M_PI * alfa * n * k / n_point) );
            }
        }

        return idft_matrix;
    }

    std::vector<std::vector<gr_complex>>
    get_c_matrix(int n_point, float alfa)
    {
        std::vector<std::vector<gr_complex>>  c_matrix( n_point,
            std::vector<gr_complex>(n_point, gr_complex(0.0f, 0.0f)) );

        std::vector<std::vector<gr_complex>>  f_matrix = get_idft_matrix(n_point, alfa);

        // Get F'
        std::vector<std::vector<gr_complex>>  f_transponse_matrix( n_point,
            std::vector<gr_complex>(n_point, gr_complex(0.0f, 0.0f)) );
        for (int r = 0; r < n_point; ++r) {

            for (int c = 0; c < n_point; ++c) {

              f_transponse_matrix[r][c] = conj( f_matrix[c][r] );
            }
        }

        // C = F' * F
        for (int r = 0; r < n_point; ++r) {

            for (int c = 0; c < n_point; ++c) {

                for (int i = 0; i < n_point; ++i) {

                    c_matrix[r][c] += f_transponse_matrix[r][i] * f_matrix[i][c];
                }
            }
        }

        return c_matrix;
    }

    std::vector<std::vector<gr_complex>>
    get_eye_c_matrix(int n_point, float alfa)
    {
        std::vector<std::vector<gr_complex>>  eye_c_matrix = get_c_matrix(n_point, alfa);

        // eye_c = eye - c, where eye - Identity Matrix
        for (int r = 0; r < n_point; ++r) {

            for (int c = 0; c < n_point; ++c) {

                if (r == c) {
                    eye_c_matrix[r][c] = gr_complex(1.0f, 0.0f) - eye_c_matrix[r][c];
                } else {
                    eye_c_matrix[r][c] = gr_complex(0.0f, 0.0f) - eye_c_matrix[r][c];
                }
            }
        }

        return eye_c_matrix;
    }

    common::common()
    {
    }

    common::~common()
    {
    }

  } /* namespace sefdm */
} /* namespace gr */

