#!/usr/bin/python
import fileinput
import sys
import random
import time
import datetime
from datetime import timedelta

def replaceAll():
	old_file = open("sample_data", "r")
	new_file = open("sample_data_new", "w")

	orig_line = ""
	for line in old_file:
		orig_line = line

	status_array = ["current", "invalid", "insufficient"]
	for x in range(1,103):
		r = random.randint(0,2)
		t = random.randint(0,50)
		print(t)
		delta = timedelta(hours=int(t))
		now = datetime.datetime.now()
		nowish = now - delta
		gotime = int(time.mktime(nowish.timetuple()))
		print(gotime)
		status = status_array[r]
		line1 = orig_line.replace("server_ident", "server_ident" + str(x))
		line2 = line1.replace("1000011111", str(int("1000011111") + x))
		line3 = line2.replace("invalid", status)
		line4 = line3.replace("change_time", str(gotime) + "000")
		new_file.write(line4)

	old_file.close()
	new_file.close()

replaceAll()