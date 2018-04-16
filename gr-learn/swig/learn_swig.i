/* -*- c++ -*- */

#define LEARN_API

%include "gnuradio.i"			// the common stuff

//load generated python docstrings
%include "learn_swig_doc.i"

%{
#include "learn/my_add_ff.h"
#include "learn/signal_detect.h"
#include "learn/history_test.h"
#include "learn/message_test.h"
#include "learn/tag_test.h"
#include "learn/clip_stream.h"
%}


%include "learn/my_add_ff.h"
GR_SWIG_BLOCK_MAGIC2(learn, my_add_ff);

%include "learn/signal_detect.h"
GR_SWIG_BLOCK_MAGIC2(learn, signal_detect);
%include "learn/history_test.h"
GR_SWIG_BLOCK_MAGIC2(learn, history_test);
%include "learn/message_test.h"
GR_SWIG_BLOCK_MAGIC2(learn, message_test);
%include "learn/tag_test.h"
GR_SWIG_BLOCK_MAGIC2(learn, tag_test);
%include "learn/clip_stream.h"
GR_SWIG_BLOCK_MAGIC2(learn, clip_stream);
