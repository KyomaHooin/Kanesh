#!/usr/bin/python
# -*- coding: utf-8 -*-

import matplotlib,StringIO,base64,numpy,time,cgi

matplotlib.use('Agg')# no display

from scipy import stats
from matplotlib import pyplot
from itertools import combinations

#---------------------------

html_head = """
<html>
<head><meta charset="utf-8"></head>
<body>
<img src="/media/python-powered.png">
<br><p style="padding-left: 42px;">[ Formát CSV: <b>tablet;element;value;value;..</b> ]</p>
<form style="padding-left: 42px;" enctype="multipart/form-data" action="regress" method="post">
<b>Soubor CSV</b>: <input style="background-color:#ddd;" type="file" name="file">
<input style="width:7em;" placeholder="min. coef." type="number" name="coef" step="0.1" min="0" max="1"><br><br>
"""

html_body= """
<input type="submit" value="Plot">
</form>
"""

html_foot = """
</body>
</html>
"""

status = '200 OK'

clr = ('#F3C300','#875692','#F38400','#A1CAF1','#BE0032','#C2B280','#848482','#008856','#E68FAC','#0067A5',
	'#F99379','#604E97','#F6A600','#B3446C','#DCD300','#882D17','#8DB600','#654522','#E25822','#2B3D26')

ramfile = '/var/www/regress/ram/data'

#---------------------------

def not_valid_csv(d):
	try:
		for line in d.splitlines()[1:]:
			if len(line.split(';')) < 4: return 1
	except: return 1

def get_data(d):
	dt = []
	for l in d.splitlines(): dt.append(l.split(';'))
	return dt

def get_tablet(d):
	t = [] 
	for i in range(0,len(d)): t.append(d[i][0])
	return numpy.unique(t)

def get_element(d):
	e = []
	for i in range(0,len(d)): e.append(d[i][1])
	return numpy.unique(e)

def get_edata(e,t,d):
	ed = []
	for tab in t:
		for i in range(0,len(d)):
			if d[i][0] == tab and d[i][1] == e:
				ed += filter(None,d[i][2:])
	return ed

def get_tdata(e,t,d):
	et = []
	for i in range(0,len(d)):
		if d[i][0] == t and d[i][1] == e:
			return filter(None,d[i][2:])

def get_break(l):
	for i in range(1,int(numpy.sqrt(l))+2):
		if i ** 2 >= l: return i

def get_c_plot(d,c,c1,c2):
	plot_buff = StringIO.StringIO()
	tab= get_tablet(d)

	set1 = [float(x) for x in get_edata(c1,tab,d)]
	set2 = [float(y) for y in get_edata(c2,tab,d)]

	coef = round(stats.pearsonr(set1,set2)[0],2)

	if abs(coef) >= float(c):
		slope, intercept, r_value, p_value, std_err = stats.linregress(set1,set2)
	
		pyplot.subplots(figsize=(3,3), facecolor='white')

		for t in tab:
			t_set1 = [float(x) for x in get_tdata(c1,t,d)]
			t_set2 = [float(x) for x in get_tdata(c2,t,d)]
			
			pyplot.plot(
				numpy.array(t_set1),
				numpy.array(t_set2),
				'o',
				markeredgewidth=1,
				markeredgecolor='black',
				markerfacecolor=clr[list(tab).index(t)],
			)

		pyplot.plot(
			numpy.array(set1),
			intercept + slope*numpy.array(set1),
			'black',
			linewidth=1
		)

		pyplot.xlabel(c1,fontsize=13)
		pyplot.ylabel(c2,fontsize=13)
		pyplot.grid(True)
		pyplot.title(coef, fontsize=17)
		pyplot.subplots_adjust(bottom=0.2,left=0.2)
		pyplot.savefig(filename=plot_buff, format='jpg',bbox_inches='tight')
		pyplot.close()

		plot_buff.seek(0)
		out = plot_buff.getvalue()
		plot_buff.close()
		
		return base64.b64encode(out)
	return ''
	
def regress(data,el1,el2):

	plot_buff = StringIO.StringIO()
	tablet = get_tablet(data)

	set1 = [float(x) for x in get_edata(el1,tablet,data)]
	set2 = [float(x) for x in get_edata(el2,tablet,data)]

	slope, intercept, r_value, p_value, std_err = stats.linregress(set1,set2)

	coef = round(stats.pearsonr(set1,set2)[0],2)

	pyplot.subplots(figsize=(8,7), facecolor='white')

	for t in tablet:
		t_set1 = [float(x) for x in get_tdata(el1,t,data)]
		t_set2 = [float(x) for x in get_tdata(el2,t,data)]

		pyplot.plot(
			numpy.array(t_set1),
			numpy.array(t_set2),
			'o',
			markeredgewidth=1.5,
			markeredgecolor='black',
			markerfacecolor=clr[list(tablet).index(t)],
			label=t
		)

	pyplot.plot(
		numpy.array(set1),
		intercept + slope*numpy.array(set1),
		'black',
		linewidth=1.5
	)

	pyplot.xlabel(el1,fontsize=13)
	pyplot.ylabel(el2,fontsize=13)
	pyplot.grid(True)
	pyplot.title(coef, fontsize=20)
	pyplot.subplots_adjust( left=0.1,right=0.8)
	pyplot.legend(frameon=False, numpoints=1, loc='center left',handletextpad=0, bbox_to_anchor=(1,0.5))
	pyplot.savefig(filename=plot_buff, format='jpg')
	pyplot.close()

	plot_buff.seek(0)
	out = plot_buff.getvalue()
	plot_buff.close()
	
	return out

#---------------------------

def application(environ, start_response):
	try:
		request_body_size = int(environ.get('CONTENT_LENGTH', 0))
	except ValueError:
		request_body_size = 0

	request_body = environ['wsgi.input'].read(request_body_size)

	body_buff = StringIO.StringIO()

	if request_body:
		body_buff.write(request_body)
		body_buff.seek(0)

	form = cgi.FieldStorage(fp=body_buff, environ=environ, keep_blank_values=True)

	html_msg = ''
	html_elm = ''

	if 'file' in form.keys():
		if form['file'].value:
			with open(ramfile,'w') as f:
				f.write(form['file'].value)
	try:
		with open(ramfile,'r') as f: csv = f.read()
	except: csv = ''
	
	if 'coef' in form.keys(): coef = form['coef'].value
	else: coef = ''

	if csv:
		if not_valid_csv(csv):
			html_msg = '<font style="padding-left: 42px;" color="red">Neplatné CSV.</font>'
		else:
			data = get_data(csv)
			element = get_element(data)
			if not coef:
				html_elm = '<table>'
				for e in element:
					html_elm+= ('<tr><td><input type="radio" name="e1" value="'
						+ e + '"></td><td>'
						+ e + '</td><td><input type="radio" name="e2" value="'
						+ e + '"></td><td>'
						+ e + '</td></tr>')
				html_elm += '</table><br>'
			if coef:
				c_all = []
				for c in combinations(element,2):
					cp = get_c_plot(data,coef,c[0],c[1])
					if cp: c_all.append(cp)
				brk  = get_break(len(c_all))
				for j in range(0,len(c_all)):
					html_msg +=('<img src="data:image/jpeg;base64,' + c_all[j] + '">')
					if (j + 1) % brk == 0: html_msg += '<br>'
			elif 'e1' and 'e2' in form.keys():
				html_msg +=('<img src="data:image/jpeg;base64,'
					+ base64.b64encode(regress(data, form['e1'].value, form['e2'].value))
					+ '">')

	response_headers = [
		('Content-type', 'text/html'),
		('Content-Length',str(len(html_head + html_elm + html_body + html_msg + html_foot)))
	]
	start_response(status, response_headers)
	return [html_head + html_elm + html_body + html_msg + html_foot]

