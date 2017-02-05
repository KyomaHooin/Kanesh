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
from colour.models import (Lab_to_XYZ,XYZ_to_sRGB)

#

tab_name='I 686' 
Lab_L=47.8
Lab_a=11.3
Lab_b=15.4

CIE_1976_UCS_chromaticity_diagram_plot(Lab_L, Lab_a, Lab_b,\
	filename=tab_name.replace(' ','') + '_1976.png', \
	figure_size=(10,6), \
	title='CIE 1976 Chromaticity Diagram - ' + tab_name, \
	)

#RGB = (0.32315746, 0.32983556, 0.33640183)

#Lab = np.array([Lab_L, Lab_a, Lab_b])
#Lab_sRGB =XYZ_to_sRGB(Lab_to_XYZ(Lab))

#print Lab_sRGB

#single_colour_plot(ColourParameter(Lab_sRGB), \
#	filename='color.png', \
#	figure_size=(10,6), \
#	title='Lab to sRGB color' \
#	)
