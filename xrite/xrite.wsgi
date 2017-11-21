#!/usr/bin/python
# -*- coding: utf-8 -*-

import StringIO,time,cgi,re

#---------------------------

html_head = """
<html>
<head><meta charset="utf-8"></head>
<body>
<img src="/media/python-powered.png">
<br><p style="padding-left: 42px;">[ Formát CSV: <b>QCReport</b> ]</p>
<form style="padding-left: 42px;" enctype="multipart/form-data" action="xrite" method="post">
<b>Soubor CSV</b>: <input style="background-color:#ddd;" type="file" name="file"><br><br>
<input type="submit" value="Export">
</form>
"""

html_foot = """
</body>
</html>
"""

alpha = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

status = '200 OK'

#---------------------------

def is_valid_csv(data):
	for line in data.splitlines():
		if len(line.split(',')) != 33: return 0
	return 1

def parse_csv(f,p):
	std,lst,lstx,avg = [],[],[],[]
	try:
		for ln in f.splitlines()[10:]:# skip header
			line = ln.split(',')
			if line[0] == 'STANDARD': # catch standard
				std = [line[1],float(line[5]),float(line[6]),float(line[7])]
			elif line[0]: # non-empty
				if re.match('^[A-Z]\d+$',line[1]):
					lst.append((line[1][0],
						int(line[1][1:]),
						std[0],
						float(line[17]) + std[1],
						float(line[18]) + std[2],
						float(line[19]) + std[3]
					))
				else:
					lstx.append(line[1] + ';' + std[0] + ';' + ';'.join(line[17:20]) + '\r\n')
		lst.sort()# sort
		lstx.sort()
		p.write('sep=;\n')# sep.
		for a in alpha:
			for i in lst:
				if a == i[0]:
					avg.append(i)# update avg
			if len(avg) > 0:	
				for j in avg:
					p.write(j[0] + str(j[1]) + ';' + ';'.join(map(str,j[2:])) + '\r\n')
				p.write('AVG;;'
					+ str(round(sum(zip(*avg)[3])/len(avg),1)) + ';'
					+ str(round(sum(zip(*avg)[4])/len(avg),1)) + ';'
					+ str(round(sum(zip(*avg)[5])/len(avg),1)) + '\r\n'
				)
			avg = []# clear avg
		for j in lstx: p.write(j)
		return p
	except:
		return '<font style="padding-left: 42px;" color="red">Chyba při zpracování dat.</font>'

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

	payload = StringIO.StringIO()

	if 'file' in form.keys():
		if form['file'].value:
			if is_valid_csv(form['file'].value):
				html_msg = parse_csv(form['file'].value,payload)
				payload.seek(0)
			else:
				html_msg = '<font style="padding-left: 42px;" color="red">Neplatné CSV.</font>'

	if payload.len > 0: # empty payload
		if 'wsgi.file_wrapper' in environ:
			response_headers = [
				('Content-type','application/octet-stream'),
				('Content-Length', str(payload.len)),
				('Content-Disposition', 'attachment; filename=xrite_' + time.strftime("%Y%m%d_%H%M%S") + '.csv')
			]
			start_response(status, response_headers)
			return environ['wsgi.file_wrapper'](payload, 1024)
	else:
		response_headers = [
			('Content-type', 'text/html'),
			('Content-Length',str(len(html_head + html_msg + html_foot)))
		]
		start_response(status, response_headers)
		return [html_head + html_msg + html_foot]

