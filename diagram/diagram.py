#!/usr/bin/python

import StringIO,ternary,numpy,sys

from matplotlib import pyplot

try:
	f = open('input_color.csv','r')
except:
	print("Failed to read input.")
	sys.exit(1)


clr = ('#F3C300','#875692','#F38400','#A1CAF1','#BE0032','#C2B280','#848482','#008856','#E68FAC','#0067A5',
	'#F99379','#604E97','#F6A600','#B3446C','#DCD300','#882D17','#8DB600','#654522','#E25822','#2B3D26')

#---------------------------

def is_valid_csv(fh):
	for line in fh.readlines()[1:]:
		if len(line.split(';')) != 23: return 0
	fh.seek(0)#return
	return 1

def parse_csv(fh):
	s = fh.read().replace(',','.')
	fh.close()
	return numpy.genfromtxt(
			StringIO.StringIO(s),
			delimiter=';',
			autostrip=True,
			dtype=None,
			skip_header=1
		)

def parse_data(data,sel):
	row = numpy.shape(data)[0]
	out = numpy.empty([row - 1,3])
	std = data[1:,-1]

	for i in range(1,row):
		e1 = data[i,data[0,:] == sel[0]].astype(float)
		e2 = data[i,data[0,:] == sel[1]].astype(float)
		e3 = data[i,data[0,:] == sel[2]].astype(float)
		summ = numpy.sum([e1, e2, e3])
		out[i - 1,0] = e1 / summ * 100 
		out[i - 1,1] = e2 / summ * 100 
		out[i - 1,2] = e3 / summ * 100

	return numpy.concatenate((out,std[:,None]),-1)

def scatter_data(data,std):
	for st in std:
		tax.scatter(
			data[data[:,3] == st,:3].astype(float),
			marker='o',
			edgecolor='black',
			linewidth='1',
			s=50,
			color=clr[list(std).index(st)],
			label=st
		)

#---------------------------

#VAR

if is_valid_csv(f):
	raw = parse_csv(f)
else:
	print "Invalid input."
	sys.exit(2)

subset = numpy.delete(raw,1,0)
subset = numpy.delete(subset,0,1)
subset = numpy.delete(subset,0,1)
subset = numpy.delete(subset,range(1,numpy.shape(subset)[1],2),1)# SD

element=('Mg','Al','Fe')

data = parse_data(subset,element)

std = numpy.unique(data[1:,-1])

#BASE

figure, ax = pyplot.subplots(figsize=(8,8), facecolor='white')
tax = ternary.TernaryAxesSubplot(ax=ax, scale=100)

#GRID/BOUNDARY

tax.gridlines(color="blue", multiple=5, zorder=-1)
tax.boundary(linewidth=1.25)

#TICK

tax.ticks(linewidth=2, multiple=10, offset=0.014)

#AXIS

ax.axis('off')

#ARROW

ax.annotate("", xy=(7.5,25), xytext=(25,55), arrowprops=dict(arrowstyle="->"))
ax.annotate("", xy=(30,-6), xytext=(70,-6), arrowprops=dict(arrowstyle="<-"))
ax.annotate("", xy=(92.5,25), xytext=(75,55), arrowprops=dict(arrowstyle="<-"))

#LABEL

tax.right_corner_label(element[0] + '[%]', fontsize=20, offset=0.01)
tax.left_corner_label(element[2] + '[%]', fontsize=20, offset=0.01)
tax.top_corner_label(element[1] + '[%]', fontsize=20, offset=0.2)

tax.left_axis_label(element[2] + " [%]", fontsize=12, offset=0.12)
tax.right_axis_label(element[1] + " [%]", fontsize=12, offset=0.12)
tax.bottom_axis_label(element[0] + " [%]", fontsize=12, offset=0)

tax._redraw_labels()

#SCATTER

scatter_data(data, std)

#LEGEND

tax.legend(frameon=False, scatterpoints=1, handletextpad=0, bbox_to_anchor = (1.08, 1.15))

#SAVE/DISPLAY

ternary.plt.subplots_adjust(left=0.08, right=0.9, top=0.85, bottom=0.06)

tax.show()
#tax.savefig(filename='demo.png', format='png', dpi=300)

