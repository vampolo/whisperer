import transaction

from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm.exc import NoResultFound

from sqlalchemy import create_engine
from sqlalchemy import Integer
from sqlalchemy import Unicode
from sqlalchemy import Column
from sqlalchemy import TIMESTAMP

from zope.sqlalchemy import ZopeTransactionExtension

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
Base = declarative_base()

""" class MyModel(Base):
    __tablename__ = 'models'
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(255), unique=True)
    value = Column(Integer)

    def __init__(self, name, value):
        self.name = name
        self.value = value
"""

class URM(Base):
	__tablename__ = 'urm'
	id = Column(Integer, primary_key=True)
	# put reference
	userId = Column(Integer, ForeignKey('users.id'))
	itemId = Column(Integer, ForeignKey('item.id'))

	rating = Column(Integer)
	dataSet = Column(Unicode(255))	
	# timestamp = Column(TIMESTAMP)

    def __init__(self, userId, itemId, rating, dataSet):
        self.userId = userId
        self.itemId = itemId
	self.rating = rating
	self.dataSet = dataSet

class ICM(Base):
	__tablename__ = 'icm'
	id = Column(Integer, primary_key=True)

	# put reference
	itemId = Column(Integer, ForeignKey('item.id'))
	metadataId = Column(Integer, ForeignKey('metadata.id'))	

    def __init__(self, itemId, metadataId):
        self.itemId = itemId
        self.metadataId = metadataId

class metadata(Base):
	__tablename__ = 'metadata'
	id = Column(Integer, primary_key=True)
	metaName = Column(Unicode(255))
	metaType = Column(Unicode(255))
	metaLang = Column(Unicode(255))
  

    def __init__(self, metaName, metaType, metaLang):
        self.metaName = metaName
	self.metaType = metaType
	self.metaLang = metaLang

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

"""
def populate():
    session = DBSession()
    model = MyModel(name=u'test name', value=55)
    session.add(model)
    session.flush()
    transaction.commit()
"""

def populate():
    session = DBSession()
    #just a examp	
    metadata1 = metadata(metadataId=1, metaName='Brad Pitt', metaType='actor', metaLang='eng')
    session.add(metadata1)

    session.flush()
    transaction.commit()


def initialize_sql(engine):
    DBSession.configure(bind=engine)
    Base.metadata.bind = engine
    Base.metadata.create_all(engine)
    try:
	populate()
    except IntegrityError:
        DBSession.rollback()

def appmaker(engine):
    initialize_sql(engine)
    return default_get_root
