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

class URMcell(Base):
	__tablename__ = 'URM'
	id = Column(Integer, primary_key=True)
	# put reference
	userId = Column(Integer, ForeignKey('User.id'))
	itemId = Column(Integer, ForeignKey('Item.id'))
	rating = Column(Integer)
	# timestamp = Column(TIMESTAMP)
	# timestamp = Column(DateTime)


    	def __init__(self, userId, itemId, rating):
			self.userId = userId
			self.itemId = itemId
			self.rating = rating

class ICMcell(Base):
	__tablename__ = 'ICM'
	id = Column(Integer, primary_key=True)

	# put reference
	itemId = Column(Integer, ForeignKey('Item.id'))
	metadataId = Column(Integer, ForeignKey('Metadata.id'))	

	def __init__(self, itemId, metadataId):
        	self.itemId = itemId
	        self.metadataId = metadataId

class User(Base):
	__tablename__ = 'User'
	id = Column(Integer, primary_key=True)
	username = Column(Unicode(255), unique=True)

	# is relationship right?!
	ratings = relationship("URMcell", backref="User")

	def __init__(self, username):
		self.username = username

class Item(Base):
	__tablename__ = 'Item'
	id = Column(Integer, primary_key=True)
	itemName = Column(Unicode(255), unique=True)
	dataSet = Column(Unicode(255))

	# is relationship right?!
	ratings = relationship("URMcell", backref="Item")
	itemContent = relationship("ICMcell", backref="Item")

	def __init__(self, itemName, dataSet):
		self.itemName = itemName
		self.dataSet = dataSet

class Metadata(Base):
	__tablename__ = 'Metadata'
	id = Column(Integer, primary_key=True)
	#And uniqueness? Can be a metaName, but Brad could be a director name or a actor name.... but are different items!
	metaName = Column(Unicode(255))
	metaType = Column(Unicode(255))
	metaLang = Column(Unicode(255))
  
	# is relationship right?!
	itemContent = relationship("ICMcell", backref="Metadata")


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

def initialize_sql(engine):
    DBSession.configure(bind=engine)
    Base.metadata.bind = engine
    Base.metadata.create_all(engine)
    try:
		session = DBSession()
		model = MyModel(name=u'test name', value=55)
		#user1 = user(username='John')
    		#item1 = item(itemName='Inglourious Bastards', dataSet='NetFlix')	
	    	#metadata1 = metadata(metaName='Brad Pitt', metaType='actor', metaLang='eng')
		#urmTest = URMcell(userId=user1.id, itemId=item1.id, rating=5)
    		#icmTest = ICMcell(itemId=item1.id, metadataId=metadata1.id)
		#session.add_all(user1, item1, metadata1, urmTest, icmTest)    	    	
		session.add(model)	
		session.flush()
		transaction.commit()
    except IntegrityError:
        DBSession.rollback()
    
	

def appmaker(engine):
    initialize_sql(engine)
    #Base.metadata.drop_all(engine)	
    return default_get_root

