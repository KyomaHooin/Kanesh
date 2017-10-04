#!/usr/bin/python

import numpy

from scipy import stats

import matplotlib.pyplot as plt

f = open('input.csv','r')

data = numpy.genfromtxt(
	f,
	delimiter=';',
	autostrip=True,
	dtype=None,
	skip_header=1
)

f.close()

slope, intercept, r_value, p_value, std_err = stats.linregress(data)

coef = round(stats.pearsonr(data[:,0],data[:,1])[0],2)

plt.subplots(figsize=(8,8), facecolor='white')

#point
plt.plot(
	data[:,0],
	data[:,1],
	'o',
	markeredgewidth=1.5,
	markeredgecolor='black',
	markerfacecolor='yellow',
	markersize='7',
	label='J3145'
	)

#line
plt.plot(
	data[:,0],
	intercept + slope*data[:,0],
	'#123456',
	)

plt.xlabel('Os',fontsize=13)
plt.ylabel('Re',fontsize=13)

plt.grid(True)

plt.xlim(0,1)
plt.ylim(0,1)

plt.legend(frameon=False)

plt.savefig(filename='regress.png', format='png', dpi=300)
#plt.show()

