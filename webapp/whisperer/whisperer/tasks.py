import sys
import os
sys.path.append(os.getcwd())

from celery.task import task
from whisperer import Whisperer
import datetime

@task()
def gen_model(algname):
	w = Whisperer()
	if algname in w.get_algnames():
		w.create_model(algname)
		return dict(algname=algname, date=datetime.datetime.now())
	return None
