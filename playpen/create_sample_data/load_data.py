#!/usr/bin/python

from mongoengine.connection import connect
from mongoengine import connection, register_connection
from optparse import OptionParser
from pymongo import Connection
from subprocess import call, PIPE
import os

drop = False
parser = OptionParser()
parser.add_option("-d", "--drop", action="store_true", dest="drop", help="drop mpu collection")
parser.add_option("-p", "--path-to-orig", dest="path", help="path to original json file .. orig_marketing_product_usage.json")
(opts, args) = parser.parse_args()
drop = opts.drop
path = opts.path
print(drop)

DUMP_DIR = path

def setup_database():
    # Disconnect from the default mongo db, and use a test db instead.
    
    conn = Connection()
    checkin_service = conn["checkin_service"]
    results = conn["results"]
      
    for collection in ['splice_server', 'marketing_product_usage']:
        if drop:
          print('DROPPING')
          checkin_service.drop_collection(collection)
        print 'importing %s collection' % collection
        call(['mongoimport', '--db', 'checkin_service', '-c', collection, '--file', 
              '%s.json' % os.path.join(DUMP_DIR, collection)]
              )
    """    
    for collection in ['marketing_report_data']:
            results.drop_collection(collection)
            print 'importing %s collection' % collection
            call(['mongoimport', '--db', 'results', '-c', collection, '--file', 
                  '%s.json' % os.path.join(DUMP_DIR, collection)]
                  ) 
    """

            
    conn.disconnect()

    


setup_database()
