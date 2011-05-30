from pymatlab.matlab import MatlabSession
import numpy 
from models import User, Item, Rating, Metadata, DBSession
import os
import functools

ALGOPATH='../../algoritms'

def clean(f):
	@functools.wraps(f)
	def wrapper(self, *args, **kwds):
		self._clean()
		res = f(self, *args, **kwds)
		self._clean()
		return res
	return wrapper

class Whisperer(object):
	def __init__(self):
		self.m = MatlabSession('matlab -nosplash -nodisplay')
		print "addpath(genpath('"+os.path.abspath(ALGOPATH)+"'))"
		self.m.run("addpath(genpath('"+os.path.abspath(ALGOPATH)+"'))")
		self.db = DBSession()
	
	def _put(self, name, value):
		self.m.put(name, value)
	
	def _get(self, name):
		return self.m.get(name)
	
	def _clean(self):
		self.m.run("clear")
		
	def create_urm(self, users=None, items=None, ratings=None):
		"""Return the user rating matrix"""
		if not users:
			users = self.db.query(User).all()
		if not items:
			items = self.db.query(Item).all()
		if not ratings:
			ratings = self.db.query(Rating).all()
		
		urm = numpy.zeros((len(users),len(items)))
		for r in ratings:
			urm[r.user_id-1][r.item_id-1] = r.rating
		return urm
		
	def create_icm(self, items=None, metadatas=None):
		"""Returns the item content matrix"""
		if not items:
			items = self.db.query(Item).all()
		if not metadatas:
			metadatas = self.db.query(Metadata).all()
		
		icm = numpy.zeros((len(metadatas),len(items)))
		for i in items:
			for m in i.metadatas:
				icm[m.id-1][i.id-1] = 1
		return icm
	
	def create_model(self, algname):
		pass
	
	
	@clean	
	def do_something(self):
		print 'in something'
		print 'URM'
		print self.create_urm()
		print 'ICM'
		print self.create_icm()
		#do something
		
