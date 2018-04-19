#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Sefdm Test
# Generated: Thu Apr 19 13:20:34 2018
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
from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import filter
from gnuradio import gr
from gnuradio import qtgui
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from optparse import OptionParser
import sefdm
import sip
import sys


class SEFDM_Test(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "Sefdm Test")
        Qt.QWidget.__init__(self)
        self.setWindowTitle("Sefdm Test")
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
        self.payload_sym_num = payload_sym_num = 20
        self.payload_subcarr_num = payload_subcarr_num = 64
        self.payload_gi_len = payload_gi_len = 16
        self.radio_samp_rate = radio_samp_rate = 10e6
        self.radio_carrier_freq = radio_carrier_freq = 450e6
        self.qtTimeSink_num_point = qtTimeSink_num_point = 29500
        self.prmbl_payload_len = prmbl_payload_len = 320 + payload_sym_num * (payload_subcarr_num + payload_gi_len)

        ##################################################
        # Blocks
        ##################################################
        self.sefdm_ieee_802_11a_synchronization_0 = sefdm.ieee_802_11a_synchronization(160,
                                                   True, 15,
                                                   160 + 32 - 20, 40, 32,
                                                   payload_sym_num, payload_subcarr_num, payload_gi_len)
        self.sefdm_ieee_802_11a_preamble_detection_0 = sefdm.ieee_802_11a_preamble_detection(144, 16, 0.6, True, -20, "packet_len", prmbl_payload_len, 150)
        self.sefdm_ieee_802_11a_ofdm_symbol_demodulation_0 = sefdm.ieee_802_11a_ofdm_symbol_demodulation(payload_sym_num, payload_subcarr_num)
        self.sefdm_extract_packets_from_stream_0 = sefdm.extract_packets_from_stream("packet_len")
        self.qtgui_time_sink_x_1 = qtgui.time_sink_f(
        	qtTimeSink_num_point, #size
        	radio_samp_rate, #samp_rate
        	"", #name
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
        
        if not True:
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
        self.top_layout.addWidget(self._qtgui_time_sink_x_1_win)
        self.qtgui_time_sink_x_0 = qtgui.time_sink_c(
        	qtTimeSink_num_point, #size
        	radio_samp_rate, #samp_rate
        	"", #name
        	1 #number of inputs
        )
        self.qtgui_time_sink_x_0.set_update_time(0.10)
        self.qtgui_time_sink_x_0.set_y_axis(-1, 1)
        
        self.qtgui_time_sink_x_0.set_y_label('Amplitude', "")
        
        self.qtgui_time_sink_x_0.enable_tags(-1, True)
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
        self.top_layout.addWidget(self._qtgui_time_sink_x_0_win)
        self.qtgui_const_sink_x_0 = qtgui.const_sink_c(
        	1024, #size
        	"", #name
        	0 #number of inputs
        )
        self.qtgui_const_sink_x_0.set_update_time(0.00010)
        self.qtgui_const_sink_x_0.set_y_axis(-2, 2)
        self.qtgui_const_sink_x_0.set_x_axis(-2, 2)
        self.qtgui_const_sink_x_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, qtgui.TRIG_SLOPE_POS, 0.0, 0, "")
        self.qtgui_const_sink_x_0.enable_autoscale(False)
        self.qtgui_const_sink_x_0.enable_grid(True)
        self.qtgui_const_sink_x_0.enable_axis_labels(True)
        
        if not True:
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
        self.top_layout.addWidget(self._qtgui_const_sink_x_0_win)
        self.fir_filter_xxx_0 = filter.fir_filter_ccf(1, ([-0.0690, -0.2497, 0.6374, -0.2497, -0.0690]))
        self.fir_filter_xxx_0.declare_sample_delay(0)
        self.blocks_throttle_0 = blocks.throttle(gr.sizeof_gr_complex*1, radio_samp_rate,True)
        self.blocks_tagged_stream_to_pdu_0 = blocks.tagged_stream_to_pdu(blocks.complex_t, "packet_len")
        self.blocks_file_source_0 = blocks.file_source(gr.sizeof_gr_complex*1, '/home/ivan/Documents/Diplom/Signals/RxBaseband_Truncate_ComlexFloat32_bin/rx_tr_randi_20ofdm_20000pckt_15.dat', False)

        ##################################################
        # Connections
        ##################################################
        self.msg_connect((self.blocks_tagged_stream_to_pdu_0, 'pdus'), (self.sefdm_ieee_802_11a_synchronization_0, 'in'))    
        self.msg_connect((self.sefdm_ieee_802_11a_ofdm_symbol_demodulation_0, 'out2'), (self.qtgui_const_sink_x_0, 'in'))    
        self.msg_connect((self.sefdm_ieee_802_11a_synchronization_0, 'out'), (self.sefdm_ieee_802_11a_ofdm_symbol_demodulation_0, 'in2'))    
        self.connect((self.blocks_file_source_0, 0), (self.blocks_throttle_0, 0))    
        self.connect((self.blocks_throttle_0, 0), (self.fir_filter_xxx_0, 0))    
        self.connect((self.blocks_throttle_0, 0), (self.sefdm_ieee_802_11a_preamble_detection_0, 0))    
        self.connect((self.fir_filter_xxx_0, 0), (self.sefdm_ieee_802_11a_preamble_detection_0, 1))    
        self.connect((self.sefdm_extract_packets_from_stream_0, 0), (self.blocks_tagged_stream_to_pdu_0, 0))    
        self.connect((self.sefdm_ieee_802_11a_preamble_detection_0, 0), (self.qtgui_time_sink_x_0, 0))    
        self.connect((self.sefdm_ieee_802_11a_preamble_detection_0, 1), (self.qtgui_time_sink_x_1, 0))    
        self.connect((self.sefdm_ieee_802_11a_preamble_detection_0, 0), (self.sefdm_extract_packets_from_stream_0, 0))    

    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "SEFDM_Test")
        self.settings.setValue("geometry", self.saveGeometry())
        event.accept()

    def get_payload_sym_num(self):
        return self.payload_sym_num

    def set_payload_sym_num(self, payload_sym_num):
        self.payload_sym_num = payload_sym_num
        self.set_prmbl_payload_len(320 + self.payload_sym_num * (self.payload_subcarr_num + self.payload_gi_len))

    def get_payload_subcarr_num(self):
        return self.payload_subcarr_num

    def set_payload_subcarr_num(self, payload_subcarr_num):
        self.payload_subcarr_num = payload_subcarr_num
        self.set_prmbl_payload_len(320 + self.payload_sym_num * (self.payload_subcarr_num + self.payload_gi_len))

    def get_payload_gi_len(self):
        return self.payload_gi_len

    def set_payload_gi_len(self, payload_gi_len):
        self.payload_gi_len = payload_gi_len
        self.set_prmbl_payload_len(320 + self.payload_sym_num * (self.payload_subcarr_num + self.payload_gi_len))

    def get_radio_samp_rate(self):
        return self.radio_samp_rate

    def set_radio_samp_rate(self, radio_samp_rate):
        self.radio_samp_rate = radio_samp_rate
        self.qtgui_time_sink_x_1.set_samp_rate(self.radio_samp_rate)
        self.qtgui_time_sink_x_0.set_samp_rate(self.radio_samp_rate)
        self.blocks_throttle_0.set_sample_rate(self.radio_samp_rate)

    def get_radio_carrier_freq(self):
        return self.radio_carrier_freq

    def set_radio_carrier_freq(self, radio_carrier_freq):
        self.radio_carrier_freq = radio_carrier_freq

    def get_qtTimeSink_num_point(self):
        return self.qtTimeSink_num_point

    def set_qtTimeSink_num_point(self, qtTimeSink_num_point):
        self.qtTimeSink_num_point = qtTimeSink_num_point

    def get_prmbl_payload_len(self):
        return self.prmbl_payload_len

    def set_prmbl_payload_len(self, prmbl_payload_len):
        self.prmbl_payload_len = prmbl_payload_len


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
