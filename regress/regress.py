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

#--------------------------------

f = open('input.csv','r')

data = csv_read(f)

f.close()

tablet = get_tablet()

set1 =[float(x) for x in get_edata('Mg',tablet)]
set2 =[float(x) for x in get_edata('Al',tablet)]

slope, intercept, r_value, p_value, std_err = stats.linregress(set1,set2)

coef = round(stats.pearsonr(set1,set2)[0],2)

print set1
print set2

plt.subplots(figsize=(8,8), facecolor='white')

#point
plt.plot(
	set1,
	set2,
	'o',
	markeredgewidth=1.5,
	markeredgecolor='black',
	markerfacecolor=clr[5],
	markersize='7',
#	label='J3145'
	)

#line
plt.plot(
	numpy.array(set1),
	intercept + slope*numpy.array(set1),
	'black',
	linewidth=2
	)

plt.xlabel('Mg',fontsize=13)
plt.ylabel('Al',fontsize=13)

plt.grid(True)

#plt.xlim(0,1)
#plt.ylim(0,1)

#plt.legend(frameon=False)

#plt.savefig(filename='regress.png', format='png', dpi=300)
plt.show()

