#!/usr/bin/python

import matplotlib,StringIO,numpy,gzip,cgi

matplotlib.use('Agg')# no display

from colour.plotting import *
from colour.models import Lab_to_XYZ,XYZ_to_sRGB

#-------------

html = """
<html>
<head></head>
<body>
<img width="500" src="/media/color.png">
<br>
<form style="padding: 42px;" enctype="multipart/form-data" action="color" method="post">
<b>CSV soubor</b>: <input type="file" name="file"> <input type="submit" value="Export">
</form>
</div>
</body>
</html>
"""
status = '200 OK'

buff = StringIO.StringIO()
zbuff = StringIO.StringIO()

#csv = open('/var/www/color/data.csv','w')
log = open('/var/www/color/color.log','a',)

payload = gzip.GzipFile(fileobj=zbuff,mode='wb')

#-------------

def is_csv(data):
	if not data: return 0
	for line in data.splitlines():
		if len(line.split(';')) != 4: return 0
	return 1

def application(environ, start_response):

	try:
		request_body_size = int(environ.get('CONTENT_LENGTH', 0))
	except ValueError:
		request_body_size = 0

	request_body = environ['wsgi.input'].read(request_body_size)

	if request_body:
		buff.write(request_body)
		buff.seek(0)

	form = cgi.FieldStorage(fp=buff, environ=environ, keep_blank_values=True)

	if 'file' in form.keys():
		if is_csv(form['file'].value):
			payload.write(form['file'].value)
			payload.close()
			#csv.write(form['file'].value)
			#csv.close()

	zbuff.seek(0)# return godamnit
	log.write(str(zbuff.len) + '\n')
	log.close()

	if zbuff.len > 10: # empty GZIP header
		if 'wsgi.file_wrapper' in environ:
			response_headers = [
				('Content-type','application/octet-stream'),
				('Content-Length', str(zbuff.len)),
				('Content-Disposition', 'attachment; filename=demo.gz')
			]
			start_response(status, response_headers)
			return environ['wsgi.file_wrapper'](zbuff, 1024)
	else:
		response_headers = [
			('Content-type', 'text/html'),
			('Content-Length',str(len(html)))
		]
		start_response(status, response_headers)
		return [html]

