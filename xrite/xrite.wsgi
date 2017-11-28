#!/usr/bin/python
# -*- coding: utf-8 -*-

import openpyxl,StringIO,time,cgi,re

from openpyxl.cell import get_column_letter

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

header = ['č. měření','název standardu','ΔL*','Δa*','Δb*','ΔC*','ΔH*']

status = '200 OK'

#---------------------------

def cell_format(sheet,data,coord,color):
	for i in range(1,len(data)+1):
		xy = get_column_letter(i) + str(coord)
		sheet.cell(xy).style.alignment.horizontal = 'center'
		sheet.cell(xy).style.fill.fill_type = 'solid'
		sheet.cell(xy).style.fill.start_color.index = color
		for side in ('top','bottom','left','right'):
			getattr(sheet.cell(xy).style.borders,side).border_style = 'thin'
			getattr(sheet.cell(xy).style.borders,side).color.index = '000000'

def cell_data(sheet,data,coord):
	for i in range(1,len(data)+1):
		sheet.cell(get_column_letter(i) + str(coord)).value = data[i-1]

def is_valid_csv(data):
	for line in data.splitlines():
		if len(line.split(',')) != 33: return 0
	return 1

def csv_to_xlsx(f,p):
	std,data,batch1,batch2,avg = '',[],[],[],[]
	try:
		book = openpyxl.Workbook()
		sheet = book.get_active_sheet()
		coord=1

		for ln in f.splitlines()[10:]:# header
			line = ln.split(',')
			if line[0] == 'STANDARD':# standard
				std = line[1].title()
			elif line[0]: # non-empty
				if re.match('^[A-Z]\d+$',line[1]):# data
					data.append([line[1][0]]+[int(line[1][1:])]+[std]+line[5:8]+line[17:22])
		data.sort()
		cell_data(sheet,header,coord)# header
		cell_format(sheet,header,coord,'dd9d050')
		coord+=1
		for a in alpha:# data
			for i in data:
				if a == i[0]:
					batch1.append([i[0]+str(i[1]),i[2]] + map(float,i[6:11]))# non-sum
					batch2.append([i[0]+str(i[1]),i[2]] + map(float,i[3:6]) + ['',''])# sum
			if len(batch1) > 0:
				avg.append([
					'','',
					str(round(sum(zip(*batch1)[2])/len(batch1),1)),
					str(round(sum(zip(*batch1)[3])/len(batch1),1)),
					str(round(sum(zip(*batch1)[4])/len(batch1),1)),
					str(round(sum(zip(*batch1)[5])/len(batch1),1)),
					str(round(sum(zip(*batch1)[6])/len(batch1),1))
				])
				for b in batch1:
					cell_data(sheet,b,coord)
					cell_format(sheet,b,coord,'aaccccff')
					coord+=1
				batch1 = []
			if len(avg) > 0:
				cell_data(sheet,avg[0],coord)
				cell_format(sheet,avg[0],coord,'ffbb543')
				coord+=1
			if len(batch2) > 0:
				avg.append([
					'','',
					str(round(sum(zip(*batch2)[2])/len(batch2),1)),
					str(round(sum(zip(*batch2)[3])/len(batch2),1)),
					str(round(sum(zip(*batch2)[4])/len(batch2),1)),
					'',''
				])
				for c in batch2:
					cell_data(sheet,c,coord)
					cell_format(sheet,c,coord,'ff92d050')
					coord+=1
				batch2 = []
			if len(avg) > 0:
				cell_data(sheet,avg[1],coord)
				cell_format(sheet,avg[1],coord,'ffbb543')
				coord+=1
			avg = []
		sheet.column_dimensions['B'].width = 15
		book.save(p)
		return '<b>ok</b>'
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
				html_msg = csv_to_xlsx(form['file'].value,payload)
				payload.seek(0)
			else:
				html_msg = '<font style="padding-left: 42px;" color="red">Neplatné CSV.</font>'

	if payload.len > 0: # empty payload
		if 'wsgi.file_wrapper' in environ:
			response_headers = [
				('Content-type','application/octet-stream'),
				('Content-Length', str(payload.len)),
				('Content-Disposition', 'attachment; filename=xrite_' + time.strftime("%Y%m%d_%H%M%S") + '.xlsx')
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

