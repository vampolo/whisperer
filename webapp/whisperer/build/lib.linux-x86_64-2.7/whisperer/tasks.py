import sys
import os
here = os.path.abspath(os.path.dirname(__file__))
sys.path.append(here)

from celery.task import task
from whisperer import Whisperer
import datetime

"""
goshawk@whisperer:~/whisperer/webapp/whisperer$ PATH=/usr/local/MATLAB/R2011a/bin/:$PATH LD_LIBRARY_PATH=/usr/local/MATLAB/R2011a/bin/glnxa64/:$LD_LIBRARY_PATH PYTHONPATH=/usr/local/lib/python2.7/dist-packages/whisperer-0.0-py2.7.egg/whisperer/:$PYTHONPATH celeryd --loglevel=INFO
"""

@task()
def gen_model(algname):
	w = Whisperer()
	if algname in w.get_algnames():
		w.create_model(algname)
		return dict(algname=algname, date=datetime.datetime.now())
	return None
