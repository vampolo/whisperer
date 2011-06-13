from pyramid.view import view_config
#get all classes from the models to be used
from models import *
from whisperer import Whisperer
import tasks

@view_config(context='whisperer.models.MyApp',
             renderer='templates/base.pt')
def admin(request):
	return dict()

@view_config(name='createAllModels',
			 context='whisperer.models.MyApp',
             renderer='json')
def admin_create(context, request):
	for algname in Whisperer.get_algnames():
		tasks.gen_model.delay(algname)
	return dict()

@view_config(context='whisperer.models.Algorithm',
             renderer='templates/model.pt')
def single_model(context, request):
    return dict()

@view_config(name='create',
			 context='whisperer.models.Algorithm',
             renderer='json')
def create_model(context, request):
	tasks.gen_model.delay(context.name)
	return dict(test='success')
    
@view_config(name='populate',
			 context = 'whisperer.models.MyApp',
			 renderer = 'json')
def populate_database(context, request):
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
			metadata = Metadata(name = meta.get('name'), type = meta.get('type'), lang = meta.get('lang'))
			session.add(metadata)
			session.flush()
	
	metadatas = session.query(Metadata).all()
	max_metadata = len(metadatas)-1

	for item in items:
		if not session.query(Item).filter(Item.name.in_([item])).all():			
			new_item = Item(name = item)
			new_item.metadatas.append(metadatas[randint(0,max_metadata)])
			session.add(new_item)
			session.flush()

	items = session.query(Item).all()
	max_item = len(items)-1
	
	for username in users:
		if not session.query(User).filter(User.name.in_([username])).all():
			user = User(name = username)
			user.ratings.append(Rating(user = user, item = items[randint(0, max_item)], rating = randint(0,5)))
			session.add(user)
			session.flush()
	
	users = session.query(User).all()
	max_user = len(users)-1
	
	ratings = session.query(Rating).all()
	max_ratings = len(ratings)
	return dict()
