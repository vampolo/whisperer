import transaction

from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import relationship, backref

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm.exc import NoResultFound

from sqlalchemy import create_engine
from sqlalchemy import Integer, String, Unicode
from sqlalchemy import Column
from sqlalchemy import TIMESTAMP, ForeignKey

from zope.sqlalchemy import ZopeTransactionExtension

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
Base = declarative_base()

class URMrow(Base):
	__tablename__ = 'urm'
	id = Column(Integer, primary_key=True)
	# put reference
	userId = Column(Integer, ForeignKey('user.id'))
	itemId = Column(Integer, ForeignKey('item.id'))

	rating = Column(Integer)
	dataSet = Column(Unicode(255))	
	# timestamp = Column(TIMESTAMP)
	# timestamp = Column(DateTime)


    	def __init__(self, userId, itemId, rating, dataSet):
        	self.userId = userId
	        self.itemId = itemId
		self.rating = rating
		self.dataSet = dataSet

class ICMrow(Base):
	__tablename__ = 'icm'
	id = Column(Integer, primary_key=True)

	# put reference
	itemId = Column(Integer, ForeignKey('item.id'))
	metadataId = Column(Integer, ForeignKey('metadata.id'))	

	def __init__(self, itemId, metadataId):
        	self.itemId = itemId
	        self.metadataId = metadataId

class user(Base):
	__tablename__ = 'user'
	id = Column(Integer, primary_key=True)
	username = Column(Unicode(255), unique=True)

	# is relationship right?!
	ratings = relationship("URMrow", backref="user")

	def __init__(self, username):
		self.username = username

class item(Base):
	__tablename__ = 'item'
	id = Column(Integer, primary_key=True)
	itemName = Column(Unicode(255), unique=True)

	# is relationship right?!
	ratings = relationship("URMrow", backref="item")
	itemContent = relationship("ICMrow", backref="item")

	def __init__(self, itemName):
		self.itemName = itemName

class metadata(Base):
	__tablename__ = 'metadata'
	id = Column(Integer, primary_key=True)
	metaName = Column(Unicode(255), unique=True)
	metaType = Column(Unicode(255))
	metaLang = Column(Unicode(255))
  
	# is relationship right?!
	itemContent = relationship("ICMrow", backref="metadata")


	def __init__(self, metaName, metaType, metaLang):
		self.metaName = metaName
		self.metaType = metaType
		self.metaLang = metaLang

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

def populate():
    session = DBSession()
    model = MyModel(name=u'test name', value=55)
    session.add(model)
    session.flush()
    transaction.commit()


def testing():
    session = DBSession()
    #just a examp
    user1 = user(username='John')
    item1 = item(itemName='Inglourious Bastards')	
    metadata1 = metadata(metaName='Brad Pitt', metaType='actor', metaLang='eng')
    #session.save(user1,item1,metadata1)
    urmTest = URMrow(userId=user1.id, itemId=item1.id, rating=5, dataSet='NetFlix')
    icmTest = ICMrow(itemId=item1.id, metadataId=metadata1.id)
    session.add(icmTest)
    session.flush()
    transaction.commit()


def initialize_sql(engine):
    DBSession.configure(bind=engine)
    Base.metadata.bind = engine
    Base.metadata.create_all(engine)
    try:
	testing()
    except IntegrityError:
        DBSession.rollback()

def appmaker(engine):
    initialize_sql(engine)
    return default_get_root
"""
import transaction

from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import relationship, backref

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm.exc import NoResultFound

from sqlalchemy import create_engine
from sqlalchemy import Integer, String, Unicode
from sqlalchemy import Column
from sqlalchemy import TIMESTAMP, ForeignKey

from zope.sqlalchemy import ZopeTransactionExtension

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))

Base = declarative_base()

class user(Base):
	__tablename__ = 'user'

	id = Column(Integer, primary_key=True)
	username = Column(String(50))

	# is relationship right?!
	#URMratings = relationship("URMrow", backref="user")

	def __init__(self, username):
		self.username = username

	def __repr__(self):
		return "<User('%s')>" % (self.username)


class URMrow(Base):
	__tablename__ = 'urm'
	id = Column(Integer, primary_key=True)
	# put reference
	userId = Column(Integer, ForeignKey('user.id'))
	itemId = Column(Integer, ForeignKey('item.id'))

	rating = Column(Integer)
	dataSet = Column(String(50))	
	# timestamp = Column(TIMESTAMP)
	# timestamp = Column(DateTime)

    	def __init__(self, userId, itemId, rating, dataSet):
        	self.userId = userId
	        self.itemId = itemId
		self.rating = rating
		self.dataSet = dataSet

class ICMrow(Base):
	__tablename__ = 'icm'
	id = Column(Integer, primary_key=True)

	# put reference
	itemId = Column(Integer, ForeignKey('item.id'))
	metadataId = Column(Integer, ForeignKey('metadata.id'))	
	
	def __init__(self, itemId, metadataId):
        	self.itemId = itemId
	        self.metadataId = metadataId

class item(Base):
	__tablename__ = 'item'
	id = Column(Integer, primary_key=True)
	itemName = Column(String(50), unique=True)
	
	# is relationship right?!
	ratings = relationship("URMrow", backref="item")
	itemContent = relationship("ICMrow", backref="item")

	def __init__(self, itemName):
		self.itemName = itemName

class metadata(Base):
	__tablename__ = 'metadata'
	id = Column(Integer, primary_key=True)
	metaName = Column(String(50), unique=True)
	metaType = Column(String(50))
	metaLang = Column(String(50))
  
	# is relationship right?!
	itemContent = relationship("ICMrow", backref="metadata")


	def __init__(self, metaName, metaType, metaLang):
		self.metaName = metaName
		self.metaType = metaType
		self.metaLang = metaLang

class MyModel(Base):
    __tablename__ = 'models'
    id = Column(Integer, primary_key=True)
    name = Column(String(50))
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

def populate():
    session = DBSession()
    model = MyModel(name=u'test name', value=55)
    session.add(model)
    session.flush()
    transaction.commit()


def testing():

	session = DBSession()
	
	our_user = session.query(user).filter_by(username='Mary').first() 
	our_user
	
	#The underlying Table object created by our declarative_base() version of User is accessible via the __table__ attribute:
	users_table = user.__table__
	#users_table	
	#The owning MetaData object is available as well:
	metadata = Base.metadata
	metadata

	#just a examp
	#user1 = user('John',  URMratings=[URMrow(itemId=1)])
	#user1 = user('Mary')	
	#session.add(user1)
	session.flush()
	transaction.commit()

	item1 = item(itemName='InglouriousBastards')	
	session.add(item1)

	metadata1 = metadata(metaName='BradPitt', metaType='actor', metaLang='eng')
	session.add(metadata1)

	session.flush()

	urmTest = URMrow(userId=user1.id, itemId=item1.id, rating=5, dataSet='NetFlix')
	icmTest = ICMrow(itemId=item1.id, metadataId=metadata1.id)

	session.add_all([icmTest, urmTest])

	

def initialize_sql(engine):
    DBSession.configure(bind=engine)
    Base.metadata.bind = engine
    Base.metadata.create_all(engine)
    try:
	testing()
    except IntegrityError, e:
        DBSession.rollback()
	print str(e)

def appmaker(engine):
    initialize_sql(engine)
    return default_get_root

"""
