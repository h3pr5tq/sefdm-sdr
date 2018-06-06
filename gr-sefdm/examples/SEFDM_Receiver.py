#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: SEFDM Receiver
# Generated: Thu May 17 22:58:05 2018
##################################################

if __name__ == '__main__':
    import ctypes
    import sys
    if sys.platform.startswith('linux'):
        try:
            x11 = ctypes.cdll.LoadLibrary('libX11.so')
            x11.XInitThreads()
        except:
            print "Warning: failed to XInitThreads()"

from PyQt4 import Qt
from PyQt4.QtCore import QObject, pyqtSlot
from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import filter
from gnuradio import gr
from gnuradio import qtgui
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from gnuradio.qtgui import Range, RangeWidget
from optparse import OptionParser
import sefdm
import sip
import sys


class SEFDM_Test(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "SEFDM Receiver")
        Qt.QWidget.__init__(self)
        self.setWindowTitle("SEFDM Receiver")
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except:
            pass
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("GNU Radio", "SEFDM_Test")
        self.restoreGeometry(self.settings.value("geometry").toByteArray())

        ##################################################
        # Variables
        ##################################################
        self.sym_sefdm_len = sym_sefdm_len = 26
        self.sym_fft_size = sym_fft_size = 32
        self.pld_n_sym = pld_n_sym = 20
        self.pld_len_cp = pld_len_cp = 6
        self.hdr_n_sym = hdr_n_sym = 6
        self.hdr_len_cp = hdr_len_cp = 6
        self.sym_n_inf = sym_n_inf = 20
        self.sym_len_right_gi = sym_len_right_gi = 2
        self.sym_len_left_gi = sym_len_left_gi = 3
        self.radio_samp_rate = radio_samp_rate = 4e6
        self.radio_if_gain = radio_if_gain = 40
        self.radio_carrier_freq = radio_carrier_freq = 2290e6
        self.radio_bb_gain = radio_bb_gain = 38
        self.qtTimeSink_num_point = qtTimeSink_num_point = 10000
        self.prmbl_hdr_no_payload_len = prmbl_hdr_no_payload_len = 320 + hdr_n_sym * (sym_fft_size + hdr_len_cp) + (sym_fft_size + hdr_len_cp) + pld_n_sym * (sym_sefdm_len+ pld_len_cp)

        ##################################################
        # Blocks
        ##################################################
        self._radio_samp_rate_options = (4e6, 8e6, 10e6, 16e6, 20e6, )
        self._radio_samp_rate_labels = ('4 MHz', '8 MHz', '10 MHz', '16 MHz', '20 MHz', )
        self._radio_samp_rate_tool_bar = Qt.QToolBar(self)
        self._radio_samp_rate_tool_bar.addWidget(Qt.QLabel('Sample Rate'+": "))
        self._radio_samp_rate_combo_box = Qt.QComboBox()
        self._radio_samp_rate_tool_bar.addWidget(self._radio_samp_rate_combo_box)
        for label in self._radio_samp_rate_labels: self._radio_samp_rate_combo_box.addItem(label)
        self._radio_samp_rate_callback = lambda i: Qt.QMetaObject.invokeMethod(self._radio_samp_rate_combo_box, "setCurrentIndex", Qt.Q_ARG("int", self._radio_samp_rate_options.index(i)))
        self._radio_samp_rate_callback(self.radio_samp_rate)
        self._radio_samp_rate_combo_box.currentIndexChanged.connect(
        	lambda i: self.set_radio_samp_rate(self._radio_samp_rate_options[i]))
        self.top_grid_layout.addWidget(self._radio_samp_rate_tool_bar, 0, 1, 1, 1)
        self._radio_carrier_freq_range = Range(10e6, 2750e6, 1e6, 2290e6, 200)
        self._radio_carrier_freq_win = RangeWidget(self._radio_carrier_freq_range, self.set_radio_carrier_freq, 'Carrier Frequence', "counter_slider", float)
        self.top_grid_layout.addWidget(self._radio_carrier_freq_win, 0, 0, 1, 1)
        self.sefdm_mf_demodulator_0 = sefdm.mf_demodulator(pld_n_sym,
                                     sym_fft_size, sym_sefdm_len, sym_len_right_gi, sym_len_left_gi,
                                     True, True)
        self.sefdm_ieee_802_11a_synchronization_0 = sefdm.ieee_802_11a_synchronization(160,
                                                   True, 15,
                                                   160 + 32 - 20, 40, 32,
                                                   False,
                                                   prmbl_hdr_no_payload_len)
        self.sefdm_ieee_802_11a_preamble_detection_0 = sefdm.ieee_802_11a_preamble_detection(144, 16, 0.6, 60, -20, "packet_len", prmbl_hdr_no_payload_len, 150)
        self.sefdm_id_detector_0 = sefdm.id_detector(3,
                                  pld_n_sym,
                                  sym_fft_size, sym_sefdm_len, sym_len_right_gi, sym_len_left_gi,)
        self.sefdm_header_synchronization_0 = sefdm.header_synchronization(prmbl_hdr_no_payload_len - 320,
                                             hdr_n_sym, hdr_len_cp,
                                             pld_n_sym, pld_len_cp,
                                             sym_fft_size, sym_sefdm_len, sym_len_right_gi, sym_len_left_gi)
        self.sefdm_extract_packets_from_stream_0 = sefdm.extract_packets_from_stream("packet_len")
        self._radio_if_gain_range = Range(0, 40, 8, 40, 200)
        self._radio_if_gain_win = RangeWidget(self._radio_if_gain_range, self.set_radio_if_gain, 'RX LNA (IF) gain', "counter", float)
        self.top_layout.addWidget(self._radio_if_gain_win)
        self._radio_bb_gain_range = Range(0, 62, 2, 38, 200)
        self._radio_bb_gain_win = RangeWidget(self._radio_bb_gain_range, self.set_radio_bb_gain, 'RX VGA (baseband) gain', "counter", float)
        self.top_layout.addWidget(self._radio_bb_gain_win)
        self.qtgui_time_sink_x_1 = qtgui.time_sink_f(
        	qtTimeSink_num_point, #size
        	radio_samp_rate, #samp_rate
        	"Packet Detection Metric", #name
        	1 #number of inputs
        )
        self.qtgui_time_sink_x_1.set_update_time(0.10)
        self.qtgui_time_sink_x_1.set_y_axis(0, 2)
        
        self.qtgui_time_sink_x_1.set_y_label('Amplitude', "")
        
        self.qtgui_time_sink_x_1.enable_tags(-1, True)
        self.qtgui_time_sink_x_1.set_trigger_mode(qtgui.TRIG_MODE_FREE, qtgui.TRIG_SLOPE_POS, 0.0, 0, 0, "")
        self.qtgui_time_sink_x_1.enable_autoscale(False)
        self.qtgui_time_sink_x_1.enable_grid(True)
        self.qtgui_time_sink_x_1.enable_axis_labels(True)
        self.qtgui_time_sink_x_1.enable_control_panel(False)
        
        if not False:
          self.qtgui_time_sink_x_1.disable_legend()
        
        labels = ['', '', '', '', '',
                  '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
                  1, 1, 1, 1, 1]
        colors = ["blue", "red", "green", "black", "cyan",
                  "magenta", "yellow", "dark red", "dark green", "blue"]
        styles = [1, 1, 1, 1, 1,
                  1, 1, 1, 1, 1]
        markers = [-1, -1, -1, -1, -1,
                   -1, -1, -1, -1, -1]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
                  1.0, 1.0, 1.0, 1.0, 1.0]
        
        for i in xrange(1):
            if len(labels[i]) == 0:
                self.qtgui_time_sink_x_1.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_time_sink_x_1.set_line_label(i, labels[i])
            self.qtgui_time_sink_x_1.set_line_width(i, widths[i])
            self.qtgui_time_sink_x_1.set_line_color(i, colors[i])
            self.qtgui_time_sink_x_1.set_line_style(i, styles[i])
            self.qtgui_time_sink_x_1.set_line_marker(i, markers[i])
            self.qtgui_time_sink_x_1.set_line_alpha(i, alphas[i])
        
        self._qtgui_time_sink_x_1_win = sip.wrapinstance(self.qtgui_time_sink_x_1.pyqwidget(), Qt.QWidget)
        self.top_grid_layout.addWidget(self._qtgui_time_sink_x_1_win, 2, 0, 1, 2)
        self.qtgui_time_sink_x_0 = qtgui.time_sink_c(
        	qtTimeSink_num_point, #size
        	radio_samp_rate, #samp_rate
        	"Oscillogram", #name
        	1 #number of inputs
        )
        self.qtgui_time_sink_x_0.set_update_time(0.10)
        self.qtgui_time_sink_x_0.set_y_axis(-1, 1)
        
        self.qtgui_time_sink_x_0.set_y_label('Amplitude', "")
        
        self.qtgui_time_sink_x_0.enable_tags(-1, False)
        self.qtgui_time_sink_x_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, qtgui.TRIG_SLOPE_POS, 0.0, 0, 0, "")
        self.qtgui_time_sink_x_0.enable_autoscale(False)
        self.qtgui_time_sink_x_0.enable_grid(True)
        self.qtgui_time_sink_x_0.enable_axis_labels(True)
        self.qtgui_time_sink_x_0.enable_control_panel(False)
        
        if not True:
          self.qtgui_time_sink_x_0.disable_legend()
        
        labels = ['', '', '', '', '',
                  '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
                  1, 1, 1, 1, 1]
        colors = ["blue", "red", "green", "black", "cyan",
                  "magenta", "yellow", "dark red", "dark green", "blue"]
        styles = [1, 1, 1, 1, 1,
                  1, 1, 1, 1, 1]
        markers = [-1, -1, -1, -1, -1,
                   -1, -1, -1, -1, -1]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
                  1.0, 1.0, 1.0, 1.0, 1.0]
        
        for i in xrange(2*1):
            if len(labels[i]) == 0:
                if(i % 2 == 0):
                    self.qtgui_time_sink_x_0.set_line_label(i, "Re{{Data {0}}}".format(i/2))
                else:
                    self.qtgui_time_sink_x_0.set_line_label(i, "Im{{Data {0}}}".format(i/2))
            else:
                self.qtgui_time_sink_x_0.set_line_label(i, labels[i])
            self.qtgui_time_sink_x_0.set_line_width(i, widths[i])
            self.qtgui_time_sink_x_0.set_line_color(i, colors[i])
            self.qtgui_time_sink_x_0.set_line_style(i, styles[i])
            self.qtgui_time_sink_x_0.set_line_marker(i, markers[i])
            self.qtgui_time_sink_x_0.set_line_alpha(i, alphas[i])
        
        self._qtgui_time_sink_x_0_win = sip.wrapinstance(self.qtgui_time_sink_x_0.pyqwidget(), Qt.QWidget)
        self.top_grid_layout.addWidget(self._qtgui_time_sink_x_0_win, 1, 0, 1, 1)
        self.qtgui_freq_sink_x_0 = qtgui.freq_sink_c(
        	1024, #size
        	firdes.WIN_BLACKMAN_hARRIS, #wintype
        	radio_carrier_freq, #fc
        	radio_samp_rate, #bw
        	"Power Spectral Density", #name
        	1 #number of inputs
        )
        self.qtgui_freq_sink_x_0.set_update_time(0.10)
        self.qtgui_freq_sink_x_0.set_y_axis(-140, 10)
        self.qtgui_freq_sink_x_0.set_y_label('Relative Gain', 'dB')
        self.qtgui_freq_sink_x_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, 0.0, 0, "")
        self.qtgui_freq_sink_x_0.enable_autoscale(False)
        self.qtgui_freq_sink_x_0.enable_grid(True)
        self.qtgui_freq_sink_x_0.set_fft_average(0.2)
        self.qtgui_freq_sink_x_0.enable_axis_labels(True)
        self.qtgui_freq_sink_x_0.enable_control_panel(False)
        
        if not False:
          self.qtgui_freq_sink_x_0.disable_legend()
        
        if "complex" == "float" or "complex" == "msg_float":
          self.qtgui_freq_sink_x_0.set_plot_pos_half(not True)
        
        labels = ['', '', '', '', '',
                  '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
                  1, 1, 1, 1, 1]
        colors = ["blue", "red", "green", "black", "cyan",
                  "magenta", "yellow", "dark red", "dark green", "dark blue"]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
                  1.0, 1.0, 1.0, 1.0, 1.0]
        for i in xrange(1):
            if len(labels[i]) == 0:
                self.qtgui_freq_sink_x_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_freq_sink_x_0.set_line_label(i, labels[i])
            self.qtgui_freq_sink_x_0.set_line_width(i, widths[i])
            self.qtgui_freq_sink_x_0.set_line_color(i, colors[i])
            self.qtgui_freq_sink_x_0.set_line_alpha(i, alphas[i])
        
        self._qtgui_freq_sink_x_0_win = sip.wrapinstance(self.qtgui_freq_sink_x_0.pyqwidget(), Qt.QWidget)
        self.top_grid_layout.addWidget(self._qtgui_freq_sink_x_0_win, 1, 1, 1, 1)
        self.qtgui_const_sink_x_0_1 = qtgui.const_sink_c(
        	1024, #size
        	"After Equalaizer / Phase Freq Comp / ID Detector", #name
        	0 #number of inputs
        )
        self.qtgui_const_sink_x_0_1.set_update_time(0.00010)
        self.qtgui_const_sink_x_0_1.set_y_axis(-2, 2)
        self.qtgui_const_sink_x_0_1.set_x_axis(-2, 2)
        self.qtgui_const_sink_x_0_1.set_trigger_mode(qtgui.TRIG_MODE_FREE, qtgui.TRIG_SLOPE_POS, 0.0, 0, "")
        self.qtgui_const_sink_x_0_1.enable_autoscale(False)
        self.qtgui_const_sink_x_0_1.enable_grid(True)
        self.qtgui_const_sink_x_0_1.enable_axis_labels(True)
        
        if not False:
          self.qtgui_const_sink_x_0_1.disable_legend()
        
        labels = ['', '', '', '', '',
                  '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
                  1, 1, 1, 1, 1]
        colors = ["blue", "red", "red", "red", "red",
                  "red", "red", "red", "red", "red"]
        styles = [0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0]
        markers = [0, 0, 0, 0, 0,
                   0, 0, 0, 0, 0]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
                  1.0, 1.0, 1.0, 1.0, 1.0]
        for i in xrange(1):
            if len(labels[i]) == 0:
                self.qtgui_const_sink_x_0_1.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_const_sink_x_0_1.set_line_label(i, labels[i])
            self.qtgui_const_sink_x_0_1.set_line_width(i, widths[i])
            self.qtgui_const_sink_x_0_1.set_line_color(i, colors[i])
            self.qtgui_const_sink_x_0_1.set_line_style(i, styles[i])
            self.qtgui_const_sink_x_0_1.set_line_marker(i, markers[i])
            self.qtgui_const_sink_x_0_1.set_line_alpha(i, alphas[i])
        
        self._qtgui_const_sink_x_0_1_win = sip.wrapinstance(self.qtgui_const_sink_x_0_1.pyqwidget(), Qt.QWidget)
        self.top_grid_layout.addWidget(self._qtgui_const_sink_x_0_1_win, 3, 1, 1, 1)
        self.qtgui_const_sink_x_0 = qtgui.const_sink_c(
        	1024, #size
        	"After Equalaizer / Phase Freq Comp", #name
        	0 #number of inputs
        )
        self.qtgui_const_sink_x_0.set_update_time(0.00010)
        self.qtgui_const_sink_x_0.set_y_axis(-2, 2)
        self.qtgui_const_sink_x_0.set_x_axis(-2, 2)
        self.qtgui_const_sink_x_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, qtgui.TRIG_SLOPE_POS, 0.0, 0, "")
        self.qtgui_const_sink_x_0.enable_autoscale(False)
        self.qtgui_const_sink_x_0.enable_grid(True)
        self.qtgui_const_sink_x_0.enable_axis_labels(True)
        
        if not False:
          self.qtgui_const_sink_x_0.disable_legend()
        
        labels = ['', '', '', '', '',
                  '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
                  1, 1, 1, 1, 1]
        colors = ["blue", "red", "red", "red", "red",
                  "red", "red", "red", "red", "red"]
        styles = [0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0]
        markers = [0, 0, 0, 0, 0,
                   0, 0, 0, 0, 0]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
                  1.0, 1.0, 1.0, 1.0, 1.0]
        for i in xrange(1):
            if len(labels[i]) == 0:
                self.qtgui_const_sink_x_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_const_sink_x_0.set_line_label(i, labels[i])
            self.qtgui_const_sink_x_0.set_line_width(i, widths[i])
            self.qtgui_const_sink_x_0.set_line_color(i, colors[i])
            self.qtgui_const_sink_x_0.set_line_style(i, styles[i])
            self.qtgui_const_sink_x_0.set_line_marker(i, markers[i])
            self.qtgui_const_sink_x_0.set_line_alpha(i, alphas[i])
        
        self._qtgui_const_sink_x_0_win = sip.wrapinstance(self.qtgui_const_sink_x_0.pyqwidget(), Qt.QWidget)
        self.top_grid_layout.addWidget(self._qtgui_const_sink_x_0_win, 3, 0, 1, 1)
        self.fir_filter_xxx_0 = filter.fir_filter_ccf(1, ([-0.0690, -0.2497, 0.6374, -0.2497, -0.0690]))
        self.fir_filter_xxx_0.declare_sample_delay(0)
        self.blocks_throttle_0 = blocks.throttle(gr.sizeof_gr_complex*1, radio_samp_rate,True)
        self.blocks_tagged_stream_to_pdu_0 = blocks.tagged_stream_to_pdu(blocks.complex_t, "packet_len")
        self.blocks_file_source_0 = blocks.file_source(gr.sizeof_gr_complex*1, '/home/ivan/Documents/Signals/1_rx_sefdm_11.05.18/rx_sefdm__pckt_10000_1000__hdr_6_6__pld_20_6__sym_32_26_20_3_2_bpsk__.dat', False)

        ##################################################
        # Connections
        ##################################################
        self.msg_connect((self.blocks_tagged_stream_to_pdu_0, 'pdus'), (self.sefdm_ieee_802_11a_synchronization_0, 'in'))    
        self.msg_connect((self.sefdm_header_synchronization_0, 'sefdm_hdr_synch_out'), (self.sefdm_mf_demodulator_0, 'mf_demodulator_in'))    
        self.msg_connect((self.sefdm_id_detector_0, 'id_detector_out'), (self.qtgui_const_sink_x_0_1, 'in'))    
        self.msg_connect((self.sefdm_ieee_802_11a_synchronization_0, 'out'), (self.sefdm_header_synchronization_0, 'sefdm_hdr_synch_in'))    
        self.msg_connect((self.sefdm_mf_demodulator_0, 'mf_demodulator_out'), (self.qtgui_const_sink_x_0, 'in'))    
        self.msg_connect((self.sefdm_mf_demodulator_0, 'mf_demodulator_out'), (self.sefdm_id_detector_0, 'id_detector_in'))    
        self.connect((self.blocks_file_source_0, 0), (self.blocks_throttle_0, 0))    
        self.connect((self.blocks_throttle_0, 0), (self.fir_filter_xxx_0, 0))    
        self.connect((self.blocks_throttle_0, 0), (self.sefdm_ieee_802_11a_preamble_detection_0, 0))    
        self.connect((self.fir_filter_xxx_0, 0), (self.sefdm_ieee_802_11a_preamble_detection_0, 1))    
        self.connect((self.sefdm_extract_packets_from_stream_0, 0), (self.blocks_tagged_stream_to_pdu_0, 0))    
        self.connect((self.sefdm_ieee_802_11a_preamble_detection_0, 0), (self.qtgui_freq_sink_x_0, 0))    
        self.connect((self.sefdm_ieee_802_11a_preamble_detection_0, 0), (self.qtgui_time_sink_x_0, 0))    
        self.connect((self.sefdm_ieee_802_11a_preamble_detection_0, 1), (self.qtgui_time_sink_x_1, 0))    
        self.connect((self.sefdm_ieee_802_11a_preamble_detection_0, 0), (self.sefdm_extract_packets_from_stream_0, 0))    

    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "SEFDM_Test")
        self.settings.setValue("geometry", self.saveGeometry())
        event.accept()

    def get_sym_sefdm_len(self):
        return self.sym_sefdm_len

    def set_sym_sefdm_len(self, sym_sefdm_len):
        self.sym_sefdm_len = sym_sefdm_len
        self.set_prmbl_hdr_no_payload_len(320 + self.hdr_n_sym * (self.sym_fft_size + self.hdr_len_cp) + (self.sym_fft_size + self.hdr_len_cp) + self.pld_n_sym * (self.sym_sefdm_len+ self.pld_len_cp))

    def get_sym_fft_size(self):
        return self.sym_fft_size

    def set_sym_fft_size(self, sym_fft_size):
        self.sym_fft_size = sym_fft_size
        self.set_prmbl_hdr_no_payload_len(320 + self.hdr_n_sym * (self.sym_fft_size + self.hdr_len_cp) + (self.sym_fft_size + self.hdr_len_cp) + self.pld_n_sym * (self.sym_sefdm_len+ self.pld_len_cp))

    def get_pld_n_sym(self):
        return self.pld_n_sym

    def set_pld_n_sym(self, pld_n_sym):
        self.pld_n_sym = pld_n_sym
        self.set_prmbl_hdr_no_payload_len(320 + self.hdr_n_sym * (self.sym_fft_size + self.hdr_len_cp) + (self.sym_fft_size + self.hdr_len_cp) + self.pld_n_sym * (self.sym_sefdm_len+ self.pld_len_cp))

    def get_pld_len_cp(self):
        return self.pld_len_cp

    def set_pld_len_cp(self, pld_len_cp):
        self.pld_len_cp = pld_len_cp
        self.set_prmbl_hdr_no_payload_len(320 + self.hdr_n_sym * (self.sym_fft_size + self.hdr_len_cp) + (self.sym_fft_size + self.hdr_len_cp) + self.pld_n_sym * (self.sym_sefdm_len+ self.pld_len_cp))

    def get_hdr_n_sym(self):
        return self.hdr_n_sym

    def set_hdr_n_sym(self, hdr_n_sym):
        self.hdr_n_sym = hdr_n_sym
        self.set_prmbl_hdr_no_payload_len(320 + self.hdr_n_sym * (self.sym_fft_size + self.hdr_len_cp) + (self.sym_fft_size + self.hdr_len_cp) + self.pld_n_sym * (self.sym_sefdm_len+ self.pld_len_cp))

    def get_hdr_len_cp(self):
        return self.hdr_len_cp

    def set_hdr_len_cp(self, hdr_len_cp):
        self.hdr_len_cp = hdr_len_cp
        self.set_prmbl_hdr_no_payload_len(320 + self.hdr_n_sym * (self.sym_fft_size + self.hdr_len_cp) + (self.sym_fft_size + self.hdr_len_cp) + self.pld_n_sym * (self.sym_sefdm_len+ self.pld_len_cp))

    def get_sym_n_inf(self):
        return self.sym_n_inf

    def set_sym_n_inf(self, sym_n_inf):
        self.sym_n_inf = sym_n_inf

    def get_sym_len_right_gi(self):
        return self.sym_len_right_gi

    def set_sym_len_right_gi(self, sym_len_right_gi):
        self.sym_len_right_gi = sym_len_right_gi

    def get_sym_len_left_gi(self):
        return self.sym_len_left_gi

    def set_sym_len_left_gi(self, sym_len_left_gi):
        self.sym_len_left_gi = sym_len_left_gi

    def get_radio_samp_rate(self):
        return self.radio_samp_rate

    def set_radio_samp_rate(self, radio_samp_rate):
        self.radio_samp_rate = radio_samp_rate
        self._radio_samp_rate_callback(self.radio_samp_rate)
        self.qtgui_time_sink_x_1.set_samp_rate(self.radio_samp_rate)
        self.qtgui_time_sink_x_0.set_samp_rate(self.radio_samp_rate)
        self.qtgui_freq_sink_x_0.set_frequency_range(self.radio_carrier_freq, self.radio_samp_rate)
        self.blocks_throttle_0.set_sample_rate(self.radio_samp_rate)

    def get_radio_if_gain(self):
        return self.radio_if_gain

    def set_radio_if_gain(self, radio_if_gain):
        self.radio_if_gain = radio_if_gain

    def get_radio_carrier_freq(self):
        return self.radio_carrier_freq

    def set_radio_carrier_freq(self, radio_carrier_freq):
        self.radio_carrier_freq = radio_carrier_freq
        self.qtgui_freq_sink_x_0.set_frequency_range(self.radio_carrier_freq, self.radio_samp_rate)

    def get_radio_bb_gain(self):
        return self.radio_bb_gain

    def set_radio_bb_gain(self, radio_bb_gain):
        self.radio_bb_gain = radio_bb_gain

    def get_qtTimeSink_num_point(self):
        return self.qtTimeSink_num_point

    def set_qtTimeSink_num_point(self, qtTimeSink_num_point):
        self.qtTimeSink_num_point = qtTimeSink_num_point

    def get_prmbl_hdr_no_payload_len(self):
        return self.prmbl_hdr_no_payload_len

    def set_prmbl_hdr_no_payload_len(self, prmbl_hdr_no_payload_len):
        self.prmbl_hdr_no_payload_len = prmbl_hdr_no_payload_len


def main(top_block_cls=SEFDM_Test, options=None):

    from distutils.version import StrictVersion
    if StrictVersion(Qt.qVersion()) >= StrictVersion("4.5.0"):
        style = gr.prefs().get_string('qtgui', 'style', 'raster')
        Qt.QApplication.setGraphicsSystem(style)
    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls()
    tb.start()
    tb.show()

    def quitting():
        tb.stop()
        tb.wait()
    qapp.connect(qapp, Qt.SIGNAL("aboutToQuit()"), quitting)
    qapp.exec_()


if __name__ == '__main__':
    main()
