#!/usr/bin/python
#
# Preformated CSV from XLS data
#

import subprocess,sys,os,re

try: import xlrd
except:
	print "Error: Importing 'xlrd' failed."
	sys.exit(1)

#--------

SRC = '/home/user/Desktop/PROJEKT/PROJEKT/artax/dokumenty/'
SPORIG = '/home/user/Desktop/PROJEKT/PROJEKT/artax/program/spectra.txt'
SPFILE = '/home/user/Desktop/spectra.txt'
SPECTRA = {}

#--------

print "\nFILE:", SPFILE
print "ORIG:", SPORIG
print "\nGenerating mapping.."

for xls in os.listdir(SRC):
	if 'xls' in xls:
		try:
			book = xlrd.open_workbook(SRC + xls)
			sheet = book.sheet_by_index(0)
			for i in range(1,sheet.nrows):
				tid = re.sub('tabl_(.*)','\\1',sheet.row_values(i)[2])
				SPECTRA[int(tid)] = ('tabl_'
					+ tid + ';'
					+ re.sub(' ','',sheet.row_values(i)[1])
					+'_' + tid + '\r\n')
		except:
			print "Error: Failed to open XLS file: " + xls
#The bad one..
SPECTRA.pop(722)
SPECTRA.pop(775)
SPECTRA.pop(776)

print "Done."

with open(SPFILE,'w') as f:
	for j in SPECTRA:
		f.write(SPECTRA[j])
try:
	subprocess.check_output(['diff', SPFILE, SPORIG], stderr=subprocess.STDOUT)
except subprocess.CalledProcessError as e:
	print e.output

move = raw_input("Update target file? [y/n]: ")

if move == 'y':
	os.rename(SPFILE, SPORIG)
else:
	os.remove(SPFILE)

print "Done."

