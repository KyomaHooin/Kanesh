#!/usr/bin/python
# -*- coding: utf-8 -*-

import matplotlib,StringIO,base64,numpy,time,cgi

matplotlib.use('Agg')# no display

from scipy import stats
from matplotlib import pyplot

#---------------------------

html_head = """
<html>
<head><meta charset="utf-8"></head>
<body>
<img src="/media/python-powered.png">
<br><p style="padding-left: 42px;">[ Formát CSV: <b>tablet;element;value;value;..</b> ]</p>
<form style="padding-left: 42px;" enctype="multipart/form-data" action="regress" method="post">
<b>Soubor CSV</b>: <input style="background-color:#ddd;" type="file" name="file"><br><br>
<table>
<tr><td><input type="radio" name="e1" value="Na"></td><td>Na</td><td><input type="radio" name="e2" value="Na"></td><td>Na</td></tr>
<tr><td><input type="radio" name="e1" value="Mg"></td><td>Mg</td><td><input type="radio" name="e2" value="Mg"></td><td>Mg</td></tr>
<tr><td><input type="radio" name="e1" value="Al"></td><td>Al</td><td><input type="radio" name="e2" value="Al"></td><td>Al</td></tr>
<tr><td><input type="radio" name="e1" value="Si"></td><td>Si</td><td><input type="radio" name="e2" value="Si"></td><td>Si</td></tr>
<tr><td><input type="radio" name="e1" value="P"></td><td>P</td><td><input type="radio" name="e2" value="P"></td><td>P</td></tr>
<tr><td><input type="radio" name="e1" value="K"></td><td>K</td><td><input type="radio" name="e2" value="K"></td><td>K</td></tr>
<tr><td><input type="radio" name="e1" value="Ca"></td><td>Ca</td><td><input type="radio" name="e2" value="Ca"></td><td>Ca</td></tr>
<tr><td><input type="radio" name="e1" value="Ti"></td><td>Ti</td><td><input type="radio" name="e2" value="Ti"></td><td>Ti</td></tr>
<tr><td><input type="radio" name="e1" value="Mn"></td><td>Mn</td><td><input type="radio" name="e2" value="Mn"></td><td>Mn</td></tr>
<tr><td><input type="radio" name="e1" value="Fe"></td><td>Fe</td><td><input type="radio" name="e2" value="Fe"></td><td>Fe</td></tr>
</table>
<br>
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

element = ('Na','Mg','Al','Si','P','K','Ca','Ti','Mn','Fe')

#---------------------------

def not_valid_csv(data):
	for line in data.splitlines()[1:]:
		if line.split(';')[1] not in element: return 1
	return 0

def get_data(d):
	dt = []
	for l in d.splitlines(): dt.append(l.split(';'))
	return dt

def get_tablet(d):
	t = [] 
	for i in range(0,len(d)): t.append(d[i][0])
	return numpy.unique(t)

def get_edata(e,t,d):
	ed = []
	for tab in t:
		for i in range(0,len(d)):
			if d[i][0] == tab and d[i][1] == e:
				ed += d[i][2:]
	return ed

def get_tdata(e,t,d):
	et = []
	for i in range(0,len(d)):
		if d[i][0] == t and d[i][1] == e:
			return d[i][2:]

def regress(csv,el1,el2):

	plot_buff = StringIO.StringIO()
	data = get_data(csv)
	tablet = get_tablet(data)
	
	if not data: return '<b>No data.</b>'

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
	#		markersize='7',
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
	
	if 'file' in form.keys():
		if 'e1' and 'e2' not in form.keys():
			html_msg = '<font style="padding-left: 42px;" color="red">Neplatný výběr prvků!</font>'
		elif not_valid_csv(form['file'].value):
			html_msg = '<font style="padding-left: 42px;" color="red">Neplatné CSV.</font>'
		else:
			#regress(form['file'].value.decode('utf-8'),form['e1'].value,form['e2'].value)
			html_msg +=('<img src="data:image/jpeg;base64,'
			+ base64.b64encode(regress(form['file'].value.decode('utf-8'),form['e1'].value,form['e2'].value))
			+ '">')
			#html_msg = regress(form['file'].value.decode('utf-8'),form['e1'].value,form['e2'].value)

	response_headers = [
		('Content-type', 'text/html'),
		('Content-Length',str(len(html_head + html_msg + html_foot)))
	]
	start_response(status, response_headers)
	return [html_head + html_msg + html_foot]

