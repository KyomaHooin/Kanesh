#!/usr/bin/python
#
# TODO:
#
# CSV loop
#

import matplotlib
matplotlib.use('Agg')# no display

import numpy as np

from colour.plotting import *
from colour.models import Lab_to_XYZ,XYZ_to_sRGB

#----

tab_name='I 686' 
Lab_L=47.8
Lab_a=11.3
Lab_b=15.4

Lab = np.array([Lab_L, Lab_a, Lab_b])

illuminant=DEFAULT_PLOTTING_ILLUMINANT# D65

Lab_sRGB = XYZ_to_sRGB(Lab_to_XYZ(Lab,illuminant),illuminant)

#----

CIE_1976_UCS_chromaticity_diagram_plot(Lab,\
	filename=tab_name.replace(' ','') + '_1976.png', \
	figure_size=(10,6), \
	title='CIE 1976 Chromaticity Diagram - ' + tab_name, \
	)

single_colour_plot(ColourParameter(RGB=Lab_sRGB), \
	filename=tab_name.replace(' ','') + '_sRGB.png', \
	figure_size=(4,4), \
	title='Lab to sRGB color' \
	)
