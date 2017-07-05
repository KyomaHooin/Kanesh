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
<br><p style="padding-left: 42px;">[ Formát CSV: <b>Element;Element;Element;STD</b> ]</p>
<form style="padding-left: 42px;" enctype="multipart/form-data" action="diagram" method="post">
<b>Soubor CSV</b>: <input style="background-color:#ddd;" type="file" name="file"> <input type="submit" value="Export">
</form>
"""

html_foot = """
</body>
</html>
"""

status = '200 OK'

clr = ('#DC143C','#EE1289','#0000FF','#00CDCD','#00C957','#9ACD32','#FFD700','#EE7600','#FF0000')

#---------------------------

def plot_data(csv,out):
	try:

		plot_buff = StringIO.StringIO()

		data = numpy.genfromtxt(
				StringIO.StringIO(csv),
				delimiter=';',
				autostrip=True,
				dtype=None
			)

		element = data[0,:3]# 1st row no 4th column
		std = numpy.unique(data[1:,3])# unique 4th column from 2nd row

		figure, ax = pyplot.subplots(figsize=(8,8), facecolor='white')
		tax = ternary.TernaryAxesSubplot(ax=ax,scale=100)

		tax.gridlines(color="blue", multiple=5,zorder=-1)

		tax.ticks(linewidth=2, multiple=10)

		ax.axis('off')

		ax.annotate("", xy=(7.5,25), xytext=(25,55), arrowprops=dict(arrowstyle="->"))
		ax.annotate("", xy=(30,-6), xytext=(70,-6), arrowprops=dict(arrowstyle="<-"))
		ax.annotate("", xy=(92.5,25), xytext=(75,55), arrowprops=dict(arrowstyle="<-"))

		tax.right_corner_label(element[0] + '[%]', fontsize=20, offset=0.01)
		tax.left_corner_label(element[2] + '[%]', fontsize=20, offset=0.01)
		tax.top_corner_label(element[1] + '[%]', fontsize=20, offset=0.2)

		tax.left_axis_label(element[2] + " [%]", fontsize=12, offset=0.12)
		tax.right_axis_label(element[1] + " [%]", fontsize=12, offset=0.12)
		tax.bottom_axis_label(element[0] + " [%]", fontsize=12, offset=0)

		tax._redraw_labels()

		for s in std:
			tax.scatter(
				data[data[:,3] == s,:3].astype(float),
				marker='o',
				edgecolor='black',
				linewidth='1',
				s=50,
				color=clr[list(std).index(s)],
				label=s
			)

		tax.legend(frameon=False, scatterpoints=1, handletextpad=0, bbox_to_anchor = (1.08, 1.15))

		ternary.plt.subplots_adjust(left=0.08,right=0.9,top=0.85, bottom=0.06)

		tax.savefig(filename=plot_buff, format='png',dpi=300)

		out.writestr('diagram_' + time.strftime("%Y%m%d_%H%M%S") + '.png', plot_buff.getvalue())
		plot_buff.close()
	except:
		return '<font style="padding-left: 42px;" color="red">Chyba při generování grafu.</font>'

def is_csv(data):
	for line in data.splitlines():
		if len(line.split(';')) != 4: return 0
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

	if 'file' in form.keys():
		if form['file'].value:
			if is_csv(form['file'].value):
				payload = zipfile.ZipFile(zip_buff, mode='a', compression=zipfile.ZIP_DEFLATED)
				html_msg = plot_data(form['file'].value.decode('utf-8'),payload)
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

