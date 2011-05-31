from pymatlab.matlab import MatlabSession
import numpy 
from models import User, Item, Rating, Metadata, DBSession
import os
import functools

ALGOPATH='../../algorithms'

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
		self.savepath = os.path.join(os.path.abspath(ALGOPATH), 'saved')
		self.db = DBSession()
	
	def _put(self, name, value):
		self.m.putvalue(name, value)
	
	def _run(self, command):
		self.m.run(command)
		
	def _get(self, name):
		return self.m.getvalue(name)
	
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
		
	def create_userprofile(self, user, items=None):
		if not items:
			items = self.db.query(Item).all()
		
		ratings = self.db.query(Rating).all()
		up = numpy.zeros((1,len(items)))
		for r in ratings:
			up[0][r.item.id-1] = r.rating
		return up
	
	@clean
	def create_model(self, algname, urm=None):
		#function [model] = createModel_AsySVD(URM,param)
		if not urm:
			urm = self.create_urm()
		self._put('urm', urm)
		self._run("["+algname+"_model] = createModel_"+algname+"(urm)")
		self._run("save('"+os.path.join(self.savepath, algname+'_model')+"', '"+algname+"_model')")
			
	
	@clean
	def get_rec(self, algname, user, **param):
		#function [recomList] = onLineRecom_AsySVD (userProfile, model,param)
		up = self.create_userprofile(user)
		self._put('up', up)
		self._run("param = struct()")
		for k,v in param.iteritems():
			self._run("param."+str(k)+" = "+str(v))
		self._run("load('"+os.path.join(self.savepath, algname+'_model')+"', '"+algname+"_model')")
		self._run("[rec] = onLineRecom_"+algname+"(up, "+algname+"_model, param)")
		return self._get("rec")
	
	@clean	
	def do_something(self):
		print 'in something'
		print 'URM'
		print self.create_urm()
		print 'ICM'
		print self.create_icm()
		print 'run AsySVD'
		print self.create_model('AsySVD')
		print 'get rec'
		print self.get_rec('AsySVD', self.db.query(User).filter(User.id==2).first(), userToTest=2)
		#do something
		
