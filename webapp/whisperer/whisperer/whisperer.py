from pymatlab.matlab import MatlabSession
import numpy 
from models import User, Item, Rating, Metadata
import os
import functools
import datetime
import config

from sqlalchemy import create_engine, func
from sqlalchemy.orm import sessionmaker
engine = create_engine(config.DB, echo=True)
Session = sessionmaker(bind=engine)

#request.registry.settings

def matlab(f):
	@functools.wraps(f)
	def wrapper(self, *args, **kwds):
		self._start_matlab()
		res = f(self, *args, **kwds)
		self._close_matlab()
		return res
	return wrapper
	
class Whisperer(object):
	
	savepath = config.SAVEPATH
	algopath = config.ALGOPATH
	
	def _start_matlab(self):
		self.m = MatlabSession('matlab -nosplash -nodisplay')
		self.m.run("addpath(genpath('"+os.path.abspath(self.algopath)+"'))")
		
	def __init__(self):
		self.m = None
		self.db = Session()
	
	def _put(self, name, value):
		self.m.putvalue(name, value)
	
	def _run(self, command):
		self.m.run(command)
		
	def _get(self, name):
		return self.m.getvalue(name)
	
	def _close_matlab(self):
		if self.m:
			self.m.close()
		self.m = None
		
	def create_urm(self, users=None, items=None, ratings=None):
		"""Return the user rating matrix"""
		if not users:
			users = self.db.query(User).all()
		if not items:
			items = self.db.query(Item).all()
		if not ratings:
			ratings = self.db.query(Rating).all()
		
		urm = numpy.zeros((self.db.query(func.max(User.id)).one()[0],self.db.query(func.max(Item.id)).one()[0]))
		for r in ratings:
			urm[r.user_id-1][r.item_id-1] = r.rating
		return urm
		
	def create_icm(self, items=None, metadatas=None):
		"""Returns the item content matrix"""
		if not items:
			items = self.db.query(Item).all()
		if not metadatas:
			metadatas = self.db.query(Metadata).all()
		
		icm = numpy.zeros((self.db.query(func.max(Metadata.id)).one()[0],self.db.query(func.max(Item.id)).one()[0]))
		for i in items:
			for m in i.metadatas:
				icm[m.id-1][i.id-1] = 1
		return icm
		
	def create_userprofile(self, user, items=None):
		if not items:
			items = self.db.query(Item).all()
		
		ratings = self.db.query(Rating).all()
		up = numpy.zeros((1,self.db.query(func.max(Item.id)).one()[0]))
		for r in ratings:
			up[0][r.item.id-1] = r.rating
		return up
	
	@matlab
	def create_model(self, algname, urm=None, icm=None):
		"""Create a model and saves it the ALGORITHMS/saved directory"""
		#function [model] = createModel_AsySVD(URM,param)
		if not urm:
			urm = self.create_urm()
		if not icm:
			icm = self.create_icm()
		
		alg = self._get_model_name(algname)
		self._put('urm', urm)
		self._run("["+alg+"_model] = createModel_"+alg+"(urm, icm)")
		self._run("save('"+os.path.join(self.savepath, alg+'_model')+"', '"+alg+"_model')")
	
	@matlab		
	def _get_rec(self, algname, user, **param):
		"""Return a recommendation using the matlab engine"""
		#function [recomList] = onLineRecom_AsySVD (userProfile, model,param)
		up = self.create_userprofile(user)
		alg = self._get_model_name(algname)
		
		self._put('up', up)
		self._run("param = struct()")
		for k,v in param.iteritems():
			self._run("param."+str(k)+" = "+str(v))
		self._run("load('"+os.path.join(self.savepath, alg+'_model')+"', '"+alg+"_model')")
		self._run("[rec] = onLineRecom_"+algname+"(up, "+alg+"_model, param)")
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
		for root, dirs, files in os.walk(self.algopath):
			for f in files:
				if f.startswith('onLineRecom'):
					algs.append(f[12:-2])
		algs.sort()
		return algs
		
	@classmethod
	def _get_model_name(self, algname=None):
		for root, dirs, files in os.walk(self.algopath):
			for f in files:
				if f.startswith('onLineRecom'):
					if f[12:-2] == algname:
						for mf in files:
							if mf.startswith('createModel'):
								return mf[12:-2]
					
		return None
		
	
	@classmethod
	def get_models_info(self):
		"""Return a dict of algorithms in which there is a model created and the time the model was created"""
		algnames = self.get_algnames()
		algs = dict()
		for root, dirs, files in os.walk(self.savepath):
			for f in files:
				for algname in algnames:
					if f[:-10] in self._get_model_name(algname):
						algo =f[:-10]
						path = os.path.join(root, f)
						algs[algname] = datetime.datetime.fromtimestamp(os.path.getmtime(path))
		return algs
	
	@matlab
	def load_urm(self):
		self._run("load('urmFull.mat')")
		self._run("A=full(urm)")
		urm = self._get("A")
		#force matlab to close and free memory
		self._close_matlab()
		print 'Out of matlab!'
		#for (row,col),value in numpy.ndenumerate(urm):
		for i,row in enumerate(urm):
			print 'processing row: %s' % (i)
			self.db.add(User(name="netflix%s" % (i)))
			self.db.flush()	
		self.db.commit()
		#urm[r.user_id-1][r.item_id-1]
	
	@matlab
	def load_titles(self, filename='/tmp/movie_titles.txt'):
		self._run("load('titles.mat')")
		titles = self._get('titles')
		l = list()
		for row in titles:
			l.append(''.join(row).rstrip())
		f = open(filename, 'w')
		for item in l:
			f.write("%s\n" % item)
		f.close()
		return l
		
	def do_something(self):
		print 'URM'
		print self.create_urm()
		print 'ICM'
		print self.create_icm()
		print 'run AsySVD'
		print self.create_model('AsySVD')
		#print self.create_model('cosineIIknn')
		print 'get rec'
		print self.get_rec('AsySVD', self.db.query(User).filter(User.id==35).first())
		print Whisperer.get_algnames()
		print self.get_models_info()
		#do something

if __name__=='__main__':
	w = Whisperer()
	print w.get_models_info()
	#w.load_urm()
	#w.do_something()
