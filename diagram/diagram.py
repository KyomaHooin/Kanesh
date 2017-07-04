#!/usr/bin/python

import ternary,numpy,sys

from matplotlib import pyplot

try:
	f = open('input.csv','r')
except:
	print("Failed to read input.")
	sys.exit(1)

clr = ('#DC143C','#EE1289','#0000FF','#00CDCD','#00C957','#9ACD32','#FFD700','#EE7600','#FF0000')

#---------------------------

def is_csv(fn):
	for line in fn.readlines():
		if len(line.split(';')) != 4: return 0
	return 1

def parse_csv(fn):
	csv=[]
	fn.seek(0)# not required in file buffer
	for line in fn.readlines():
		csv.append(line.strip().split(';'))
	return numpy.array(csv)

def scatter_data(dat,std):
	for s in std:
		tax.scatter(
			dat[dat[:,3] == s,:3].astype(float),
			marker='o',
			edgecolor='black',
			linewidth='1',
			s=50,
			color=clr[list(std).index(s)],
			label=s
		)
	
#---------------------------

#VAR

if is_csv(f):
	data = parse_csv(f)
else:
	print "Invalid input."
	sys.exit(2)

element = data[0,:3]# 1st row no 4th column

std = numpy.unique(data[1:,3])# unique 4th column from 2nd row

#BASE

figure, ax = pyplot.subplots(figsize=(8,8), facecolor='white')
tax = ternary.TernaryAxesSubplot(ax=ax,scale=100)

#GRID

tax.gridlines(color="blue", multiple=5,zorder=-1)
#tax.boundary(linewidth=2)

#TICK

tax.ticks(linewidth=2, multiple=10)
#tax.clear_matplotlib_ticks()

#AXIS

ax.axis('off')

#ARROW

ax = tax.get_axes()
ax.annotate("", xy=(10,30), xytext=(30,65), arrowprops=dict(arrowstyle="->"))
ax.annotate("", xy=(30,-6), xytext=(70,-6), arrowprops=dict(arrowstyle="<-"))
ax.annotate("", xy=(90,30), xytext=(70,65), arrowprops=dict(arrowstyle="<-"))

#LABEL

tax.right_corner_label(element[1] + '[%]', fontsize=20, offset=0.01)
tax.left_corner_label(element[2] + '[%]', fontsize=20, offset=0.01)
tax.top_corner_label(element[0] + '[%]', fontsize=20, offset=0.2)

tax.left_axis_label(element[2] + " [%]", fontsize=12, offset=0.12)
tax.right_axis_label(element[1] + " [%]", fontsize=12, offset=0.12)
tax.bottom_axis_label(element[0] + " [%]", fontsize=12, offset=0)

tax._redraw_labels()

#SCATTER

scatter_data(data,std)

#LEGEND

tax.legend(frameon=False, scatterpoints=1, handletextpad=0, bbox_to_anchor = (1.08, 1.15))

#SAVE/DISPLAY

ternary.plt.subplots_adjust(left=0.08,right=0.9,top=0.85, bottom=0.06)
#ternary.plt.tight_layout()

tax.show()
#tax.savefig(filename='demo.png', format='png',dpi=300)

#CLEANUP

f.close()

