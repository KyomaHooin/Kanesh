#!/usr/bin/python
# -*- coding: utf-8 -*-

import matplotlib

matplotlib.use('Agg')# no display

import StringIO,ternary,zipfile,numpy,time,cgi

from matplotlib import pyplot

#---------------------------

html_head = """
<html>
<head><meta charset="utf-8"></head>
<body>
<img src="/media/python-powered.png">
<br><p style="padding-left: 42px;">[ Formát CSV: <b>Element;Element; .. ;Element;STD</b> ]</p>
<form style="padding-left: 42px;" enctype="multipart/form-data" action="diagram" method="post">
<b>Soubor CSV</b>: <input style="background-color:#ddd;" type="file" name="file"><br><br>
<table>
<tr><td><input type="checkbox" name="Na"></td><td>Na</td><td>- Sodík</td></tr>
<tr><td><input type="checkbox" name="Mg"></td><td>Mg</td><td>- Hořčík</td></tr>
<tr><td><input type="checkbox" name="Al"></td><td>Al</td><td>- Hliník</td></tr>
<tr><td><input type="checkbox" name="Si"></td><td>Si</td><td>- Křemík</td></tr>
<tr><td><input type="checkbox" name="P"></td><td>P</td><td>- Fosfor</td></tr>
<tr><td><input type="checkbox" name="K"></td><td>K</td><td>- Draslík</td></tr>
<tr><td><input type="checkbox" name="Ca"></td><td>Ca</td><td>- Vápník</td></tr>
<tr><td><input type="checkbox" name="Ti"></td><td>Ti</td><td>- Titan</td></tr>
<tr><td><input type="checkbox" name="Mn"></td><td>Mn</td><td>- Mangan</td></tr>
<tr><td><input type="checkbox" name="Fe"></td><td>Fe</td><td>- Železo</td></tr>
</table>
<br>
<input type="submit" value="Export">
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

def plot_data(csv,elm,out):
	try:

		plot_buff = StringIO.StringIO()

		data = numpy.genfromtxt(
				StringIO.StringIO(csv),
				delimiter=';',
				autostrip=True,
				dtype=None
			)

		for e in elm:
			if e not in data[0,:-1]:
				return '<font style="padding-left: 42px;" color="red">CSV neobsahuje všechny prvky!</font>'

		subset = numpy.hstack((
				data[:,data[0,:] == elm[0]],
				data[:,data[0,:] == elm[1]],
				data[:,data[0,:] == elm[2]],
				data[:,[-1]]
			))

		std = numpy.unique(data[1:,-1])

		figure, ax = pyplot.subplots(figsize=(8,8), facecolor='white')
		tax = ternary.TernaryAxesSubplot(ax=ax, scale=100)

		tax.gridlines(color="blue", multiple=5, zorder=-1)
		tax.boundary(linewidth=1.25)

		tax.ticks(linewidth=2, multiple=10, offset=0.014)

		ax.axis('off')

		ax.annotate("", xy=(7.5,25), xytext=(25,55), arrowprops=dict(arrowstyle="->"))
		ax.annotate("", xy=(30,-6), xytext=(70,-6), arrowprops=dict(arrowstyle="<-"))
		ax.annotate("", xy=(92.5,25), xytext=(75,55), arrowprops=dict(arrowstyle="<-"))

		tax.right_corner_label(elm[0] + '[%]', fontsize=20, offset=0.01)
		tax.left_corner_label(elm[2] + '[%]', fontsize=20, offset=0.01)
		tax.top_corner_label(elm[1] + '[%]', fontsize=20, offset=0.2)

		tax.left_axis_label(elm[2] + " [%]", fontsize=12, offset=0.12)
		tax.right_axis_label(elm[1] + " [%]", fontsize=12, offset=0.12)
		tax.bottom_axis_label(elm[0] + " [%]", fontsize=12, offset=0)

		tax._redraw_labels()

		for st in std:
			tax.scatter(
				subset[subset[:,3] == st,:3].astype(float),
				marker='o',
				edgecolor='black',
				linewidth='1',
				s=50,
				color=clr[list(std).index(st)],
				label=st
			)

		tax.legend(frameon=False, scatterpoints=1, handletextpad=0, bbox_to_anchor = (1.08, 1.15))

		ternary.plt.subplots_adjust(left=0.08, right=0.9, top=0.85, bottom=0.06)

		tax.savefig(filename=plot_buff, format='png', dpi=300)

		out.writestr('diagram_' + time.strftime("%Y%m%d_%H%M%S") + '.png', plot_buff.getvalue())
		plot_buff.close()
	except:
		return '<font style="padding-left: 42px;" color="red">Chyba při generování grafu.</font>'

def is_csv(data):
	for line in data.splitlines():
		if len(line.split(';')) < 4: return 0
	return 1

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
	
	zip_buff = StringIO.StringIO()

	checked = []

	for elm in element:
		if elm in form: checked.append(elm)

	if len(checked) > 0 and len(checked) != 3:
		html_msg = '<font style="padding-left: 42px;" color="red">Neplatný výběr prvků!</font>'
	elif len(checked) == 3:
		if 'file' in form.keys():
			if form['file'].value:
				if is_csv(form['file'].value):
					payload = zipfile.ZipFile(zip_buff, mode='a', compression=zipfile.ZIP_DEFLATED)
					html_msg = plot_data(form['file'].value.decode('utf-8'),checked,payload)
					payload.close()
					zip_buff.seek(0)
				else:
					html_msg = '<font style="padding-left: 42px;" color="red">Neplatné CSV.</font>'

	if zip_buff.len > 22: # empty ZIP header
		if 'wsgi.file_wrapper' in environ:
			response_headers = [
				('Content-type','application/octet-stream'),
				('Content-Length', str(zip_buff.len)),
				('Content-Disposition', 'attachment; filename=diagram_'+time.strftime("%Y%m%d_%H%M%S")+'.zip')
			]
			start_response(status, response_headers)
			return environ['wsgi.file_wrapper'](zip_buff, 1024)
	else:
		response_headers = [
			('Content-type', 'text/html'),
			('Content-Length',str(len(html_head + html_msg + html_foot)))
		]
		start_response(status, response_headers)
		return [html_head + html_msg + html_foot]

