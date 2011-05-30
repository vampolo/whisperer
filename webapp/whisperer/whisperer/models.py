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

	def __init__(self, user, item, rating):
		self.user = user
		self.item = item
		self.rating = rating

class User(Base):
	__tablename__ = 'user'
	id = Column(Integer, primary_key=True)
	name = Column(Unicode(255), unique=True)
	timestamp = Column(DateTime, default=datetime.datetime.now)

	#one user has many ratings (one to many)
	ratings = relationship("Rating", backref="user")

	def __init__(self, username):
		self.name = username

items_metadatas_table = Table('items_metadatas', Base.metadata,
    Column('item_id', Integer, ForeignKey('item.id')),
    Column('metadata_id', Integer, ForeignKey('metadata.id'))
)

class Dataset(Base):
	__tablename__ = 'dataset'
	id = Column(Integer, primary_key=True)
	items = relationship("Item", backref="dataset")
	timestamp = Column(DateTime, default=datetime.datetime.now)
	
class Item(Base):
	__tablename__ = 'item'
	id = Column(Integer, primary_key=True)
	name = Column(Unicode(255))
	dataset_id = Column(Integer, ForeignKey('dataset.id'))
	timestamp = Column(DateTime, default=datetime.datetime.now)
	
	#many metadatas refer to many items (many-to-one)
	metadatas = relationship("Metadata", 
							 secondary=items_metadatas_table,
							 backref="items")
	
	def __init__(self, name, dataset=None):
		self.name = name
		self.dataset = dataset

class Metadata(Base):
	__tablename__ = 'metadata'
	id = Column(Integer, primary_key=True)
	name = Column(Unicode(255))
	type = Column(Unicode(255))
	lang = Column(Unicode(255))
	timestamp = Column(DateTime, default=datetime.datetime.now)
	
	#metadata-item relation set on item
	
	def __init__(self, name, type, lang):
		self.name = name
		self.type = type
		self.lang = lang

class MyModel(Base):
    __tablename__ = 'models'
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(255), unique=True)
    value = Column(Integer)

    def __init__(self, name, value):
        self.name = name
        self.value = value


class MyApp(object):
    __name__ = None
    __parent__ = None

    def __getitem__(self, key):
        session= DBSession()
        try:
            id = int(key)
        except (ValueError, TypeError):
            raise KeyError(key)

        query = session.query(MyModel).filter_by(id=id)

        try:
            item = query.one()
            item.__parent__ = self
            item.__name__ = key
            return item
        except NoResultFound:
            raise KeyError(key)

    def get(self, key, default=None):
        try:
            item = self.__getitem__(key)
        except KeyError:
            item = default
        return item

    def __iter__(self):
        session= DBSession()
        query = session.query(MyModel)
        return iter(query)

root = MyApp()

def default_get_root(request):
    return root

def populate_database():
	'''
	populate database with fake data
	'''
	from random import randint
	
	session = DBSession()
	
	#create some users for first
	users = ['Andeia', 'Vincenzo', 'Leonardo', 'Paolo']
	items = ['film1', 'film2', 'film3', 'film4', 'film5']
	metadatas = [dict(name='primo metadato', type='boh', lang='eng'),
				 dict(name='secondo metadato', type='boh2', lang='eng'),
				 dict(name='metadato3', type='boh3', lang='eng'),
				 dict(name='metadato4', type='boh4', lang='eng'),
				 dict(name='metadato5', type='boh5', lang='eng')]
	
	
	for meta in metadatas:
		if not session.query(Metadata).filter(Metadata.name.in_([meta.get('name')])).all():
			metadata = Metadata(meta.get('name'), meta.get('type'), meta.get('lang'))
			session.add(metadata)
			session.flush()
	
	metadatas = session.query(Metadata).all()
	max_metadata = len(metadatas)-1

	for item in items:
		if not session.query(Item).filter(Item.name.in_([item])).all():			
			new_item = Item(item)
			new_item.metadatas.append(metadatas[randint(0,max_metadata)])
			session.add(new_item)
			session.flush()

	items = session.query(Item).all()
	max_item = len(items)-1
	
	for username in users:
		if not session.query(User).filter(User.name.in_([username])).all():
			user = User(username)
			user.ratings.append(Rating(user, items[randint(0, max_item)], randint(0,5)))
			session.add(user)
			session.flush()
	
	users = session.query(User).all()
	max_user = len(users)-1
	
	ratings = session.query(Rating).all()
	max_ratings = len(ratings)
	
	from whisperer import Whisperer
	
	w = Whisperer()
	w.do_something()
	
	
def initialize_sql(engine):
    DBSession.configure(bind=engine)
    Base.metadata.bind = engine
    Base.metadata.create_all(engine)
    try:
		session = DBSession()
		model = MyModel(name=u'test name', value=55)
		session.add(model)	
		session.flush()
		transaction.commit()
    except IntegrityError:
        DBSession.rollback()
    populate_database()    	    	
    
	

def appmaker(engine):
    initialize_sql(engine)
    #Base.metadata.drop_all(engine)	
    return default_get_root

