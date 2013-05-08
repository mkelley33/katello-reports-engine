#!/usr/bin/python
import fileinput
import sys
import random

def replaceAll():
	old_file = open("sample_data", "r")
	new_file = open("sample_data_new", "w")

	orig_line = ""
	for line in old_file:
		orig_line = line

	status_array = ["current", "invalid", "insufficient"]
	for x in range(1,103):
		print(x)
		r = random.randint(0,2)
		print "random" + str(r)
		status = status_array[r]
		line1 = orig_line.replace("server_ident", "server_ident" + str(x))
		line2 = line1.replace("1000011111", str(int("1000011111") + x))
		line3 = line2.replace("invalid", status)
		new_file.write(line3)

	old_file.close()
	new_file.close()

replaceAll()