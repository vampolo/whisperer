import transaction

from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import relationship, backref

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm.exc import NoResultFound

from sqlalchemy import Integer, String, Unicode, DateTime, ForeignKey, Column, create_engine, Table

from zope.sqlalchemy import ZopeTransactionExtension

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
Base = declarative_base()

class Rating(Base):
	__tablename__ = 'rating'
	id = Column(Integer, primary_key=True)
	userId = Column(Integer, ForeignKey('user.id'))
	itemId = Column(Integer, ForeignKey('item.id'))
	rating = Column(Integer)
	timestamp = Column(DateTime)
	
	#many ratings refer to one item (many-to-one)
	item= relationship("Item", backref="ratings")

	def __init__(self, userId, itemId, rating):
		self.userId = userId
		self.itemId = itemId
		self.rating = rating

class User(Base):
	__tablename__ = 'user'
	id = Column(Integer, primary_key=True)
	username = Column(Unicode(255), unique=True)

	#one user has many ratings (one to many)
	ratings = relationship("Rating", backref="user")

	def __init__(self, username):
		self.username = username

items_metadatas_table = Table('items_metadatas', Base.metadata,
    Column('item_id', Integer, ForeignKey('item.id')),
    Column('metadata_id', Integer, ForeignKey('metadata.id'))
)

class Item(Base):
	__tablename__ = 'item'
	id = Column(Integer, primary_key=True)
	itemName = Column(Unicode(255))
	dataSet = Column(Unicode(255))
	
	#many metadatas refer to many items (many-to-one)
	metadatas = relationship("Metadata", 
							 secondary=items_metadatas_table,
							 backref="items")
	
	def __init__(self, itemName, dataSet):
		self.itemName = itemName
		self.dataSet = dataSet

class Metadata(Base):
	__tablename__ = 'metadata'
	id = Column(Integer, primary_key=True)
	metaName = Column(Unicode(255))
	metaType = Column(Unicode(255))
	metaLang = Column(Unicode(255))

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

