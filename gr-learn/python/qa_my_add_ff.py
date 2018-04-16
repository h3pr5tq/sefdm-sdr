#!/usr/bin/env python
# -*- coding: utf-8 -*-
# 
# Copyright 2018 <+YOU OR YOUR COMPANY+>.
# 
# This is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
# 
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this software; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street,
# Boston, MA 02110-1301, USA.
# 

from gnuradio import gr, gr_unittest
from gnuradio import blocks
import learn_swig as learn

class qa_my_add_ff (gr_unittest.TestCase):

    def setUp (self):
        self.tb = gr.top_block ()

    def tearDown (self):
        self.tb = None

    def test_001_t (self):

        # Сюда вставляем код для тестирования

        src_data = (1, 2, 3, 4, 5, 5) # входные данные
        add_val = 5; # что прибавляем
        expected_result = (6, 8, 11, 14, 17, 19) # ожидаемые выходные данные

        # set up fg

        # Создадим просто flow-graph
        # Используемые блоки
        src = blocks.vector_source_f(src_data)
        add = learn.my_add_ff(add_val)
        dst = blocks.vector_sink_f()

        # Соединяем
        self.tb.connect(src, add)
        self.tb.connect(add, dst)

        # Запускаем
        self.tb.run ()

        # check data
        result_data = dst.data()
        self.assertFloatTuplesAlmostEqual(expected_result, result_data, 6)


if __name__ == '__main__':
    gr_unittest.run(qa_my_add_ff, "qa_my_add_ff.xml")
