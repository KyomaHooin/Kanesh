#!/usr/bin/python
#
# Create Chromaticity diagram and RGB color plot.
#

import matplotlib,numpy,time,sys,os

matplotlib.use('Agg')# no display

from colour.plotting import *
from colour.models import Lab_to_XYZ,XYZ_to_sRGB

#----

logfile = '/var/log/color.log'

runtime = time.strftime("%d.%m.%Y %H:%M")

illuminant = DEFAULT_PLOTTING_ILLUMINANT# D65

#-----

try:# LOG
	log = open(logfile,'a')
except:
	print('Failed to open log file.')
	sys.exit(1)

if len(sys.argv) != 2:
	log.write('Wrong number of arguments. ' + runtime + '\n')
	sys.exit(2)

try:
	os.makedirs(os.getcwd() + '/export')
except: pass

try:# INIT
	csv = open(sys.argv[1],'r')
except:
	log.write('Failed top open data file.')
	sys.exit(3)

#-----

try:# DIAGRAM
	for line in csv.read().splitlines()[1:]:
		ln = line.split(',')

		Lab = numpy.array([float(ln[2]),float(ln[3]),float(ln[4])])

		Lab_sRGB = XYZ_to_sRGB(Lab_to_XYZ(Lab,illuminant),illuminant)

		CIE_1976_UCS_chromaticity_diagram_plot(Lab,\
			filename='export/' + ln[0] + '_1976.png', \
			figure_size=(10,6), \
			title='CIE 1976 Chromaticity Diagram - ' + ln[0] \
		)

		single_colour_plot(ColourParameter(RGB=Lab_sRGB), \
			filename='export/' + ln[0] + '_sRGB.png', \
			figure_size=(4,4), \
			title='Lab to sRGB color - ' + ln[0] \
		)
except:
	log.write('Failed to export data. ' + runtime + '\n')

csv.close()
log.close()

