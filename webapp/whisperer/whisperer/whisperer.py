from pymatlab.matlab import MatlabSession
import numpy 
from models import User, Item, Rating, Metadata
import os
import functools
import datetime

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
engine = create_engine('sqlite:///whisperer.db', echo=True)
Session = sessionmaker(bind=engine)

#request.registry.settings
here = os.path.abspath(os.path.dirname(__file__))
ALGOPATH=os.path.join(os.path.join(here,'../algorithms'))

def matlab(f):
	@functools.wraps(f)
	def wrapper(self, *args, **kwds):
		if not self.m:
			self._start_matlab()
		self._clean()
		res = f(self, *args, **kwds)
		self._clean()
		return res
	return wrapper
	
class Whisperer(object):
	
	savepath = os.path.join(os.path.abspath(ALGOPATH), 'saved')
	
	def _start_matlab(self):
		self.m = MatlabSession('matlab -nosplash -nodisplay')
		self.m.run("addpath(genpath('"+os.path.abspath(ALGOPATH)+"'))")
		
	def __init__(self):
		self.m = None
		self.db = Session()
	
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
	
	@matlab
	def create_model(self, algname, urm=None):
		"""Create a model and saves it the ALGORITHMS/saved directory"""
		#function [model] = createModel_AsySVD(URM,param)
		if not urm:
			urm = self.create_urm()
		self._put('urm', urm)
		self._run("["+algname+"_model] = createModel_"+algname+"(urm)")
		self._run("save('"+os.path.join(self.savepath, algname+'_model')+"', '"+algname+"_model')")
	
	@matlab		
	def _get_rec(self, algname, user, **param):
		"""Return a recommendation using the matlab engine"""
		#function [recomList] = onLineRecom_AsySVD (userProfile, model,param)
		up = self.create_userprofile(user)
		self._put('up', up)
		self._run("param = struct()")
		for k,v in param.iteritems():
			self._run("param."+str(k)+" = "+str(v))
		self._run("load('"+os.path.join(self.savepath, algname+'_model')+"', '"+algname+"_model')")
		self._run("[rec] = onLineRecom_"+algname+"(up, "+algname+"_model, param)")
		return self._get("rec")
	
	def get_rec(self, algname, user, **param):
		"""Wrapper aroung the real recommendation getter to set parameters"""
		if algname == 'AsySVD':
			param = dict(param, userToTest=user.id)
		
		return self._get_rec(algname, user, **param)
	
	@classmethod	
	def get_algnames(self):
		"""Return a list of algorithms in the system"""
		algs = list()
		for root, dirs, files in os.walk(ALGOPATH):
			for f in files:
				if f.startswith('createModel'):
					algs.append(f[12:-2])
		algs.sort()
		return algs
	
	@classmethod
	def get_models_info(self):
		"""Return a dict of algorithms in which there is a model created and the time the model was created"""
		algnames = self.get_algnames()
		algs = dict()
		for root, dirs, files in os.walk(self.savepath):
			for f in files:
				if f[:-10] in algnames:
					algo =f[:-10]
					path = os.path.join(root, f)
					algs[algo] = datetime.datetime.fromtimestamp(os.path.getmtime(path))
		return algs
		
	def do_something(self):
		print 'URM'
		print self.create_urm()
		print 'ICM'
		print self.create_icm()
		print 'run AsySVD'
		#print self.create_model('AsySVD')
		#print self.create_model('cosineIIknn')
		print 'get rec'
		print self.get_rec('AsySVD', self.db.query(User).filter(User.id==2).first())
		print Whisperer.get_algnames()
		print self.get_models_info()
		#do something
		
