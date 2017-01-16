#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# CIE Lab D65 color offset to RGB graph. 
#

import matplotlib
matplotlib.use('Agg')# Anti-Grain Geometry => no X, png only  

import colorpy.illuminants
import colorpy.plots
import colorpy.colormodels

clr = colorpy.colormodels.lab_color(47.8,11.3,15.4)

#47.8,11.3,15.4
#xyz_from_lab

D65 = colorpy.illuminants.get_illuminant_D65()

colorpy.plots.custom_spectrum_plot(D65,
	u'D65 - Standard Hnědá',
	'd65-demo',
	u'Vlnová délka ($nm$)',
	u'Intenzita ($W/m^2$)',
	clr)

