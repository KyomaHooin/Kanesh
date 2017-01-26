#!/usr/bin/python

import matplotlib
matplotlib.use('Agg')

import colour
from colour import ILLUMINANTS_RELATIVE_SPDS
from colour.plotting import *
from colour.utilities.verbose import message_box

#colour.plotting.DEFAULT_FIGURE_WIDTH = 5

#message_box('Plotting "CIE 1931 Chromaticity Diagram".')
#CIE_1931_chromaticity_diagram_plot()

#A = ILLUMINANTS_RELATIVE_SPDS['A']
#D65 = ILLUMINANTS_RELATIVE_SPDS['D65']

#CIE_1931_chromaticity_diagram_plot(filename='test.png',figure_size=(10,5))

#colour.plotting.common.DEFAULT_FONT_SIZE=5

CIE_1931_chromaticity_diagram_plot(filename='test.png',figure_size=(10,6),title='CIE 1931 Chromaticity Diagram')

