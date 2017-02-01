#!/usr/bin/python

#no display..
import matplotlib
matplotlib.use('Agg')

import colour
from colour import ILLUMINANTS_RELATIVE_SPDS
from colour.plotting import *
from colour.utilities.verbose import message_box

#D65 = ILLUMINANTS_RELATIVE_SPDS['D65']

CIE_1931_chromaticity_diagram_plot(filename='1931.png',figure_size=(10,6),title='CIE 1931 Chromaticity Diagram')

CIE_1976_UCS_chromaticity_diagram_plot(filename='1976.png',figure_size=(10,6),title='CIE 1976 Chromaticity Diagram')

