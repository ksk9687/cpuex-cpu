import sys
import re

arr1={}

pat1 = re.compile("^([^\t]*)\t(\\w*)\t(\\w*)$")

for line in open('pattern.txt', 'r'):
	patret=pat1.search(line)
	if patret:
		num = patret.group(1)
		posold = patret.group(2)
		posnew = patret.group(3)
		arr1[posnew] = (num,posold)

pat = re.compile("LOC *= *\\\"?(\\w*)\\\"?")

for line in sys.stdin:
	patret=pat.search(line)
	if patret:
		str = patret.group(1)
		if str in arr1:
			pre  = line[:patret.start(1)]
			post = line[patret.end(1):].rstrip()
			(i,newpos) = arr1[str]
			print pre+newpos+post+" # "+i
		else:
			print line,
	else:
		print line,
