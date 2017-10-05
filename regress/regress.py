#!/usr/bin/python

import numpy

from scipy import stats

import matplotlib.pyplot as plt

#--------------------------------

clr = ('#F3C300','#875692','#F38400','#A1CAF1','#BE0032','#C2B280','#848482','#008856','#E68FAC','#0067A5',
	'#F99379','#604E97','#F6A600','#B3446C','#DCD300','#882D17','#8DB600','#654522','#E25822','#2B3D26')

element = ('Na','Mg','Al','Si','P','K','Ca','Ti','Mn','Fe')

#--------------------------------

def csv_read(f):
	d = []
	for l in f: d.append(l.split(';'))
	return d

def get_tablet():
	t = [] 
	for i in range(0,len(data)): t.append(data[i][0])
	return numpy.unique(t)

def get_edata(e,tab):
	ed = []
	for t in tab:
		for i in range(0,len(data)):
			if data[i][0] == t and data[i][1] == e:
				ed += data[i][2:]
	return ed

def get_tdata(e,tab):
	et = []
	for i in range(0,len(data)):
		if data[i][0] == tab and data[i][1] == e:
				return data[i][2:]

#--------------------------------

f = open('input.csv','r')

data = csv_read(f)

f.close()

tablet = get_tablet()

set1 = [float(x) for x in get_edata('Mg',tablet)]
set2 = [float(x) for x in get_edata('Al',tablet)]

slope, intercept, r_value, p_value, std_err = stats.linregress(set1,set2)

coef = round(stats.pearsonr(set1,set2)[0],2)

plt.subplots(figsize=(8,7), facecolor='white')

for t in tablet:
	t_set1 = [float(x) for x in get_tdata('Mg',t)]
	t_set2 = [float(x) for x in get_tdata('Al',t)]
 
	plt.plot(
		numpy.array(t_set1),
		numpy.array(t_set2),
		'o',
		markeredgewidth=1.5,
		markeredgecolor='black',
		markerfacecolor=clr[list(tablet).index(t)],
	markersize='7',
	label=t
	)

#line
plt.plot(
	numpy.array(set1),
	intercept + slope*numpy.array(set1),
	'black',
	linewidth=1.5
	)

plt.xlabel('Mg',fontsize=13)
plt.ylabel('Al',fontsize=13)

plt.grid(True)

plt.title(coef, fontsize=20)

plt.subplots_adjust( left=0.1,right=0.8)

plt.legend(frameon=False, numpoints=1, loc='center left',bbox_to_anchor=(1,0.5))

plt.savefig(filename='regress.png', format='png', dpi=300)
#plt.show()

