#!/usr/bin/python

import matplotlib
matplotlib.use('Agg')# no display

from colour.plotting import *

#

Lab_L=47.8
Lab_a=11.3
Lab_b=15.4

CIE_1976_UCS_chromaticity_diagram_plot(Lab_L, Lab_a, Lab_b,\
	filename='1976.png', \
	figure_size=(10,6), \
	title='CIE 1976 Chromaticity Diagram - Hneda' \
	)

