#!/usr/bin/python
# -*- coding: utf-8 -*-

import matplotlib,StringIO,zipfile,numpy,time,cgi

matplotlib.use('Agg')# no display

from colour.plotting import *
from colour.models import Lab_to_XYZ,XYZ_to_sRGB

#-------------

html_head = """
<html>
<head><meta charset="utf-8"></head>
<body>
<img width="500" src="/media/color.png">
<br><p style="padding-left: 42px;">[ Formát CSV: <b>ID;L;a;b</b> ]</p>
<form style="padding-left: 42px;" enctype="multipart/form-data" action="color" method="post">
<b>Soubor CSV</b>: <input style="background-color:#ddd;" type="file" name="file"> <input type="submit" value="Export">
</form>
"""

html_foot = """
</body>
</html>
"""

status = '200 OK'

illuminant = DEFAULT_PLOTTING_ILLUMINANT# D65

#-------------

def plot_data(data,out):
	try:
		Lab_array = []
		img1_buff = StringIO.StringIO()

		for line in data.splitlines():
			img2_buff = StringIO.StringIO()
			ln = line.split(';')

			Lab = numpy.array([float(ln[1]),float(ln[2]),float(ln[3])])
			Lab_array.append(Lab)
			Lab_sRGB = XYZ_to_sRGB(Lab_to_XYZ(Lab,illuminant),illuminant)

			single_colour_plot(
				ColourParameter(RGB=Lab_sRGB), \
				filename=img2_buff, \
				figure_size=(4,4), \
				title='Lab to sRGB color - ' + ln[0]
			)

			out.writestr(ln[0] + '_sRGB.png',img2_buff.getvalue())
			img2_buff.close()
	
		CIE_1976_UCS_chromaticity_diagram_plot(
			Lab_array, \
			filename=img1_buff, \
			figure_size=(6,6), \
			title='CIE 1976 Chromaticity Diagram'
		)

		out.writestr('CIE_1976.png',img1_buff.getvalue())
		img1_buff.close()
	except:
		return '<font style="padding-left: 42px;" color="red">Chyba při generování grafu.</font>'

def is_csv(data):
	for line in data.splitlines():
		if len(line.split(';')) != 4: return 0
	return 1

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
				('Content-Disposition', 'attachment; filename=color_'+time.strftime("%Y%m%d_%H%M%S")+'.zip')
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

