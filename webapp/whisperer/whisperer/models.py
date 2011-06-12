import transaction

from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import relationship, backref

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm.exc import NoResultFound

from sqlalchemy import Integer, String, Unicode, DateTime, ForeignKey, Column, Table

from zope.sqlalchemy import ZopeTransactionExtension

import datetime 

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
Base = declarative_base()

class Rating(Base):
	__tablename__ = 'rating'
	id = Column(Integer, primary_key=True)
	user_id = Column(Integer, ForeignKey('user.id'))
	item_id = Column(Integer, ForeignKey('item.id'))
	rating = Column(Integer)
	timestamp = Column(DateTime, default=datetime.datetime.now)
	
	#many ratings refer to one item (many-to-one)
	item = relationship("Item", backref="ratings")

class User(Base):
	__tablename__ = 'user'
	id = Column(Integer, primary_key=True)
	name = Column(Unicode(255), unique=True)
	timestamp = Column(DateTime, default=datetime.datetime.now)

	#one user has many ratings (one to many)
	ratings = relationship("Rating", backref="user")

items_metadatas_table = Table('items_metadatas', Base.metadata,
    Column('item_id', Integer, ForeignKey('item.id')),
    Column('metadata_id', Integer, ForeignKey('metadata.id'))
)

items_datasets_table = Table('items_datasets', Base.metadata,
    Column('item_id', Integer, ForeignKey('item.id')),
    Column('dataset_id', Integer, ForeignKey('dataset.id'))
)

class Dataset(Base):
	__tablename__ = 'dataset'
	id = Column(Integer, primary_key=True)
	items = relationship("Item", backref="dataset")
	timestamp = Column(DateTime, default=datetime.datetime.now)
	
	#many items refers to many datasets (many-to-many)
	items = relationship("Item",
						 secondary=items_datasets_table,
						 backref="datasets")
	
class Item(Base):
	__tablename__ = 'item'
	id = Column(Integer, primary_key=True)
	name = Column(Unicode(255))
	timestamp = Column(DateTime, default=datetime.datetime.now)
	
	#many metadatas refer to many items (many-to-many)
	metadatas = relationship("Metadata", 
							 secondary=items_metadatas_table,
							 backref="items")		
	
class Metadata(Base):
	__tablename__ = 'metadata'
	id = Column(Integer, primary_key=True)
	name = Column(Unicode(255))
	type = Column(Unicode(255))
	lang = Column(Unicode(255))
	timestamp = Column(DateTime, default=datetime.datetime.now)
	
	#metadata-item relation set on item

class UserResource(object):
	
	def __getitem__(self, key):
		session = DBSession()
		try:
			user = session.query(User).filter(User.id==int(key)).one()
		except NoResultFound:
			raise KeyError
		res = User()
		res.__name__ = key
		res.__parent__ = user
		return res
		
class ItemResource(object):
	
	def __getitem__(self, key):
		session = DBSession()
		try:
			item = session.query(Item).filter(Item.id==key).one()
		except NoResultFound:
			raise KeyError
		res = Item()
		res.__name__ = key
		res.__parent__ = item
		return res
		
class Algorithm(object):
	def __init__(self, name, date):
		self.name = name
		self.date = date.strftime("%d/%m/%y %H:%M") if date else None

class MyApp(object):	
    __name__ = None																																																																																																																																																																																																																																																																																																														
    __parent__ = None
    
    def __getitem__(self, key):
		if key == 'user':
			user = UserResource()
			user.__parent__ = self
			user.__name__ = key
			return user
		if key == 'item':
			item = ItemResource()
			item.__parent__ = self
			item.__name__ = key
			return item
		from whisperer import Whisperer
		if key in Whisperer.get_algnames():
			infos = Whisperer.get_models_info()
			a = Algorithm(key,infos.get(key))
			a.__parent__ = self
			a.__name__ = key
			return a
		else:
			raise KeyError
    

root = MyApp()

def default_get_root(request):
    return root
	
	
def initialize_sql(engine):
    DBSession.configure(bind=engine)
    Base.metadata.bind = engine
    Base.metadata.create_all(engine)
    
	

def appmaker(engine):
    initialize_sql(engine)
    #Base.metadata.drop_all(engine)	
    return default_get_root

