#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Sefdm Test
# Generated: Mon Apr 16 16:13:41 2018
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
import osmosdr
import sefdm
import sip
import sys
import time


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
        self.samp_rate = samp_rate = 10e6
        self.packet_len_with_margin_tag_key = packet_len_with_margin_tag_key = "packet_len"
        self.packet_len = packet_len = 320 + 80 * 20
        self.num_point_on_graph = num_point_on_graph = 29500
        self.carrier_freq = carrier_freq = 450e6

        ##################################################
        # Blocks
        ##################################################
        self.sefdm_ofdm_symbol_demodulation_0 = sefdm.ofdm_symbol_demodulation()
        self.sefdm_ieee_802_11a_preamble_detection_0 = sefdm.ieee_802_11a_preamble_detection(144, 16, 0.3, True, -20, packet_len_with_margin_tag_key, packet_len, 150)
        self.sefdm_ieee_802_11a_coarse_time_synch_0 = sefdm.ieee_802_11a_coarse_time_synch()
        self.sefdm_extract_packets_from_stream_0 = sefdm.extract_packets_from_stream(packet_len_with_margin_tag_key)
        self.qtgui_time_sink_x_1 = qtgui.time_sink_f(
        	num_point_on_graph, #size
        	samp_rate, #samp_rate
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
        self.qtgui_const_sink_x_0 = qtgui.const_sink_c(
        	1024, #size
        	"", #name
        	0 #number of inputs
        )
        self.qtgui_const_sink_x_0.set_update_time(0.010)
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
        self.osmosdr_source_0 = osmosdr.source( args="numchan=" + str(1) + " " + 'hackrf=2359524b' )
        self.osmosdr_source_0.set_sample_rate(samp_rate)
        self.osmosdr_source_0.set_center_freq(carrier_freq, 0)
        self.osmosdr_source_0.set_freq_corr(0, 0)
        self.osmosdr_source_0.set_dc_offset_mode(0, 0)
        self.osmosdr_source_0.set_iq_balance_mode(0, 0)
        self.osmosdr_source_0.set_gain_mode(False, 0)
        self.osmosdr_source_0.set_gain(0, 0)
        self.osmosdr_source_0.set_if_gain(32, 0)
        self.osmosdr_source_0.set_bb_gain(40, 0)
        self.osmosdr_source_0.set_antenna('', 0)
        self.osmosdr_source_0.set_bandwidth(0, 0)
          
        self.fir_filter_xxx_0 = filter.fir_filter_ccf(1, ([-0.0690, -0.2497, 0.6374, -0.2497, -0.0690]))
        self.fir_filter_xxx_0.declare_sample_delay(0)
        self.blocks_tagged_stream_to_pdu_0 = blocks.tagged_stream_to_pdu(blocks.complex_t, packet_len_with_margin_tag_key)
        self.blocks_null_sink_0 = blocks.null_sink(gr.sizeof_float*1)

        ##################################################
        # Connections
        ##################################################
        self.msg_connect((self.blocks_tagged_stream_to_pdu_0, 'pdus'), (self.sefdm_ieee_802_11a_coarse_time_synch_0, 'in'))    
        self.msg_connect((self.sefdm_ieee_802_11a_coarse_time_synch_0, 'out'), (self.sefdm_ofdm_symbol_demodulation_0, 'in2'))    
        self.msg_connect((self.sefdm_ofdm_symbol_demodulation_0, 'out2'), (self.qtgui_const_sink_x_0, 'in'))    
        self.connect((self.fir_filter_xxx_0, 0), (self.sefdm_ieee_802_11a_preamble_detection_0, 1))    
        self.connect((self.osmosdr_source_0, 0), (self.fir_filter_xxx_0, 0))    
        self.connect((self.osmosdr_source_0, 0), (self.sefdm_ieee_802_11a_preamble_detection_0, 0))    
        self.connect((self.sefdm_extract_packets_from_stream_0, 0), (self.blocks_tagged_stream_to_pdu_0, 0))    
        self.connect((self.sefdm_ieee_802_11a_preamble_detection_0, 1), (self.blocks_null_sink_0, 0))    
        self.connect((self.sefdm_ieee_802_11a_preamble_detection_0, 1), (self.qtgui_time_sink_x_1, 0))    
        self.connect((self.sefdm_ieee_802_11a_preamble_detection_0, 0), (self.sefdm_extract_packets_from_stream_0, 0))    

    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "SEFDM_Test")
        self.settings.setValue("geometry", self.saveGeometry())
        event.accept()

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.qtgui_time_sink_x_1.set_samp_rate(self.samp_rate)
        self.osmosdr_source_0.set_sample_rate(self.samp_rate)

    def get_packet_len_with_margin_tag_key(self):
        return self.packet_len_with_margin_tag_key

    def set_packet_len_with_margin_tag_key(self, packet_len_with_margin_tag_key):
        self.packet_len_with_margin_tag_key = packet_len_with_margin_tag_key

    def get_packet_len(self):
        return self.packet_len

    def set_packet_len(self, packet_len):
        self.packet_len = packet_len

    def get_num_point_on_graph(self):
        return self.num_point_on_graph

    def set_num_point_on_graph(self, num_point_on_graph):
        self.num_point_on_graph = num_point_on_graph

    def get_carrier_freq(self):
        return self.carrier_freq

    def set_carrier_freq(self, carrier_freq):
        self.carrier_freq = carrier_freq
        self.osmosdr_source_0.set_center_freq(self.carrier_freq, 0)


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
