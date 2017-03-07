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

buff = StringIO.StringIO()

csv = open('/var/www/color/data.csv','w')
log = open('/var/www/color/color.log','a')

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

	# CGI parse
	form = cgi.FieldStorage(fp=buff, environ=environ, keep_blank_values=True)
	
	if 'file' in form.keys():
		if is_csv(form['file'].value):
			csv.write(form['file'].value)
			log.write('ok\n')


		else: log.write('fail\n')	

	csv.close()
	buff.close()
	log.close()

	status = '200 OK'

	response_headers = [('Content-type', 'text/html'),('Content-Length',str(len(html)))]

	start_response(status, response_headers)

	return [html]
