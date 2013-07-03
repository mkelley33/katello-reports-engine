#!/usr/bin/python
import calendar
import datetime
from datetime import timedelta
import fileinput
from optparse import OptionParser
import os
import random
import sys

unique_systems = 0
parser = OptionParser()
parser.add_option("-u", "--unique-systems-status", dest="unique_systems", help="number of unique systems to create for each status")
parser.add_option("-p", "--path-to-orig", dest="path", help="path to original json file .. orig_marketing_product_usage.json")
(opts, args) = parser.parse_args()

unique_systems = opts.unique_systems
path = opts.path

print("creating " + str(unique_systems) + " unique systems")

mandatories = ['unique_systems']
for m in mandatories:
	if not opts.__dict__[m]:
		print "mandatory option is missing\n"
		parser.print_help()
		exit(-1)
unique_systems = int(unique_systems) + 1

def replaceAll():
	orig = os.path.join(path, "orig_marketing_product_usage.json")
	new = os.path.join(path, "marketing_product_usage.json")
	old_file = open(orig, "r")
	if( os.path.isfile(new)):
		os.remove(new)
	new_file = open(new, "a")
	#old_file_no_breaks = map(lambda line: line.rstrip('\n'), old_file)

	orig_line = ""
	for i, line in enumerate(old_file):
		orig_line = line

		#status_array = ["current", "invalid", "insufficient"]
		for x in range(1, unique_systems):
			r = random.randint(0,2)
			#t = random.randint(0,23)
			delta = timedelta(hours=int(x))
			now = datetime.datetime.now()

			nowish = now + delta

			gotime = calendar.timegm(nowish.timetuple())
			#status = status_array[r]
			ident = "server_ident" + str(i + 1) + str(x)
			print(ident)
			line1 = orig_line.replace("server_ident", ident)
			line2 = line1.replace("sat_id", str(int("1000011111") + (i + 1)  + x))
			line3 = line2.replace("change_time", str(gotime) + "000")
			line4 = line3.replace("replace_name", ident)
			new_file.write(line4)

	old_file.close()
	new_file.close()

replaceAll()
