import sys
import os
here = os.path.abspath(os.path.dirname(__file__))
sys.path.append(here)

from celery.task import task
from whisperer import Whisperer
import datetime

#goshawk@earth:~/Projects/whisperer/webapp/whisperer$ PYTHONPATH=/usr/local/lib/python2.7/dist-packages/whisperer-0.0-py2.7.egg/whisperer/:$PYTHONPATH celeryd --loglevel=INFO


@task()
def gen_model(algname):
	w = Whisperer()
	if algname in w.get_algnames():
		w.create_model(algname)
		return dict(algname=algname, date=datetime.datetime.now())
	return None
