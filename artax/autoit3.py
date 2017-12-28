#!/usr/bin/python
#
# AutoIt3 linux wrapper
#

import subprocess,argparse,os,re

BASE='/root/.wine/drive_c/Program Files (x86)/AutoIt3/'
COMPILER='Aut2Exe/Aut2exe.exe'
RUNNER='AutoIt3.exe'
WINE='/usr/bin/wine'

#--------------

parser = argparse.ArgumentParser()
parser.add_argument("SRC")
parser.add_argument("-c",action='store_true',default=False)
parser.add_argument("-i","--ICO")
args = parser.parse_args()

#--------------

if not os.path.isfile(args.SRC):
	print "Error: No such file."
elif args.c:
	try:
		if args.ICO: 
			subprocess.check_output([
				WINE,
				BASE + COMPILER,
				'/in',args.SRC,
				'/out',re.sub('au3','exe',os.path.basename(args.SRC)),
				'/icon', args.ICO,
				'/nopack',
				'/x86',
				'/gui'],
				stderr=subprocess.STDOUT
			)
		else:
			subprocess.check_output([
				WINE,
				BASE + COMPILER,
				'/in',args.SRC,
				'/out',re.sub('au3','exe',os.path.basename(args.SRC)),
				'/nopack',
				'/x86',
				'/gui'],
				stderr=subprocess.STDOUT
			)
	except: pass
else:
	try:
		subprocess.check_output([WINE,BASE + RUNNER,args.SRC],stderr=subprocess.STDOUT)
	except: pass

